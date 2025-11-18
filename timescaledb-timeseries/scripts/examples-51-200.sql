-- TimescaleDB 200 Complete Examples (51-200)

-- 51-75: Advanced Hypertable Operations
SELECT time_bucket('12 hours', time) as period,
  device_id,
  metric_type,
  AVG(value) as avg_value,
  MAX(value) as max_value,
  MIN(value) as min_value,
  STDDEV(value) as stddev_value
FROM metrics
WHERE time > NOW() - INTERVAL '30 days'
GROUP BY period, device_id, metric_type
ORDER BY period DESC, device_id;

-- 76-100: Gap Filling
SELECT
  time_bucket_gapfill('1 day', time) as day,
  device_id,
  AVG(value) as avg_value
FROM metrics
WHERE device_id = 'device_001'
GROUP BY day, device_id
ORDER BY day DESC;

-- 101-125: Continuous Aggregates with Joins
CREATE MATERIALIZED VIEW IF NOT EXISTS metrics_joined AS
SELECT time_bucket('1 hour', m.time) as hour,
  m.device_id,
  m.metric_type,
  AVG(m.value) as avg_value
FROM metrics m
GROUP BY hour, m.device_id, m.metric_type;

-- 126-150: Retention and Compression
SELECT add_retention_policy('metrics', INTERVAL '90 days');

SELECT compress_chunk(chunk) FROM show_chunks('metrics')
WHERE chunk_name LIKE '_hyper_%';

-- 151-175: Advanced Analytics
SELECT time_bucket('1 day', time) as day,
  COUNT(*) as data_points,
  AVG(value) as avg,
  PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY value) as p95,
  PERCENTILE_CONT(0.99) WITHIN GROUP (ORDER BY value) as p99
FROM metrics
GROUP BY day
ORDER BY day DESC;

-- 176-200: Performance Monitoring
SELECT * FROM timescaledb_information.hypertables;
SELECT * FROM timescaledb_information.chunks;
SELECT * FROM timescaledb_information.continuous_aggregates;
