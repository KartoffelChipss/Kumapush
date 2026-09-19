package main

import (
	"context"
	"kumapush-relay/appconfig"
	"kumapush-relay/db"
	"kumapush-relay/env"
	"kumapush-relay/handler"
	"kumapush-relay/repository"
	"kumapush-relay/service"
	"log/slog"
	"os"

	"github.com/gofiber/fiber/v3"
)

const maxBodyBytes = 64 * 1024

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

	notificationService, err := service.NewNotificationService(env.APNSAuthKeyPath(), env.APNSKeyID(), env.APNSTeamID(), env.AppBundleIdentifier(), env.IsDevelopment())
	if err != nil {
		slog.Error("unable to create notification service", "error", err)
		os.Exit(1)
	}

	fiberCfg := fiber.Config{
		BodyLimit:    maxBodyBytes,
		ErrorHandler: appconfig.ErrorHandler,
	}
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

	deviceRepository, err := repository.NewDeviceRepository(database.Pool())
	if err != nil {
		slog.Error("unable to create device repository", "error", err)
		os.Exit(1)
	}
	deviceHandler := handler.NewDeviceHandler(deviceRepository)
	deviceHandler.RegisterRoutes(app)

	webhookHandler := handler.NewWebhookHandler(deviceRepository, notificationService)
	webhookHandler.RegisterRoutes(app)

	slog.Info("Server starting", "port", env.Port(), "fiber", fiber.Version)
	if err := app.Listen(env.Port(), fiber.ListenConfig{
		DisableStartupMessage: true,
	}); err != nil {
		slog.Error("Server failed", "error", err)
		os.Exit(1)
	}
}
