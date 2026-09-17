package repository

import (
	"context"
	"errors"
	"time"

	"kumapush-relay/models"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgconn"
	"github.com/jackc/pgx/v5/pgxpool"
)

var (
	ErrDeviceNotFound    = errors.New("device not found")
	ErrDeviceTokenExists = errors.New("device token already registered")
)

const uniqueViolationCode = "23505"

type DeviceRepository struct {
	pool *pgxpool.Pool
}

func NewDeviceRepository(pool *pgxpool.Pool) *DeviceRepository {
	return &DeviceRepository{pool: pool}
}

func (r *DeviceRepository) Create(ctx context.Context, deviceToken string) (*models.Device, error) {
	id := uuid.NewString()

	var dateAdded time.Time
	err := r.pool.QueryRow(ctx, `
        INSERT INTO devices (id, device_token)
        VALUES ($1, $2)
        RETURNING date_added
    `, id, deviceToken).Scan(&dateAdded)
	if err != nil {
		if pgErr, ok := errors.AsType[*pgconn.PgError](err); ok && pgErr.Code == uniqueViolationCode {
			return nil, ErrDeviceTokenExists
		}
		return nil, err
	}

	return &models.Device{
		Id:          id,
		DeviceToken: deviceToken,
		DateAdded:   dateAdded.Format(time.RFC3339),
	}, nil
}

func (r *DeviceRepository) GetByDeviceToken(ctx context.Context, deviceToken string) (*models.Device, error) {
	return r.scanOne(ctx, `
        SELECT id, device_token, last_successful_notification, date_added
        FROM devices
        WHERE device_token = $1
    `, deviceToken)
}

func (r *DeviceRepository) GetById(ctx context.Context, id string) (*models.Device, error) {
	return r.scanOne(ctx, `
        SELECT id, device_token, last_successful_notification, date_added
        FROM devices
        WHERE id = $1
    `, id)
}

func (r *DeviceRepository) DeleteByDeviceToken(ctx context.Context, deviceToken string) error {
	result, err := r.pool.Exec(ctx, `
        DELETE FROM devices
        WHERE device_token = $1
    `, deviceToken)
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
		lastNotified    *time.Time
		dateAdded       time.Time
	)

	err := r.pool.QueryRow(ctx, query, args...).Scan(&id, &deviceToken, &lastNotified, &dateAdded)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, ErrDeviceNotFound
		}
		return nil, err
	}

	device := &models.Device{
		Id:          id,
		DeviceToken: deviceToken,
		DateAdded:   dateAdded.Format(time.RFC3339),
	}
	if lastNotified != nil {
		device.LastSuccessfulNotification = lastNotified.Format(time.RFC3339)
	}
	return device, nil
}
