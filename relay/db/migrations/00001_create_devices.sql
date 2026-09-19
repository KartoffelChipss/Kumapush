-- +goose Up
CREATE TABLE devices (
    id                           TEXT        PRIMARY KEY,
    device_token                 TEXT        NOT NULL,
    auth_token_hash              TEXT,
    last_successful_notification TIMESTAMPTZ,
    date_added                   TIMESTAMPTZ NOT NULL DEFAULT now(),
    down_notification_level      TEXT        NOT NULL DEFAULT 'normal'
);

CREATE UNIQUE INDEX devices_device_token_key ON devices (device_token);

-- +goose Down
DROP TABLE devices;
