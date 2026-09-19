import Foundation

enum RelayError: Error {
    case notFound
    case conflict
    case server(String)
    case transport(Error)
    case decoding(Error)
}

protocol RelayClient: AnyObject {
    var baseURL: URL { get set }
    func registerDevice(token: String) async throws -> Device
    func getDevice(byToken token: String) async throws -> Device
    func getDevice(byId id: String) async throws -> Device
    func updateDevice(id: String, downNotificationLevel: NotificationLevel) async throws -> Device
    func unregisterDevice(id: String) async throws
}

final class HTTPRelayClient: RelayClient {
    static let defaultRelayURL = URL(string: "https://kumapush.com")!

    var baseURL: URL
    private let session: URLSession

    init(baseURL: URL = HTTPRelayClient.defaultRelayURL, session: URLSession = .shared) {
        self.baseURL = baseURL
        self.session = session
    }

    func registerDevice(token: String) async throws -> Device {
        var request = URLRequest(url: baseURL.appendingPathComponent("devices"))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(["device_token": token])
        return try await send(request)
    }

    func getDevice(byToken token: String) async throws -> Device {
        try await send(URLRequest(url: baseURL.appendingPathComponent("devices/token/\(token)")))
    }

    func getDevice(byId id: String) async throws -> Device {
        try await send(URLRequest(url: baseURL.appendingPathComponent("devices/\(id)")))
    }

    func updateDevice(id: String, downNotificationLevel: NotificationLevel) async throws -> Device {
        var request = URLRequest(url: baseURL.appendingPathComponent("devices/\(id)"))
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(["down_notification_level": downNotificationLevel.rawValue])
        return try await send(request)
    }

    func unregisterDevice(id: String) async throws {
        var request = URLRequest(url: baseURL.appendingPathComponent("devices/\(id)"))
        request.httpMethod = "DELETE"
        _ = try await perform(request)
    }

    private func send(_ request: URLRequest) async throws -> Device {
        let (data, _) = try await perform(request)
        do {
            return try JSONDecoder().decode(Device.self, from: data)
        } catch {
            throw RelayError.decoding(error)
        }
    }

    private func perform(_ request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw RelayError.transport(error)
        }

        guard let http = response as? HTTPURLResponse else {
            throw RelayError.transport(URLError(.badServerResponse))
        }

        switch http.statusCode {
        case 200, 201, 204:
            return (data, http)
        case 404:
            throw RelayError.notFound
        case 409:
            throw RelayError.conflict
        default:
            if let apiError = try? JSONDecoder().decode(RelayAPIError.self, from: data) {
                throw RelayError.server(apiError.error)
            }
            throw RelayError.server("unexpected status \(http.statusCode)")
        }
    }
}
