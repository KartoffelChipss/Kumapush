package service

import (
	"fmt"
	"log/slog"

	"github.com/sideshow/apns2"
	"github.com/sideshow/apns2/payload"
	"github.com/sideshow/apns2/token"
)

type NotificationService struct {
	client              *apns2.Client
	appBundleIdentifier string
}

func NewNotificationService(authKeyPath, keyID, teamID, appBundleIdentifier string, isDevelopment bool) (*NotificationService, error) {
	authKey, err := token.AuthKeyFromFile(authKeyPath)
	if err != nil {
		return nil, fmt.Errorf("failed to load APNs auth key: %w", err)
	}

	tok := &token.Token{
		AuthKey: authKey,
		KeyID:   keyID,
		TeamID:  teamID,
	}

	client := apns2.NewTokenClient(tok)
	if isDevelopment {
		client = client.Development()
	} else {
		client = client.Production()
	}
	slog.Info("APNs client initialized", "environment", func() string {
		if isDevelopment {
			return "development"
		}
		return "production"
	}())
	return &NotificationService{client: client, appBundleIdentifier: appBundleIdentifier}, nil
}

func (s *NotificationService) SendNotification(deviceToken string, notificationPayload *payload.Payload) (*apns2.Response, error) {
	notification := &apns2.Notification{
		DeviceToken: deviceToken,
		Topic:       s.appBundleIdentifier,
		Payload:     notificationPayload,
	}

	response, err := s.client.Push(notification)
	if err != nil {
		return nil, fmt.Errorf("failed to send notification: %w", err)
	}

	return response, nil
}
