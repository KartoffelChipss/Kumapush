package appconfig

import (
	"bytes"
	"log/slog"
	"net/http/httptest"
	"strings"
	"testing"

	"github.com/gofiber/fiber/v3"
)

func TestRequestLogOmitsDeviceIds(t *testing.T) {
	var buf bytes.Buffer
	prev := slog.Default()
	slog.SetDefault(slog.New(slog.NewTextHandler(&buf, nil)))
	defer slog.SetDefault(prev)

	app := fiber.New()
	Setup(app)
	app.Post("/wh/:deviceId", func(c fiber.Ctx) error { return c.SendStatus(fiber.StatusOK) })
	app.Get("/devices/:id", func(c fiber.Ctx) error { return c.SendStatus(fiber.StatusOK) })

	for _, path := range []string{"/wh/SECRETWEBHOOKID", "/devices/SECRETDEVICEID", "/unknown/SECRETOTHERID"} {
		method := "GET"
		if strings.HasPrefix(path, "/wh/") {
			method = "POST"
		}
		if _, err := app.Test(httptest.NewRequest(method, path, nil)); err != nil {
			t.Fatal(err)
		}
	}

	out := buf.String()
	t.Log("\n" + out)
	if strings.Contains(out, "SECRET") {
		t.Fatalf("log contains an id:\n%s", out)
	}
}
