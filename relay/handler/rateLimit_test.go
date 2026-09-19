package handler

import (
	"net/http/httptest"
	"testing"

	"github.com/gofiber/fiber/v3"
)

func status(t *testing.T, app *fiber.App, method, path string) int {
	t.Helper()
	resp, err := app.Test(httptest.NewRequest(method, path, nil))
	if err != nil {
		t.Fatal(err)
	}
	return resp.StatusCode
}

// The stub handler answers 404 for device "missing" and 200 otherwise.
func webhookApp() *fiber.App {
	app := fiber.New()
	limits := webhookRateLimiters()
	app.Post("/wh/:deviceId", limits[0], limits[1], func(c fiber.Ctx) error {
		if c.Params("deviceId") == "missing" {
			return c.SendStatus(fiber.StatusNotFound)
		}
		return c.SendStatus(fiber.StatusOK)
	})
	return app
}

func TestWebhookLimitsPerDevice(t *testing.T) {
	app := webhookApp()
	for i := 0; i < webhookPerDevicePerMinute; i++ {
		if got := status(t, app, "POST", "/wh/a"); got != fiber.StatusOK {
			t.Fatalf("request %d: got %d, want 200", i+1, got)
		}
	}
	if got := status(t, app, "POST", "/wh/a"); got != fiber.StatusTooManyRequests {
		t.Fatalf("over the limit: got %d, want 429", got)
	}
	if got := status(t, app, "POST", "/wh/b"); got != fiber.StatusOK {
		t.Fatalf("other device should be unaffected: got %d, want 200", got)
	}
}

func TestWebhookFailuresLimitedPerIP(t *testing.T) {
	app := webhookApp()
	for i := 0; i < webhookFailuresPerIPPerMinute; i++ {
		if got := status(t, app, "POST", "/wh/missing"); got != fiber.StatusNotFound {
			t.Fatalf("request %d: got %d, want 404", i+1, got)
		}
	}
	// Once the failure budget is spent the IP is blocked, even for valid devices.
	if got := status(t, app, "POST", "/wh/missing"); got != fiber.StatusTooManyRequests {
		t.Fatalf("over the limit: got %d, want 429", got)
	}
	if got := status(t, app, "POST", "/wh/a"); got != fiber.StatusTooManyRequests {
		t.Fatalf("blocked IP: got %d, want 429", got)
	}
}

func TestRegisterLimitedPerIP(t *testing.T) {
	app := fiber.New()
	limits := registerRateLimiters()
	app.Post("/devices", limits[0], limits[1], func(c fiber.Ctx) error { return c.SendStatus(fiber.StatusCreated) })

	for i := 0; i < registerPerMinute; i++ {
		if got := status(t, app, "POST", "/devices"); got != fiber.StatusCreated {
			t.Fatalf("request %d: got %d, want 201", i+1, got)
		}
	}
	if got := status(t, app, "POST", "/devices"); got != fiber.StatusTooManyRequests {
		t.Fatalf("over the limit: got %d, want 429", got)
	}
}
