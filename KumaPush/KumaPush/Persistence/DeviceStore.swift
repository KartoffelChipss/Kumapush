import Foundation

protocol DeviceStore {
    var deviceId: String? { get set }
}

final class UserDefaultsDeviceStore: DeviceStore {
    private let defaults: UserDefaults
    private let key = "com.kumapush.deviceId"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    var deviceId: String? {
        get { defaults.string(forKey: key) }
        set { defaults.set(newValue, forKey: key) }
    }
}
