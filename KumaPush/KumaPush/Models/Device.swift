import Foundation

struct Device: Codable, Equatable {
    let id: String
    let deviceToken: String
    let lastSuccessfulNotification: String
    let dateAdded: String

    enum CodingKeys: String, CodingKey {
        case id
        case deviceToken = "device_token"
        case lastSuccessfulNotification = "last_successful_notification"
        case dateAdded = "date_added"
    }
}

struct RelayAPIError: Codable, Error {
    let error: String
}
