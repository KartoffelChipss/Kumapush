package db

import (
	"context"
	"fmt"
	"kumapush-relay/env"
	"log/slog"
	"net/url"

	"github.com/jackc/pgx/v5/pgxpool"
)

type DB struct {
	pool *pgxpool.Pool
}

func (d *DB) Migrate(ctx context.Context) error {
	_, err := d.pool.Exec(ctx, `
        CREATE TABLE IF NOT EXISTS devices (
            id                           TEXT        PRIMARY KEY,
            device_token                 TEXT        NOT NULL,
            last_successful_notification TIMESTAMPTZ,
            date_added                   TIMESTAMPTZ NOT NULL DEFAULT now()
        );

        ALTER TABLE devices ADD COLUMN IF NOT EXISTS down_notification_level TEXT NOT NULL DEFAULT 'normal';

        CREATE UNIQUE INDEX IF NOT EXISTS devices_device_token_key ON devices (device_token);
    `)

	if err != nil {
		return err
	}

	slog.Info("Database migration completed successfully")
	return nil
}

func getDatabaseURL() string {
	u := &url.URL{
		Scheme: "postgres",
		User:   url.UserPassword(env.DatabaseUser(), env.DatabasePassword()),
		Host:   fmt.Sprintf("%s:%s", env.DatabaseHost(), env.DatabasePort()),
		Path:   env.DatabaseName(),
	}
	return u.String()
}

func New(ctx context.Context) (*DB, error) {
	pool, err := pgxpool.New(ctx, getDatabaseURL())
	if err != nil {
		return nil, fmt.Errorf("unable to connect to database: %w", err)
	}
	slog.Info("Database connection established")
	return &DB{pool: pool}, nil
}

func (d *DB) Close() {
	d.pool.Close()
}

func (d *DB) Pool() *pgxpool.Pool {
	return d.pool
}
