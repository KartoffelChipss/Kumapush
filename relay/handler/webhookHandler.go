package handler

import (
	"log/slog"

	"kumapush-relay/models"
	"kumapush-relay/repository"

	"github.com/gofiber/fiber/v3"
)

type WebhookHandler struct {
	deviceRepo *repository.DeviceRepository
}

func NewWebhookHandler(deviceRepo *repository.DeviceRepository) *WebhookHandler {
	return &WebhookHandler{deviceRepo: deviceRepo}
}

func (wh *WebhookHandler) RegisterRoutes(router fiber.Router) {
	router.Post("/wh/:deviceId", wh.handleWebhook)
}

func (wh *WebhookHandler) handleWebhook(c fiber.Ctx) error {
	deviceId := c.Params("deviceId")
	if deviceId == "" {
		return c.Status(fiber.StatusBadRequest).JSON(models.APIError{Error: "deviceId is required"})
	}

	_, err := wh.deviceRepo.GetById(c.Context(), deviceId)
	if err != nil {
		return c.Status(fiber.StatusNotFound).JSON(models.APIError{Error: "device not found"})
	}

	var payload models.KumaWebhookPayload
	if err := c.Bind().Body(&payload); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(models.APIError{Error: "invalid request body"})
	}

	status := "offline"
	if payload.IsUp() {
		status = "online"
	}

	slog.Info("Received Uptime Kuma webhook",
		"deviceId", deviceId,
		"monitor", payload.Monitor.Name,
		"status", status,
		"message", payload.Heartbeat.Msg,
	)

	return c.Status(fiber.StatusOK).JSON(fiber.Map{})
}
