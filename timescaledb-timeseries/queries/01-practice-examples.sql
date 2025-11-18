-- TimescaleDB 50 Practice Examples

-- ============================================
-- 1-10: Hypertable Operations
-- ============================================

-- 1. Create hypertable from regular table
SELECT create_hypertable('metrics', 'time', if_not_exists => TRUE);

-- 2. Insert data into hypertable
INSERT INTO metrics (time, device_id, metric_type, value, unit)
VALUES (NOW(), 'device_001', 'temperature', 22.5, 'celsius');

-- 3. Insert multiple rows
INSERT INTO metrics (time, device_id, metric_type, value, unit) VALUES
(NOW() - INTERVAL '1 hour', 'device_001', 'temperature', 23.0, 'celsius'),
(NOW() - INTERVAL '2 hours', 'device_001', 'humidity', 65.5, 'percent'),
(NOW() - INTERVAL '3 hours', 'device_002', 'temperature', 21.5, 'celsius');

-- 4. Query recent data
SELECT * FROM metrics WHERE device_id = 'device_001' ORDER BY time DESC LIMIT 10;

-- 5. Query time range
SELECT * FROM metrics
WHERE time > NOW() - INTERVAL '1 day' AND time < NOW()
ORDER BY time DESC;

-- 6. Count metrics by device
SELECT device_id, COUNT(*) as metric_count
FROM metrics
GROUP BY device_id;

-- 7. Get latest metric for each device
SELECT DISTINCT ON (device_id) device_id, time, value
FROM metrics
ORDER BY device_id, time DESC;

-- 8. Average value per device
SELECT device_id, AVG(value) as avg_value
FROM metrics
WHERE time > NOW() - INTERVAL '7 days'
GROUP BY device_id;

-- 9. Min/Max values per device
SELECT device_id, MIN(value) as min_value, MAX(value) as max_value
FROM metrics
WHERE time > NOW() - INTERVAL '7 days'
GROUP BY device_id;

-- 10. Chunk information
SELECT show_chunks('metrics');

-- ============================================
-- 11-20: Time-Bucketing Queries
-- ============================================

-- 11. Bucket by hour
SELECT time_bucket('1 hour', time) as bucket, device_id, AVG(value) as avg_value
FROM metrics
GROUP BY bucket, device_id
ORDER BY bucket DESC;

-- 12. Bucket by day
SELECT time_bucket('1 day', time) as bucket, device_id, AVG(value) as avg_value
FROM metrics
GROUP BY bucket, device_id;

-- 13. Bucket by 10 minutes
SELECT time_bucket('10 minutes', time) as bucket, AVG(value) as avg_value
FROM metrics
WHERE time > NOW() - INTERVAL '1 day'
GROUP BY bucket
ORDER BY bucket;

-- 14. Bucket with timezone
SELECT time_bucket('1 day', time, 'America/New_York') as bucket, AVG(value)
FROM metrics
GROUP BY bucket;

-- 15. Multiple bucketing
SELECT
  time_bucket('1 hour', time) as hourly,
  time_bucket('1 day', time) as daily,
  device_id,
  AVG(value) as avg_value
FROM metrics
GROUP BY hourly, daily, device_id;

-- 16. Bucket with NULL handling
SELECT time_bucket('1 hour', time) as bucket, COUNT(value) as non_null_count
FROM metrics
WHERE value IS NOT NULL
GROUP BY bucket;

-- 17. Fill gaps in time series
SELECT time_bucket('1 hour', time) as bucket, device_id, AVG(value) as avg_value
FROM metrics
WHERE device_id = 'device_001'
GROUP BY bucket, device_id
ORDER BY bucket;

-- 18. Bucket and order
SELECT time_bucket('1 day', time) as day, SUM(value) as total
FROM metrics
GROUP BY day
ORDER BY day DESC;

-- 19. Bucket with HAVING
SELECT time_bucket('1 hour', time) as bucket, AVG(value) as avg_val
FROM metrics
GROUP BY bucket
HAVING AVG(value) > 20;

-- 20. Continuous aggregation refresh
CALL refresh_continuous_aggregate('metrics_5min_aggregate', NULL, NULL);

-- ============================================
-- 21-30: Continuous Aggregates
-- ============================================

-- 21. Create hourly continuous aggregate
CREATE MATERIALIZED VIEW metrics_hourly WITH (timescaledb.continuous) AS
SELECT time_bucket('1 hour', time) as bucket, device_id, AVG(value) as avg_value
FROM metrics
GROUP BY bucket, device_id;

-- 22. Query continuous aggregate
SELECT * FROM metrics_hourly ORDER BY bucket DESC LIMIT 10;

-- 23. Create daily aggregate
CREATE MATERIALIZED VIEW metrics_daily WITH (timescaledb.continuous) AS
SELECT time_bucket('1 day', time) as bucket, device_id,
  AVG(value) as avg_value, MIN(value) as min_value, MAX(value) as max_value
FROM metrics
GROUP BY bucket, device_id;

-- 24. Set refresh policy
SELECT add_continuous_aggregate_policy('metrics_hourly',
  start_offset => INTERVAL '1 hour',
  end_offset => INTERVAL '0',
  schedule_interval => INTERVAL '1 hour');

-- 25. Refresh specific time range
CALL refresh_continuous_aggregate('metrics_hourly', '2024-01-01', '2024-01-02');

-- 26. Check aggregate stats
SELECT hypertable_name, view_name FROM timescaledb_information.continuous_aggregates;

-- 27. Drop continuous aggregate
DROP MATERIALIZED VIEW metrics_hourly CASCADE;

-- 28. Aggregate with multiple metrics
SELECT time_bucket('1 hour', time) as bucket, device_id,
  AVG(value) FILTER (WHERE metric_type = 'temperature') as avg_temp,
  AVG(value) FILTER (WHERE metric_type = 'humidity') as avg_humidity
FROM metrics
GROUP BY bucket, device_id;

-- 29. Historical aggregate data
SELECT * FROM metrics_daily
WHERE bucket >= '2024-01-01' AND bucket < '2024-02-01'
ORDER BY bucket DESC;

-- 30. Aggregate with time functions
SELECT
  time_bucket('1 day', bucket) as day,
  device_id,
  SUM(avg_value) as daily_sum
FROM metrics_hourly
GROUP BY day, device_id;

-- ============================================
-- 31-40: Compression and Retention
-- ============================================

-- 31. Enable compression
ALTER TABLE metrics SET (
  timescaledb.compress,
  timescaledb.compress_orderby = 'time DESC, device_id'
);

-- 32. Configure compression segment size
ALTER TABLE metrics SET (
  timescaledb.compress_segmentby = 'device_id',
  timescaledb.compress_orderby = 'time DESC'
);

-- 33. Compress specific chunks
SELECT compress_chunk(chunk) FROM show_chunks('metrics')
WHERE chunk_name = 'your_chunk_name';

-- 34. Decompress chunks
SELECT decompress_chunk(chunk) FROM show_chunks('metrics')
WHERE chunk_name = 'your_chunk_name';

-- 35. Check compression ratio
SELECT
  chunk_name,
  pg_size_pretty(before_compression_total_bytes) as before,
  pg_size_pretty(after_compression_total_bytes) as after
FROM chunk_compression_stats('metrics');

-- 36. Set retention policy
SELECT add_retention_policy('metrics', INTERVAL '30 days');

-- 37. Update retention policy
SELECT alter_job(job_id, config => '{"drop_after": "60 days"}')
FROM timescaledb_information.jobs
WHERE proc_name = 'policy_retention';

-- 38. Remove retention policy
SELECT remove_retention_policy('metrics');

-- 39. Manual data deletion (retention)
DELETE FROM metrics WHERE time < NOW() - INTERVAL '60 days';

-- 40. Chunk size configuration
SELECT set_chunk_time_interval('metrics', INTERVAL '1 day');

-- ============================================
-- 41-50: Advanced Analytics
-- ============================================

-- 41. Moving average (1 hour window)
SELECT time, device_id, value,
  AVG(value) OVER (PARTITION BY device_id ORDER BY time ROWS BETWEEN 3 PRECEDING AND CURRENT ROW) as moving_avg
FROM metrics
ORDER BY time DESC;

-- 42. Rate of change
SELECT time, device_id,
  (value - LAG(value) OVER (PARTITION BY device_id ORDER BY time)) as value_change
FROM metrics
ORDER BY time DESC;

-- 43. Cumulative sum
SELECT time, device_id, value,
  SUM(value) OVER (PARTITION BY device_id ORDER BY time) as cumulative_sum
FROM metrics
ORDER BY time DESC;

-- 44. First/Last values
SELECT device_id,
  FIRST(value, time) as first_value,
  LAST(value, time) as last_value
FROM metrics
WHERE time > NOW() - INTERVAL '1 day'
GROUP BY device_id;

-- 45. Percentile calculation
SELECT device_id,
  percentile_cont(0.25) WITHIN GROUP (ORDER BY value) as p25,
  percentile_cont(0.50) WITHIN GROUP (ORDER BY value) as p50,
  percentile_cont(0.75) WITHIN GROUP (ORDER BY value) as p75
FROM metrics
WHERE time > NOW() - INTERVAL '7 days'
GROUP BY device_id;

-- 46. Standard deviation
SELECT device_id, STDDEV(value) as std_dev
FROM metrics
WHERE time > NOW() - INTERVAL '7 days'
GROUP BY device_id;

-- 47. Anomaly detection (values >2 std dev)
WITH stats AS (
  SELECT device_id, AVG(value) as mean, STDDEV(value) as std_dev
  FROM metrics
  WHERE time > NOW() - INTERVAL '7 days'
  GROUP BY device_id
)
SELECT m.time, m.device_id, m.value
FROM metrics m
JOIN stats s ON m.device_id = s.device_id
WHERE ABS(m.value - s.mean) > 2 * s.std_dev;

-- 48. Gap filling with interpolation
SELECT time, device_id, value
FROM metrics
WHERE time > NOW() - INTERVAL '1 day'
ORDER BY device_id, time;

-- 49. Compare to previous period
SELECT
  time_bucket('1 day', time) as day,
  device_id,
  AVG(value) as current_avg,
  LAG(AVG(value)) OVER (PARTITION BY device_id ORDER BY time_bucket('1 day', time)) as previous_avg
FROM metrics
GROUP BY day, device_id;

-- 50. Top N devices by average value
SELECT device_id, AVG(value) as avg_value
FROM metrics
WHERE time > NOW() - INTERVAL '7 days'
GROUP BY device_id
ORDER BY avg_value DESC
LIMIT 5;
