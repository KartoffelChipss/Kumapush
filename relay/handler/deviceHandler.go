package handler

import (
	"errors"

	"kumapush-relay/models"
	"kumapush-relay/repository"
	"kumapush-relay/service"

	"github.com/gofiber/fiber/v3"
)

type DeviceHandler struct {
	repo *repository.DeviceRepository
}

func NewDeviceHandler(repo *repository.DeviceRepository) *DeviceHandler {
	return &DeviceHandler{repo: repo}
}

func (h *DeviceHandler) RegisterRoutes(router fiber.Router) {
	router.Post("/devices", h.register)
	router.Get("/devices/token/:token", h.getByDeviceToken)
	router.Get("/devices/:id", h.getById)
	router.Patch("/devices/:id", h.update)
	router.Delete("/devices/:id", h.delete)
}

func (h *DeviceHandler) register(c fiber.Ctx) error {
	var req models.DeviceAddRequest
	if err := c.Bind().Body(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(models.APIError{Error: "invalid request body"})
	}

	if !service.IsValidAppleDeviceToken(req.DeviceToken) {
		return c.Status(fiber.StatusBadRequest).JSON(models.APIError{Error: "invalid device token"})
	}

	device, err := h.repo.Create(c.Context(), req.DeviceToken)
	if err != nil {
		if errors.Is(err, repository.ErrDeviceTokenExists) {
			return c.Status(fiber.StatusConflict).JSON(models.APIError{Error: "device token already registered"})
		}
		return c.Status(fiber.StatusInternalServerError).JSON(models.APIError{Error: "unable to register device"})
	}

	return c.Status(fiber.StatusCreated).JSON(device)
}

func (h *DeviceHandler) update(c fiber.Ctx) error {
	var req models.DeviceUpdateRequest
	if err := c.Bind().Body(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(models.APIError{Error: "invalid request body"})
	}

	if !req.DownNotificationLevel.IsValid() {
		return c.Status(fiber.StatusBadRequest).JSON(models.APIError{Error: "invalid down_notification_level"})
	}

	device, err := h.repo.UpdateDownNotificationLevel(c.Context(), c.Params("id"), req.DownNotificationLevel)
	if err != nil {
		return respondDeviceError(c, err)
	}
	return c.JSON(device)
}

func (h *DeviceHandler) getByDeviceToken(c fiber.Ctx) error {
	device, err := h.repo.GetByDeviceToken(c.Context(), c.Params("token"))
	if err != nil {
		return respondDeviceError(c, err)
	}
	return c.JSON(device)
}

func (h *DeviceHandler) getById(c fiber.Ctx) error {
	device, err := h.repo.GetById(c.Context(), c.Params("id"))
	if err != nil {
		return respondDeviceError(c, err)
	}
	return c.JSON(device)
}

func (h *DeviceHandler) delete(c fiber.Ctx) error {
	if err := h.repo.DeleteById(c.Context(), c.Params("id")); err != nil {
		return respondDeviceError(c, err)
	}
	return c.SendStatus(fiber.StatusNoContent)
}

func respondDeviceError(c fiber.Ctx, err error) error {
	if errors.Is(err, repository.ErrDeviceNotFound) {
		return c.Status(fiber.StatusNotFound).JSON(models.APIError{Error: "device not found"})
	}
	return c.Status(fiber.StatusInternalServerError).JSON(models.APIError{Error: "unable to process device request"})
}
