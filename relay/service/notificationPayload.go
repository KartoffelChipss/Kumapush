package service

import (
	"kumapush-relay/models"
	"log/slog"

	"github.com/sideshow/apns2/payload"
)

func GeneratePayload(whPayload models.KumaWebhookPayload, downLevel models.NotificationLevel) *payload.Payload {
	if whPayload.IsTest() {
		body := whPayload.Msg
		if body == "" {
			body = "Test notification"
		}
		return payload.NewPayload().AlertTitle("KumaPush").AlertBody(body).Sound("default")
	}

	status := "down"
	if whPayload.IsUp() {
		status = "up"
	}

	title := whPayload.Monitor.Name + " is " + status
	description := whPayload.Heartbeat.Msg

	p := payload.NewPayload().AlertTitle(title).AlertBody(description).Sound("default")

	if !whPayload.IsUp() && downLevel == models.NotificationLevelTimeSensitive {
		slog.Info("Setting notification to time-sensitive")
		p.InterruptionLevel(payload.InterruptionLevelTimeSensitive)
	}

	return p
}
