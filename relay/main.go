package main

import (
	"context"
	"kumapush-relay/appconfig"
	"kumapush-relay/db"
	"kumapush-relay/env"
	"kumapush-relay/handler"
	"kumapush-relay/repository"
	"log/slog"
	"os"

	"github.com/gofiber/fiber/v3"
)

func main() {
	ctx := context.Background()

	database, err := db.New(ctx)
	if err != nil {
		slog.Error("unable to connect to database", "error", err)
		os.Exit(1)
	}
	defer database.Close()

	if err := database.Migrate(ctx); err != nil {
		slog.Error("migration failed", "error", err)
		os.Exit(1)
	}

	fiberCfg := fiber.Config{}
	if env.BehindProxy() {
		fiberCfg.ProxyHeader = env.ProxyHeader()
		fiberCfg.TrustProxy = true

		proxies := []string{"127.0.0.1", "::1"}

		proxies = append(proxies, env.TrustedProxies()...)

		fiberCfg.TrustProxyConfig = fiber.TrustProxyConfig{
			Proxies: proxies,
		}
	}

	app := fiber.New(fiberCfg)
	appconfig.Setup(app)

	deviceRepository := repository.NewDeviceRepository(database.Pool())
	deviceHandler := handler.NewDeviceHandler(deviceRepository)
	deviceHandler.RegisterRoutes(app)

	webhookHandler := handler.NewWebhookHandler(deviceRepository)
	webhookHandler.RegisterRoutes(app)

	slog.Info("Server starting", "port", env.Port(), "fiber", fiber.Version)
	if err := app.Listen(env.Port(), fiber.ListenConfig{
		DisableStartupMessage: true,
	}); err != nil {
		slog.Error("Server failed", "error", err)
		os.Exit(1)
	}
}
