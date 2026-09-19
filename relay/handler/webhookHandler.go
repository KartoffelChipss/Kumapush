package handler

import (
	"errors"
	"kumapush-relay/service"
	"log/slog"

	"kumapush-relay/models"
	"kumapush-relay/repository"

	"github.com/gofiber/fiber/v3"
	"github.com/sideshow/apns2"
)

type WebhookHandler struct {
	deviceRepo          *repository.DeviceRepository
	notificationService *service.NotificationService
}

func NewWebhookHandler(deviceRepo *repository.DeviceRepository, notificationService *service.NotificationService) *WebhookHandler {
	return &WebhookHandler{deviceRepo: deviceRepo, notificationService: notificationService}
}

func (wh *WebhookHandler) RegisterRoutes(router fiber.Router) {
	limits := webhookRateLimiters()
	router.Post("/wh/:deviceId", limits[0], limits[1], wh.handleWebhook)
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

	res, err := wh.notificationService.SendNotification(device.DeviceToken, service.GeneratePayload(whPayload, device.DownNotificationLevel))
	if err != nil {
		slog.Error("Failed to send notification", "error", err)
		return c.Status(fiber.StatusInternalServerError).JSON(models.APIError{Error: "failed to send notification"})
	}
	if !res.Sent() {
		if isDeviceTokenInvalid(res) {
			slog.Info("Removing device with invalid APNs token", "deviceId", deviceId, "statusCode", res.StatusCode, "reason", res.Reason)
			if err := wh.deviceRepo.DeleteById(c.Context(), deviceId); err != nil && !errors.Is(err, repository.ErrDeviceNotFound) {
				slog.Error("Failed to remove device", "deviceId", deviceId, "error", err)
			}
			return c.Status(fiber.StatusGone).JSON(models.APIError{Error: "device is no longer registered"})
		}
		slog.Error("APNs rejected notification", "deviceId", deviceId, "statusCode", res.StatusCode, "reason", res.Reason)
		return c.Status(fiber.StatusBadGateway).JSON(models.APIError{Error: "notification rejected by APNs"})
	}

	if err := wh.deviceRepo.MarkNotificationSent(c.Context(), deviceId); err != nil {
		slog.Warn("Failed to record last successful notification", "deviceId", deviceId, "error", err)
	}

	return c.Status(fiber.StatusOK).JSON(fiber.Map{})
}

// isDeviceTokenInvalid reports whether APNs says the token will never work again
func isDeviceTokenInvalid(res *apns2.Response) bool {
	return res.Reason == apns2.ReasonUnregistered || res.Reason == apns2.ReasonBadDeviceToken
}
