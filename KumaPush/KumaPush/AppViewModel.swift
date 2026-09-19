import Combine
import Foundation

enum RelayOption: Hashable {
    case defaultRelay
    case custom
}

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

    @Published var relayOption: RelayOption = .defaultRelay
    @Published var customRelayAddress: String = ""

    var currentRelayURL: URL { relay.baseURL }

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
        if let storedURL = store.relayBaseURL {
            applyToForm(relayURL: storedURL)
        }

        guard let id = store.deviceId, let url = store.relayBaseURL else {
            state = .needsRegistration
            return
        }

        relay.baseURL = url
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

        guard let relayURL = resolvedRelayURL() else {
            errorMessage = "Enter a valid relay address"
            return
        }

        isRegistering = true
        defer { isRegistering = false }

        relay.baseURL = relayURL
        do {
            let token = try await pushRegistrar.requestAuthorizationAndRegister()
            let device = try await register(token: token)
            store.deviceId = device.id
            store.relayBaseURL = relayURL
            state = .registered(device)
        } catch PushError.permissionDenied {
            errorMessage = "Notification permission was denied"
        } catch {
            errorMessage = "Could not register: \(Self.describe(error))"
        }
    }

    func downNotificationLevelChanged(to level: NotificationLevel) async {
        guard case .registered(let device) = state, device.downNotificationLevel != level else { return }

        errorMessage = nil
        do {
            state = .registered(try await relay.updateDevice(id: device.id, downNotificationLevel: level))
        } catch {
            errorMessage = "Could not update setting: \(Self.describe(error))"
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

    /// Resolves the address currently selected on the onboarding form into a URL,
    /// tolerating a missing scheme (e.g. "localhost:3000") on custom addresses.
    private func resolvedRelayURL() -> URL? {
        switch relayOption {
        case .defaultRelay:
            return HTTPRelayClient.defaultRelayURL
        case .custom:
            let trimmed = customRelayAddress.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { return nil }
            if let url = URL(string: trimmed), let scheme = url.scheme, scheme.hasPrefix("http"), url.host != nil {
                return url
            }
            if let url = URL(string: "http://\(trimmed)"), url.host != nil {
                return url
            }
            return nil
        }
    }

    /// Reflects a previously-used relay URL back onto the onboarding form so
    /// it's prefilled if the user ever lands back on it.
    private func applyToForm(relayURL: URL) {
        if relayURL == HTTPRelayClient.defaultRelayURL {
            relayOption = .defaultRelay
        } else {
            relayOption = .custom
            customRelayAddress = relayURL.absoluteString
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
