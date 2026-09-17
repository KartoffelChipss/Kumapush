package handler

import (
	"kumapush-relay/service"
	"log/slog"

	"kumapush-relay/models"
	"kumapush-relay/repository"

	"github.com/gofiber/fiber/v3"
)

type WebhookHandler struct {
	deviceRepo          *repository.DeviceRepository
	notificationService *service.NotificationService
}

func NewWebhookHandler(deviceRepo *repository.DeviceRepository, notificationService *service.NotificationService) *WebhookHandler {
	return &WebhookHandler{deviceRepo: deviceRepo, notificationService: notificationService}
}

func (wh *WebhookHandler) RegisterRoutes(router fiber.Router) {
	router.Post("/wh/:deviceId", wh.handleWebhook)
}

func (wh *WebhookHandler) handleWebhook(c fiber.Ctx) error {
	deviceId := c.Params("deviceId")
	if deviceId == "" {
		return c.Status(fiber.StatusBadRequest).JSON(models.APIError{Error: "deviceId is required"})
	}

	device, err := wh.deviceRepo.GetById(c.Context(), deviceId)
	if err != nil {
		return c.Status(fiber.StatusNotFound).JSON(models.APIError{Error: "device not found"})
	}

	var whPayload models.KumaWebhookPayload
	if err := c.Bind().Body(&whPayload); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(models.APIError{Error: "invalid request body"})
	}

	res, err := wh.notificationService.SendNotification(device.DeviceToken, service.GeneratePayload(whPayload))
	if err != nil {
		slog.Error("Failed to send notification", "error", err)
		return c.Status(fiber.StatusInternalServerError).JSON(models.APIError{Error: "failed to send notification"})
	}
	if !res.Sent() {
		slog.Error("APNs rejected notification", "deviceId", deviceId, "statusCode", res.StatusCode, "reason", res.Reason)
		return c.Status(fiber.StatusBadGateway).JSON(models.APIError{Error: "notification rejected by APNs"})
	}

	return c.Status(fiber.StatusOK).JSON(fiber.Map{})
}
