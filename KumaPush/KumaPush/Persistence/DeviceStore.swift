import Foundation

protocol DeviceStore {
    var deviceId: String? { get set }
    var relayBaseURL: URL? { get set }
}

final class UserDefaultsDeviceStore: DeviceStore {
    private let defaults: UserDefaults
    private let deviceIdKey = "com.kumapush.deviceId"
    private let relayBaseURLKey = "com.kumapush.relayBaseURL"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    var deviceId: String? {
        get { defaults.string(forKey: deviceIdKey) }
        set { defaults.set(newValue, forKey: deviceIdKey) }
    }

    var relayBaseURL: URL? {
        get { defaults.string(forKey: relayBaseURLKey).flatMap(URL.init(string:)) }
        set { defaults.set(newValue?.absoluteString, forKey: relayBaseURLKey) }
    }
}
