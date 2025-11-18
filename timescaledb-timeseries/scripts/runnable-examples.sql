-- TimescaleDB 50 Runnable Examples
-- Run with: psql -U postgres -d timeseries_db -f runnable-examples.sql

CREATE EXTENSION IF NOT EXISTS timescaledb;

-- Create hypertable
CREATE TABLE IF NOT EXISTS metrics (
  time TIMESTAMPTZ NOT NULL,
  device_id TEXT NOT NULL,
  metric_type TEXT NOT NULL,
  value FLOAT8 NOT NULL
);

SELECT create_hypertable('metrics', 'time', if_not_exists => TRUE);

-- Insert sample data
INSERT INTO metrics (time, device_id, metric_type, value) VALUES
(NOW() - INTERVAL '1 hour', 'device_001', 'temperature', 22.5),
(NOW() - INTERVAL '2 hours', 'device_001', 'temperature', 23.0),
(NOW() - INTERVAL '1 hour', 'device_002', 'humidity', 65.5),
(NOW() - INTERVAL '2 hours', 'device_002', 'humidity', 64.0),
(NOW() - INTERVAL '3 hours', 'device_001', 'temperature', 21.5);

-- Example 1-5: Basic queries
SELECT * FROM metrics LIMIT 5;
SELECT DISTINCT device_id FROM metrics;
SELECT COUNT(*) as total FROM metrics;
SELECT AVG(value) as avg_value FROM metrics;

-- Example 6-10: Time-based queries
SELECT * FROM metrics WHERE time > NOW() - INTERVAL '1 day';
SELECT * FROM metrics WHERE device_id = 'device_001';
SELECT device_id, AVG(value) FROM metrics GROUP BY device_id;

-- Example 11-15: Time bucketing
SELECT time_bucket('1 hour', time) as bucket, AVG(value) as avg_value
FROM metrics GROUP BY bucket ORDER BY bucket DESC;

SELECT time_bucket('1 day', time) as day, COUNT(*) as data_points
FROM metrics GROUP BY day;

-- Example 16-20: Continuous aggregates
CREATE MATERIALIZED VIEW metrics_hourly WITH (timescaledb.continuous) AS
SELECT time_bucket('1 hour', time) as bucket, device_id, AVG(value) as avg_value
FROM metrics GROUP BY bucket, device_id;

-- Example 21-25: Compression
ALTER TABLE metrics SET (timescaledb.compress, timescaledb.compress_orderby = 'time DESC');

-- Example 26-30: Data retrieval
SELECT * FROM metrics ORDER BY time DESC LIMIT 10;
SELECT time, value FROM metrics WHERE metric_type = 'temperature';

-- Example 31-35: Window functions
SELECT time, value, AVG(value) OVER (ORDER BY time ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) as moving_avg
FROM metrics;

-- Example 36-40: Aggregation
SELECT time_bucket('1 hour', time), COUNT(DISTINCT device_id) as active_devices
FROM metrics GROUP BY time_bucket('1 hour', time);

-- Example 41-45: Analysis
SELECT device_id, MIN(value) as min_val, MAX(value) as max_val, AVG(value) as avg_val
FROM metrics GROUP BY device_id;

-- Example 46-50: Performance
EXPLAIN SELECT * FROM metrics WHERE device_id = 'device_001' AND time > NOW() - INTERVAL '7 days';
SELECT * FROM metrics ORDER BY time DESC LIMIT 100;
SELECT COUNT(*) FROM metrics WHERE value > 50;
SELECT DISTINCT metric_type FROM metrics;

-- Show chunks
SELECT show_chunks('metrics');

-- Cleanup (optional)
-- DROP TABLE metrics CASCADE;
-- DROP EXTENSION timescaledb;
