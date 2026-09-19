package models

type NotificationLevel string

const (
	NotificationLevelNormal        NotificationLevel = "normal"
	NotificationLevelTimeSensitive NotificationLevel = "time-sensitive"
)

func (l NotificationLevel) IsValid() bool {
	switch l {
	case NotificationLevelNormal, NotificationLevelTimeSensitive:
		return true
	}
	return false
}

type Device struct {
	Id                         string            `json:"id"`
	DeviceToken                string            `json:"device_token"`
	LastSuccessfulNotification string            `json:"last_successful_notification"`
	DateAdded                  string            `json:"date_added"`
	DownNotificationLevel      NotificationLevel `json:"down_notification_level"`
}

type DeviceRegistration struct {
	Device
	AuthToken string `json:"auth_token"`
}

type DeviceAddRequest struct {
	DeviceToken string `json:"device_token"`
}

type DeviceUpdateRequest struct {
	DeviceToken           *string            `json:"device_token"`
	DownNotificationLevel *NotificationLevel `json:"down_notification_level"`
}
