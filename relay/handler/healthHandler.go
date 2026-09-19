package handler

import (
	"context"
	"log/slog"
	"time"

	"kumapush-relay/models"

	"github.com/gofiber/fiber/v3"
	"github.com/jackc/pgx/v5/pgxpool"
)

const healthCheckTimeout = 2 * time.Second

type HealthHandler struct {
	pool *pgxpool.Pool
}

func NewHealthHandler(pool *pgxpool.Pool) *HealthHandler {
	return &HealthHandler{pool: pool}
}

func (h *HealthHandler) RegisterRoutes(router fiber.Router) {
	router.Get("/health", h.health)
}

// health reports whether the relay can serve requests, i.e. the database is reachable.
func (h *HealthHandler) health(c fiber.Ctx) error {
	ctx, cancel := context.WithTimeout(c.Context(), healthCheckTimeout)
	defer cancel()

	if err := h.pool.Ping(ctx); err != nil {
		slog.Error("Health check failed", "error", err)
		return c.Status(fiber.StatusServiceUnavailable).JSON(models.APIError{Error: "database unavailable"})
	}
	return c.JSON(fiber.Map{"status": "ok"})
}
