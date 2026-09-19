package db

import (
	"context"
	"embed"
	"fmt"
	"io/fs"
	"kumapush-relay/env"
	"log/slog"
	"net/url"

	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/jackc/pgx/v5/stdlib"
	"github.com/pressly/goose/v3"
	"github.com/pressly/goose/v3/lock"
)

//go:embed migrations/*.sql
var migrationsFS embed.FS

type DB struct {
	pool *pgxpool.Pool
}

// Migrate applies all pending migrations from db/migrations. Concurrent relay instances are
// serialized with a Postgres advisory lock.
func (d *DB) Migrate(ctx context.Context) error {
	sqlDB := stdlib.OpenDBFromPool(d.pool)
	defer sqlDB.Close()

	migrations, err := fs.Sub(migrationsFS, "migrations")
	if err != nil {
		return err
	}
	locker, err := lock.NewPostgresSessionLocker()
	if err != nil {
		return fmt.Errorf("unable to create migration locker: %w", err)
	}
	provider, err := goose.NewProvider(goose.DialectPostgres, sqlDB, migrations, goose.WithSessionLocker(locker))
	if err != nil {
		return fmt.Errorf("unable to create migration provider: %w", err)
	}

	results, err := provider.Up(ctx)
	if err != nil {
		return err
	}
	for _, r := range results {
		slog.Info("Applied migration", "migration", r.Source.Path, "duration", r.Duration.String())
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
