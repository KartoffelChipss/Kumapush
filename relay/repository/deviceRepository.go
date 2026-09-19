package repository

import (
	"context"
	"errors"
	"fmt"
	"time"

	"kumapush-relay/models"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgconn"
	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/jaevor/go-nanoid"
)

var ErrDeviceNotFound = errors.New("device not found")

const (
	uniqueViolationCode = "23505"
	idLength            = 14
	maxIDCollisionTries = 5
)

type DeviceRepository struct {
	pool       *pgxpool.Pool
	generateID func() string
}

func NewDeviceRepository(pool *pgxpool.Pool) (*DeviceRepository, error) {
	generateID, err := nanoid.Standard(idLength)
	if err != nil {
		return nil, fmt.Errorf("failed to create device id generator: %w", err)
	}
	return &DeviceRepository{pool: pool, generateID: generateID}, nil
}

// Register creates the device, or, if the device token is already known,
// replaces its auth token hash. created reports whether a new device was made.
func (r *DeviceRepository) Register(ctx context.Context, deviceToken, authTokenHash string) (device *models.Device, created bool, err error) {
	for attempt := 0; attempt < maxIDCollisionTries; attempt++ {
		var (
			id           string
			downLevel    string
			lastNotified *time.Time
			dateAdded    time.Time
		)
		err := r.pool.QueryRow(ctx, `
            INSERT INTO devices (id, device_token, auth_token_hash)
            VALUES ($1, $2, $3)
            ON CONFLICT (device_token) DO UPDATE SET auth_token_hash = EXCLUDED.auth_token_hash
            RETURNING id, last_successful_notification, date_added, down_notification_level, (xmax = 0)
        `, r.generateID(), deviceToken, authTokenHash).Scan(&id, &lastNotified, &dateAdded, &downLevel, &created)
		if err == nil {
			return newDevice(id, deviceToken, lastNotified, dateAdded, downLevel), created, nil
		}

		pgErr, ok := errors.AsType[*pgconn.PgError](err)
		if !ok || pgErr.Code != uniqueViolationCode || pgErr.ConstraintName != "devices_pkey" {
			return nil, false, err
		}
		// Extremely unlikely id collision: retry with a freshly generated id.
	}

	return nil, false, fmt.Errorf("failed to generate a unique device id after %d attempts", maxIDCollisionTries)
}

func (r *DeviceRepository) GetByDeviceToken(ctx context.Context, deviceToken string) (*models.Device, error) {
	return r.scanOne(ctx, `
        SELECT id, device_token, last_successful_notification, date_added, down_notification_level
        FROM devices
        WHERE device_token = $1
    `, deviceToken)
}

func (r *DeviceRepository) GetById(ctx context.Context, id string) (*models.Device, error) {
	return r.scanOne(ctx, `
        SELECT id, device_token, last_successful_notification, date_added, down_notification_level
        FROM devices
        WHERE id = $1
    `, id)
}

// GetAuthTokenHash returns the stored auth token hash
func (r *DeviceRepository) GetAuthTokenHash(ctx context.Context, id string) (string, error) {
	var hash *string
	err := r.pool.QueryRow(ctx, `SELECT auth_token_hash FROM devices WHERE id = $1`, id).Scan(&hash)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return "", ErrDeviceNotFound
		}
		return "", err
	}
	if hash == nil {
		return "", nil
	}
	return *hash, nil
}

func (r *DeviceRepository) UpdateDownNotificationLevel(ctx context.Context, id string, level models.NotificationLevel) (*models.Device, error) {
	result, err := r.pool.Exec(ctx, `
        UPDATE devices
        SET down_notification_level = $2
        WHERE id = $1
    `, id, string(level))
	if err != nil {
		return nil, err
	}
	if result.RowsAffected() == 0 {
		return nil, ErrDeviceNotFound
	}
	return r.GetById(ctx, id)
}

func (r *DeviceRepository) DeleteById(ctx context.Context, id string) error {
	result, err := r.pool.Exec(ctx, `
        DELETE FROM devices
        WHERE id = $1
    `, id)
	if err != nil {
		return err
	}
	if result.RowsAffected() == 0 {
		return ErrDeviceNotFound
	}
	return nil
}

func (r *DeviceRepository) scanOne(ctx context.Context, query string, args ...any) (*models.Device, error) {
	var (
		id, deviceToken string
		downLevel       string
		lastNotified    *time.Time
		dateAdded       time.Time
	)

	err := r.pool.QueryRow(ctx, query, args...).Scan(&id, &deviceToken, &lastNotified, &dateAdded, &downLevel)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, ErrDeviceNotFound
		}
		return nil, err
	}

	return newDevice(id, deviceToken, lastNotified, dateAdded, downLevel), nil
}

func newDevice(id, deviceToken string, lastNotified *time.Time, dateAdded time.Time, downLevel string) *models.Device {
	device := &models.Device{
		Id:                    id,
		DeviceToken:           deviceToken,
		DateAdded:             dateAdded.Format(time.RFC3339),
		DownNotificationLevel: models.NotificationLevel(downLevel),
	}
	if lastNotified != nil {
		device.LastSuccessfulNotification = lastNotified.Format(time.RFC3339)
	}
	return device
}
