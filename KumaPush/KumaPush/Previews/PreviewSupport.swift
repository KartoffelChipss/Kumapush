import Foundation

#if DEBUG
/// Fake dependencies used only by SwiftUI previews.

final class PreviewRelayClient: RelayClient {
    var baseURL = HTTPRelayClient.defaultRelayURL
    func registerDevice(token: String) async throws -> DeviceRegistration {
        DeviceRegistration(
            device: Device(id: "preview-device-id", deviceToken: token, lastSuccessfulNotification: "", dateAdded: ""),
            authToken: "preview-auth-token"
        )
    }
    func getDevice(byId id: String, authToken: String) async throws -> Device {
        throw RelayError.notFound
    }
    func updateDevice(id: String, authToken: String, downNotificationLevel: NotificationLevel) async throws -> Device {
        Device(id: id, deviceToken: "preview-token", lastSuccessfulNotification: "", dateAdded: "", downNotificationLevel: downNotificationLevel)
    }
    func updateDevice(id: String, authToken: String, deviceToken: String) async throws -> Device {
        Device(id: id, deviceToken: deviceToken, lastSuccessfulNotification: "", dateAdded: "")
    }
    func unregisterDevice(id: String, authToken: String) async throws {}
}

final class PreviewPushRegistrar: PushRegistrar {
    func requestAuthorizationAndRegister() async throws -> String { "preview-token" }
}

final class PreviewDeviceStore: DeviceStore {
    var deviceId: String?
    var authToken: String?
    var relayBaseURL: URL?
}
#endif
