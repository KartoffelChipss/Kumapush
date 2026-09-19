package handler

import (
	"errors"
	"strings"

	"kumapush-relay/models"
	"kumapush-relay/repository"
	"kumapush-relay/service"

	"github.com/gofiber/fiber/v3"
)

const bearerPrefix = "bearer "

// requireDeviceAuth ensures the request carries the auth token of the device
// named by the :id route parameter. A missing device and a wrong token are
// indistinguishable to the caller.
func requireDeviceAuth(repo *repository.DeviceRepository) fiber.Handler {
	return func(c fiber.Ctx) error {
		header := c.Get(fiber.HeaderAuthorization)
		if len(header) <= len(bearerPrefix) || !strings.EqualFold(header[:len(bearerPrefix)], bearerPrefix) {
			return unauthorized(c)
		}
		token := strings.TrimSpace(header[len(bearerPrefix):])

		storedHash, err := repo.GetAuthTokenHash(c.Context(), c.Params("id"))
		if err != nil {
			if errors.Is(err, repository.ErrDeviceNotFound) {
				return unauthorized(c)
			}
			return c.Status(fiber.StatusInternalServerError).JSON(models.APIError{Error: "unable to process device request"})
		}

		if !service.AuthTokenMatches(token, storedHash) {
			return unauthorized(c)
		}
		return c.Next()
	}
}

func unauthorized(c fiber.Ctx) error {
	return c.Status(fiber.StatusUnauthorized).JSON(models.APIError{Error: "unauthorized"})
}
