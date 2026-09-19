import Foundation
import Security

protocol DeviceStore {
    var deviceId: String? { get set }
    /// Secret credential for the relay; kept in the Keychain rather than UserDefaults.
    var authToken: String? { get set }
    var relayBaseURL: URL? { get set }
}

final class UserDefaultsDeviceStore: DeviceStore {
    private let defaults: UserDefaults
    private let deviceIdKey = "com.kumapush.deviceId"
    private let relayBaseURLKey = "com.kumapush.relayBaseURL"
    private let authTokenAccount = "com.kumapush.authToken"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    var deviceId: String? {
        get { defaults.string(forKey: deviceIdKey) }
        set { defaults.set(newValue, forKey: deviceIdKey) }
    }

    var authToken: String? {
        get { Keychain.read(account: authTokenAccount) }
        set { Keychain.write(newValue, account: authTokenAccount) }
    }

    var relayBaseURL: URL? {
        get { defaults.string(forKey: relayBaseURLKey).flatMap(URL.init(string:)) }
        set { defaults.set(newValue?.absoluteString, forKey: relayBaseURLKey) }
    }
}

private enum Keychain {
    private static let service = "com.kumapush"

    private static func query(account: String) -> [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
        ]
    }

    static func read(account: String) -> String? {
        var query = query(account: account)
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne

        var result: AnyObject?
        guard SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess,
              let data = result as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    static func write(_ value: String?, account: String) {
        SecItemDelete(query(account: account) as CFDictionary)
        guard let value else { return }

        var item = query(account: account)
        item[kSecValueData as String] = Data(value.utf8)
        item[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        SecItemAdd(item as CFDictionary, nil)
    }
}
