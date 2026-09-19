import Foundation

enum NotificationLevel: String, Codable, CaseIterable, Identifiable {
    case normal
    case timeSensitive = "time-sensitive"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .normal: "Normal"
        case .timeSensitive: "Time Sensitive"
        }
    }

    var detail: String {
        switch self {
        case .normal: "Delivered like any other notification."
        case .timeSensitive: "Breaks through Focus and Do Not Disturb, but not the silent switch."
        }
    }
}

struct Device: Codable, Equatable {
    let id: String
    let deviceToken: String
    let lastSuccessfulNotification: String
    let dateAdded: String
    let downNotificationLevel: NotificationLevel

    enum CodingKeys: String, CodingKey {
        case id
        case deviceToken = "device_token"
        case lastSuccessfulNotification = "last_successful_notification"
        case dateAdded = "date_added"
        case downNotificationLevel = "down_notification_level"
    }

    init(
        id: String,
        deviceToken: String,
        lastSuccessfulNotification: String,
        dateAdded: String,
        downNotificationLevel: NotificationLevel = .normal
    ) {
        self.id = id
        self.deviceToken = deviceToken
        self.lastSuccessfulNotification = lastSuccessfulNotification
        self.dateAdded = dateAdded
        self.downNotificationLevel = downNotificationLevel
    }

    // Older relays don't return the level; fall back to normal.
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        deviceToken = try container.decode(String.self, forKey: .deviceToken)
        lastSuccessfulNotification = try container.decode(String.self, forKey: .lastSuccessfulNotification)
        dateAdded = try container.decode(String.self, forKey: .dateAdded)
        downNotificationLevel = try container.decodeIfPresent(NotificationLevel.self, forKey: .downNotificationLevel) ?? .normal
    }
}

struct RelayAPIError: Codable, Error {
    let error: String
}
