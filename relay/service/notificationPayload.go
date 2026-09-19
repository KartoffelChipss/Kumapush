package service

import (
	"kumapush-relay/models"

	"github.com/sideshow/apns2/payload"
)

func GeneratePayload(whPayload models.KumaWebhookPayload) *payload.Payload {
	status := "down"
	if whPayload.IsUp() {
		status = "up"
	}

	title := whPayload.Monitor.Name + " is " + status
	description := whPayload.Heartbeat.Msg

	return payload.NewPayload().AlertTitle(title).AlertBody(description).Sound("default")
}
