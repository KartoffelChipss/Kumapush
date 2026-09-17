package env

import (
	"log/slog"
	"os"
	"strings"

	"github.com/gofiber/fiber/v3"
)

func IsDevelopment() bool {
	return os.Getenv("ENV") == "development"
}

func Port() string {
	port := os.Getenv("PORT")
	if port == "" {
		port = "4321"
	}
	return ":" + port
}

func AppBundleIdentifier() string {
	appBundleIdentifier := os.Getenv("APP_BUNDLE_IDENTIFIER")
	if appBundleIdentifier == "" {
		slog.Error("No APP_BUNDLE_IDENTIFIER environment variable set")
		os.Exit(1)
	}
	return appBundleIdentifier
}

func APNSAuthKeyPath() string {
	authKeyPath := os.Getenv("APNS_AUTH_KEY_PATH")
	if authKeyPath == "" {
		slog.Error("No APNS_AUTH_KEY_PATH environment variable set")
		os.Exit(1)
	}
	return authKeyPath
}

func APNSKeyID() string {
	keyID := os.Getenv("APNS_KEY_ID")
	if keyID == "" {
		slog.Error("No APNS_KEY_ID environment variable set")
		os.Exit(1)
	}
	return keyID
}

func APNSTeamID() string {
	teamID := os.Getenv("APNS_TEAM_ID")
	if teamID == "" {
		slog.Error("No APNS_TEAM_ID environment variable set")
		os.Exit(1)
	}
	return teamID
}

func DatabaseUser() string {
	return os.Getenv("DATABASE_USER")
}

func DatabasePassword() string {
	return os.Getenv("DATABASE_PASSWORD")
}

func DatabaseName() string {
	return os.Getenv("DATABASE_NAME")
}

func DatabaseHost() string {
	return os.Getenv("DATABASE_HOST")
}

func DatabasePort() string {
	return os.Getenv("DATABASE_PORT")
}

func BehindProxy() bool {
	return os.Getenv("BEHIND_PROXY") == "true"
}

func ProxyHeader() string {
	proxyHeader := os.Getenv("PROXY_HEADER")
	if proxyHeader == "" {
		return fiber.HeaderXForwardedFor
	}
	return proxyHeader
}

func TrustedProxies() []string {
	if extra := os.Getenv("TRUSTED_PROXIES"); extra != "" {
		proxies := strings.Split(extra, ",")
		for i := range proxies {
			proxies[i] = strings.TrimSpace(proxies[i])
		}
		return proxies
	}
	return []string{}
}
