import Combine
import Foundation

@MainActor
final class AppViewModel: ObservableObject {
    enum State {
        case loading
        case needsRegistration
        case registered(Device)
    }

    @Published private(set) var state: State = .loading
    @Published private(set) var isRegistering = false
    @Published private(set) var isUnregistering = false
    @Published private(set) var errorMessage: String?

    private let relay: RelayClient
    private let pushRegistrar: PushRegistrar
    private var store: DeviceStore

    init(relay: RelayClient, pushRegistrar: PushRegistrar, store: DeviceStore) {
        self.relay = relay
        self.pushRegistrar = pushRegistrar
        self.store = store
    }

    /// Checks whether this install already has a registered device and
    /// moves straight to the registered screen if so.
    func start() async {
        guard let id = store.deviceId else {
            state = .needsRegistration
            return
        }
        do {
            let device = try await relay.getDevice(byId: id)
            state = .registered(device)
        } catch {
            store.deviceId = nil
            state = .needsRegistration
        }
    }

    func getStartedTapped() async {
        errorMessage = nil
        isRegistering = true
        defer { isRegistering = false }

        do {
            let token = try await pushRegistrar.requestAuthorizationAndRegister()
            let device = try await register(token: token)
            store.deviceId = device.id
            state = .registered(device)
        } catch PushError.permissionDenied {
            errorMessage = "Notification permission was denied"
        } catch {
            errorMessage = "Could not register: \(Self.describe(error))"
        }
    }

    func unregisterTapped() async {
        guard case .registered(let device) = state else { return }

        errorMessage = nil
        isUnregistering = true
        defer { isUnregistering = false }

        do {
            try await relay.unregisterDevice(token: device.deviceToken)
            store.deviceId = nil
            state = .needsRegistration
        } catch RelayError.notFound {
            // Already gone on the relay; treat as success locally.
            store.deviceId = nil
            state = .needsRegistration
        } catch {
            errorMessage = "Could not unregister: \(Self.describe(error))"
        }
    }

    /// Registers the token, transparently reusing the existing device if the
    /// relay already knows this token (e.g. reinstall on the same device).
    private func register(token: String) async throws -> Device {
        do {
            return try await relay.registerDevice(token: token)
        } catch RelayError.conflict {
            return try await relay.getDevice(byToken: token)
        }
    }

    private static func describe(_ error: Error) -> String {
        switch error {
        case RelayError.server(let message):
            return message
        case RelayError.notFound:
            return "device not found"
        case RelayError.conflict:
            return "device already registered"
        case RelayError.transport:
            return "couldn't reach the relay"
        case RelayError.decoding:
            return "unexpected response from the relay"
        default:
            return error.localizedDescription
        }
    }
}
