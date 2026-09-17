import UIKit
import UserNotifications

enum PushError: Error {
    case permissionDenied
}

protocol PushRegistrar {
    /// Requests notification authorization and, if granted, registers for a
    /// remote-notification device token. Returns the token as a hex string.
    func requestAuthorizationAndRegister() async throws -> String
}

/// Bridges the delegate-based APNs registration callbacks (which AppDelegate
/// receives) to a single async call the rest of the app can use.
final class APNsPushRegistrar: PushRegistrar {
    static let shared = APNsPushRegistrar()

    private var continuation: CheckedContinuation<String, Error>?

    func requestAuthorizationAndRegister() async throws -> String {
        let granted = try await UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge])
        guard granted else {
            throw PushError.permissionDenied
        }

        return try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }

    func didRegister(deviceToken: Data) {
        let tokenString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        continuation?.resume(returning: tokenString)
        continuation = nil
    }

    func didFailToRegister(error: Error) {
        continuation?.resume(throwing: error)
        continuation = nil
    }
}
