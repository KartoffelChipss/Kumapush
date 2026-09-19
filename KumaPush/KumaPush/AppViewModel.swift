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
    @Published var pendingInsecureRelayURL: URL?

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

        guard let id = store.deviceId, let authToken = store.authToken, let url = store.relayBaseURL else {
            clearRegistration()
            return
        }

        relay.baseURL = url
        do {
            let device = try await relay.getDevice(byId: id, authToken: authToken)
            state = .registered(device)
            await syncDeviceToken(of: device, authToken: authToken)
        } catch {
            clearRegistration()
        }
    }

    /// APNs can hand out a new token (restore, reinstall, OS update). If it differs from what the relay has, push the new one
    private func syncDeviceToken(of device: Device, authToken: String) async {
        guard let currentToken = try? await pushRegistrar.requestAuthorizationAndRegister(),
              currentToken != device.deviceToken,
              let updated = try? await relay.updateDevice(id: device.id, authToken: authToken, deviceToken: currentToken)
        else { return }
        state = .registered(updated)
    }

    func getStartedTapped(allowInsecure: Bool = false) async {
        errorMessage = nil

        guard let relayURL = resolvedRelayURL() else {
            errorMessage = "Enter a valid relay address"
            return
        }

        if relayURL.scheme?.lowercased() == "http", !allowInsecure {
            pendingInsecureRelayURL = relayURL
            return
        }

        isRegistering = true
        defer { isRegistering = false }

        relay.baseURL = relayURL
        do {
            let token = try await pushRegistrar.requestAuthorizationAndRegister()
            let registration = try await relay.registerDevice(token: token)
            store.deviceId = registration.device.id
            store.authToken = registration.authToken
            store.relayBaseURL = relayURL
            state = .registered(registration.device)
        } catch PushError.permissionDenied {
            errorMessage = "Notification permission was denied"
        } catch {
            errorMessage = "Could not register: \(Self.describe(error))"
        }
    }

    func downNotificationLevelChanged(to level: NotificationLevel) async {
        guard case .registered(let device) = state, device.downNotificationLevel != level else { return }
        guard let authToken = store.authToken else {
            errorMessage = "Could not update setting: \(Self.describe(RelayError.unauthorized))"
            return
        }

        errorMessage = nil
        do {
            state = .registered(try await relay.updateDevice(id: device.id, authToken: authToken, downNotificationLevel: level))
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
            try await relay.unregisterDevice(id: device.id, authToken: store.authToken ?? "")
            clearRegistration()
        } catch RelayError.notFound, RelayError.unauthorized {
            // local state is stale.
            clearRegistration()
        } catch {
            errorMessage = "Could not unregister: \(Self.describe(error))"
        }
    }

    private func clearRegistration() {
        store.deviceId = nil
        store.authToken = nil
        state = .needsRegistration
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
        case RelayError.unauthorized:
            return "not authorized"
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
