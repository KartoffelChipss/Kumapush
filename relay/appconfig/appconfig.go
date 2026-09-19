package appconfig

import (
	"errors"
	"kumapush-relay/models"
	"log/slog"
	"time"

	"github.com/gofiber/fiber/v3"
)

func ErrorHandler(c fiber.Ctx, err error) error {
	code := fiber.StatusInternalServerError
	message := "internal server error"
	if fe, ok := errors.AsType[*fiber.Error](err); ok {
		code = fe.Code
		message = fe.Message
	}
	return c.Status(code).JSON(models.APIError{Error: message})
}

func Setup(app *fiber.App) {
	app.Use(func(c fiber.Ctx) error {
		c.Set("Content-Type", "application/json")
		return c.Next()
	})

	app.Use(func(c fiber.Ctx) error {
		if c.Path() == "/health" {
			return c.Next()
		}

		start := time.Now()
		err := c.Next()
		slog.Info("Request",
			"status", c.Response().StatusCode(),
			"method", c.Method(),
			"route", c.Route().Path,
			"latency", time.Since(start).String(),
			"ip", c.IP(),
		)
		return err
	})
}
