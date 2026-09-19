import Foundation

enum RelayError: Error {
    case unauthorized
    case notFound
    case conflict
    case server(String)
    case transport(Error)
    case decoding(Error)
}

protocol RelayClient: AnyObject {
    var baseURL: URL { get set }
    func registerDevice(token: String) async throws -> DeviceRegistration
    func getDevice(byId id: String, authToken: String) async throws -> Device
    func updateDevice(id: String, authToken: String, downNotificationLevel: NotificationLevel) async throws -> Device
    func unregisterDevice(id: String, authToken: String) async throws
}

final class HTTPRelayClient: RelayClient {
    static let defaultRelayURL = URL(string: "https://kumapush.com")!

    var baseURL: URL
    private let session: URLSession

    init(baseURL: URL = HTTPRelayClient.defaultRelayURL, session: URLSession = .shared) {
        self.baseURL = baseURL
        self.session = session
    }

    func registerDevice(token: String) async throws -> DeviceRegistration {
        var request = URLRequest(url: baseURL.appendingPathComponent("devices"))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(["device_token": token])
        return try await send(request)
    }

    func getDevice(byId id: String, authToken: String) async throws -> Device {
        try await send(authorizedRequest(path: "devices/\(id)", method: "GET", authToken: authToken))
    }

    func updateDevice(id: String, authToken: String, downNotificationLevel: NotificationLevel) async throws -> Device {
        var request = authorizedRequest(path: "devices/\(id)", method: "PATCH", authToken: authToken)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(["down_notification_level": downNotificationLevel.rawValue])
        return try await send(request)
    }

    func unregisterDevice(id: String, authToken: String) async throws {
        _ = try await perform(authorizedRequest(path: "devices/\(id)", method: "DELETE", authToken: authToken))
    }

    private func authorizedRequest(path: String, method: String, authToken: String) -> URLRequest {
        var request = URLRequest(url: baseURL.appendingPathComponent(path))
        request.httpMethod = method
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        return request
    }

    private func send<T: Decodable>(_ request: URLRequest) async throws -> T {
        let (data, _) = try await perform(request)
        do {
            return try JSONDecoder().decode(T.self, from: data)
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
        case 401:
            throw RelayError.unauthorized
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
