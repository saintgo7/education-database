-- TimescaleDB Initialization Script

-- Create extension
CREATE EXTENSION IF NOT EXISTS timescaledb CASCADE;

-- Metrics hypertable
CREATE TABLE IF NOT EXISTS metrics (
  time TIMESTAMPTZ NOT NULL,
  device_id TEXT NOT NULL,
  metric_type TEXT NOT NULL,
  value FLOAT8 NOT NULL,
  unit TEXT
);

-- Convert to hypertable
SELECT create_hypertable('metrics', 'time', if_not_exists => TRUE);

-- Add compression
ALTER TABLE metrics SET (
  timescaledb.compress,
  timescaledb.compress_orderby = 'time DESC, device_id'
);

-- Create continuous aggregate
CREATE MATERIALIZED VIEW IF NOT EXISTS metrics_5min_aggregate
WITH (timescaledb.continuous) AS
SELECT
  time_bucket('5 minutes', time) AS bucket,
  device_id,
  metric_type,
  AVG(value) AS avg_value,
  MAX(value) AS max_value,
  MIN(value) AS min_value
FROM metrics
GROUP BY bucket, device_id, metric_type;

-- Create indexes
CREATE INDEX IF NOT EXISTS metrics_device_time_idx ON metrics (device_id, time DESC);
CREATE INDEX IF NOT EXISTS metrics_type_time_idx ON metrics (metric_type, time DESC);

-- Set retention policy (30 days)
SELECT add_retention_policy('metrics', INTERVAL '30 days', if_not_exists => TRUE);

-- Insert sample data
INSERT INTO metrics (time, device_id, metric_type, value, unit)
VALUES
  (NOW() - INTERVAL '1 hour', 'device_001', 'temperature', 22.5, 'celsius'),
  (NOW() - INTERVAL '2 hours', 'device_001', 'temperature', 23.0, 'celsius'),
  (NOW() - INTERVAL '1 hour', 'device_002', 'humidity', 65.5, 'percent'),
  (NOW() - INTERVAL '2 hours', 'device_002', 'humidity', 64.0, 'percent');

-- Refresh continuous aggregate
CALL refresh_continuous_aggregate('metrics_5min_aggregate', NULL, NULL);
