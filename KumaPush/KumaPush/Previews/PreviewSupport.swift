import Foundation

#if DEBUG
/// Fake dependencies used only by SwiftUI previews.

final class PreviewRelayClient: RelayClient {
    var baseURL = HTTPRelayClient.defaultRelayURL
    func registerDevice(token: String) async throws -> Device {
        Device(id: "preview-device-id", deviceToken: token, lastSuccessfulNotification: "", dateAdded: "")
    }
    func getDevice(byToken token: String) async throws -> Device {
        throw RelayError.notFound
    }
    func getDevice(byId id: String) async throws -> Device {
        throw RelayError.notFound
    }
    func unregisterDevice(token: String) async throws {}
}

final class PreviewPushRegistrar: PushRegistrar {
    func requestAuthorizationAndRegister() async throws -> String { "preview-token" }
}

final class PreviewDeviceStore: DeviceStore {
    var deviceId: String?
    var relayBaseURL: URL?
}
#endif
