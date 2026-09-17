package env

import (
	"os"
	"strings"

	"github.com/gofiber/fiber/v3"
)

func Port() string {
	port := os.Getenv("PORT")
	if port == "" {
		port = "4321"
	}
	return ":" + port
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
