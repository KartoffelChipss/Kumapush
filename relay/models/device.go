package models

type Device struct {
	Id                         string `json:"id"`
	DeviceToken                string `json:"device_token"`
	LastSuccessfulNotification string `json:"last_successful_notification"`
	DateAdded                  string `json:"date_added"`
}

type DeviceAddRequest struct {
	DeviceToken string `json:"device_token"`
}
