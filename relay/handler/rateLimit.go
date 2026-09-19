package handler

import (
	"time"

	"kumapush-relay/models"

	"github.com/gofiber/fiber/v3"
	"github.com/gofiber/fiber/v3/middleware/limiter"
)

const (
	registerPerMinute = 5
	registerPerHour   = 30

	webhookPerDevicePerMinute = 60

	webhookFailuresPerIPPerMinute = 10
)

func tooManyRequests(c fiber.Ctx) error {
	return c.Status(fiber.StatusTooManyRequests).JSON(models.APIError{Error: "too many requests"})
}

func newLimiter(max int, window time.Duration, key func(fiber.Ctx) string, skipSuccessful bool) fiber.Handler {
	return limiter.New(limiter.Config{
		Max:                    max,
		Expiration:             window,
		KeyGenerator:           key,
		LimitReached:           tooManyRequests,
		SkipSuccessfulRequests: skipSuccessful,
		LimiterMiddleware:      limiter.SlidingWindow{},
	})
}

func byIP(c fiber.Ctx) string { return c.IP() }

func byIPAndDevice(c fiber.Ctx) string { return c.IP() + "|" + c.Params("deviceId") }

// registerRateLimiters limits registrations per client IP.
func registerRateLimiters() []fiber.Handler {
	return []fiber.Handler{
		newLimiter(registerPerMinute, time.Minute, byIP, false),
		newLimiter(registerPerHour, time.Hour, byIP, false),
	}
}

// webhookRateLimiters returns the per-IP failure limiter followed by the per-(IP, device) limiter.
func webhookRateLimiters() []fiber.Handler {
	return []fiber.Handler{
		newLimiter(webhookFailuresPerIPPerMinute, time.Minute, byIP, true),
		newLimiter(webhookPerDevicePerMinute, time.Minute, byIPAndDevice, false),
	}
}
