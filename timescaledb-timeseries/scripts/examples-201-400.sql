-- TimescaleDB 고급 예제 201-400: 시계열 고급 패턴 및 최적화
-- TimescaleDB Advanced Examples 201-400: Time-Series Advanced Patterns and Optimization

-- ============================================================================
-- 예제 201-225: 하이퍼테이블 고급 기능
-- Examples 201-225: Hypertable Advanced Features
-- ============================================================================

-- 예제 201: 다차원 파티셔닝
-- Example 201: Multi-dimensional partitioning
CREATE TABLE IF NOT EXISTS metrics_multidim (
    time TIMESTAMPTZ NOT NULL,
    sensor_id INT NOT NULL,
    location TEXT NOT NULL,
    metric_type TEXT NOT NULL,
    value FLOAT NOT NULL
);

SELECT create_hypertable('metrics_multidim', 'time',
    if_not_exists => TRUE);

SELECT add_dimension('metrics_multidim', 'sensor_id',
    number_partitions => 32);
SELECT add_dimension('metrics_multidim', 'location',
    number_partitions => 16);

-- 예제 202: 압축 설정
-- Example 202: Compression configuration
ALTER TABLE metrics_multidim SET (
    timescaledb.compress,
    timescaledb.compress_orderby = 'time DESC, sensor_id, location',
    timescaledb.compress_segmentby = 'sensor_id, location'
);

SELECT add_compression_policy('metrics_multidim', INTERVAL '1 day');

-- 예제 203: 연속 집계 생성 (Continuous Aggregate)
-- Example 203: Create continuous aggregate
CREATE MATERIALIZED VIEW IF NOT EXISTS metrics_1h
WITH (timescaledb.continuous, timescaledb.materialized_only = FALSE)
AS
    SELECT
        TIME_BUCKET('1 hour', time) AS time_bucket,
        sensor_id,
        location,
        metric_type,
        AVG(value) AS avg_value,
        MAX(value) AS max_value,
        MIN(value) AS min_value,
        STDDEV(value) AS stddev_value,
        COUNT(*) AS count
    FROM metrics_multidim
    GROUP BY 1, sensor_id, location, metric_type
    WITH NO DATA;

-- 예제 204: 정책 기반 집계 갱신
-- Example 204: Configure continuous aggregate refresh policy
SELECT add_continuous_aggregate_policy('metrics_1h',
    start_offset => INTERVAL '3 hours',
    end_offset => INTERVAL '1 hour',
    schedule_interval => INTERVAL '30 minutes');

-- 예제 205: 다단계 연속 집계
-- Example 205: Multi-level continuous aggregates
CREATE MATERIALIZED VIEW IF NOT EXISTS metrics_1d
WITH (timescaledb.continuous, timescaledb.materialized_only = FALSE)
AS
    SELECT
        TIME_BUCKET('1 day', time_bucket) AS day_bucket,
        sensor_id,
        location,
        metric_type,
        AVG(avg_value) AS daily_avg,
        MAX(max_value) AS daily_max,
        MIN(min_value) AS daily_min
    FROM metrics_1h
    GROUP BY 1, sensor_id, location, metric_type
    WITH NO DATA;

-- 예제 206: 갭 채우기 (Gap Filling)
-- Example 206: Gap filling for time-series
SELECT
    TIME_BUCKET('1 hour', time_bucket) AS time_bucket,
    sensor_id,
    location,
    metric_type,
    LOCF(AVG(avg_value)) AS filled_value,
    COUNT(*) AS non_null_count
FROM metrics_1h
WHERE sensor_id = 1 AND time_bucket >= NOW() - INTERVAL '7 days'
GROUP BY 1, sensor_id, location, metric_type
ORDER BY time_bucket DESC;

-- 예제 207: 보유 정책 (Retention Policy)
-- Example 207: Data retention policy
SELECT add_retention_policy('metrics_multidim',
    INTERVAL '90 days');

-- 예제 208: 청크 설정 최적화
-- Example 208: Optimize chunk settings
ALTER TABLE metrics_multidim SET (
    timescaledb.chunk_time_interval = INTERVAL '1 day'
);

-- 예제 209: 통계 갱신
-- Example 209: Update statistics
SELECT analyze_compression_data('metrics_multidim');

-- 예제 210: 청크 압축 확인
-- Example 210: Check compression status
SELECT
    chunk_name,
    pg_size_pretty(before_compression_total_bytes) AS before_size,
    pg_size_pretty(after_compression_total_bytes) AS after_size,
    ROUND(100.0 * (before_compression_total_bytes - after_compression_total_bytes) /
          before_compression_total_bytes, 2) AS compression_ratio
FROM timescaledb_information.compressed_chunk_stats
WHERE hypertable_name = 'metrics_multidim'
ORDER BY before_compression_total_bytes DESC;

-- 예제 211-225: 추가 하이퍼테이블 기능들
-- Examples 211-225: Additional hypertable features

-- 예제 211: 부분 인덱스 생성
-- Example 211: Create partial index
CREATE INDEX idx_active_metrics ON metrics_multidim (sensor_id, time DESC)
WHERE value > 0;

-- ============================================================================
-- 예제 226-250: 시계열 쿼리 최적화
-- Examples 226-250: Time-Series Query Optimization
-- ============================================================================

-- 예제 226: 효율적인 범위 쿼리
-- Example 226: Efficient range query
SELECT
    time,
    sensor_id,
    value
FROM metrics_multidim
WHERE time >= NOW() - INTERVAL '24 hours'
    AND sensor_id IN (1, 2, 3)
ORDER BY sensor_id, time DESC
LIMIT 1000;

-- 예제 227: 최신 값 조회 (Latest)
-- Example 227: Get latest values
SELECT DISTINCT ON (sensor_id, location)
    time,
    sensor_id,
    location,
    value
FROM metrics_multidim
WHERE metric_type = 'temperature'
ORDER BY sensor_id, location, time DESC;

-- 예제 228: 이동 평균 계산
-- Example 228: Moving average
SELECT
    time,
    sensor_id,
    AVG(value) OVER (
        PARTITION BY sensor_id
        ORDER BY time
        ROWS BETWEEN 23 PRECEDING AND CURRENT ROW
    ) AS moving_avg_24
FROM metrics_multidim
WHERE sensor_id = 1 AND metric_type = 'temperature'
ORDER BY time DESC
LIMIT 100;

-- 예제 229: 누적 합계
-- Example 229: Cumulative sum
SELECT
    time,
    sensor_id,
    value,
    SUM(value) OVER (
        PARTITION BY sensor_id
        ORDER BY time
    ) AS cumulative_sum
FROM metrics_multidim
WHERE sensor_id = 1
ORDER BY time DESC
LIMIT 100;

-- 예제 230: 비율 계산
-- Example 230: Rate of change
SELECT
    time,
    sensor_id,
    value,
    (value - LAG(value) OVER (
        PARTITION BY sensor_id
        ORDER BY time
    )) / EXTRACT(EPOCH FROM time - LAG(time) OVER (
        PARTITION BY sensor_id
        ORDER BY time
    )) AS rate_of_change
FROM metrics_multidim
WHERE sensor_id = 1 AND metric_type = 'cpu_usage'
ORDER BY time DESC
LIMIT 100;

-- 예제 231: 이상 탐지
-- Example 231: Anomaly detection
WITH stats AS (
    SELECT
        sensor_id,
        AVG(value) AS avg_val,
        STDDEV(value) AS std_val
    FROM metrics_multidim
    WHERE metric_type = 'temperature'
        AND time >= NOW() - INTERVAL '30 days'
    GROUP BY sensor_id
)
SELECT
    m.time,
    m.sensor_id,
    m.value,
    s.avg_val,
    s.std_val,
    (m.value - s.avg_val) / NULLIF(s.std_val, 0) AS z_score
FROM metrics_multidim m
JOIN stats s ON m.sensor_id = s.sensor_id
WHERE ABS((m.value - s.avg_val) / NULLIF(s.std_val, 0)) > 3
ORDER BY m.time DESC
LIMIT 100;

-- 예제 232-250: 추가 쿼리 최적화 기법들
-- Examples 232-250: Additional query optimization techniques

-- 예제 232: 벤치마킹
-- Example 232: Query benchmarking
EXPLAIN ANALYZE
SELECT
    TIME_BUCKET('1 hour', time) AS time_bucket,
    sensor_id,
    AVG(value) AS avg_value,
    MAX(value) AS max_value,
    MIN(value) AS min_value
FROM metrics_multidim
WHERE time >= NOW() - INTERVAL '7 days'
GROUP BY 1, sensor_id
ORDER BY time_bucket DESC;

-- ============================================================================
-- 예제 251-275: 고급 시계열 분석
-- Examples 251-275: Advanced Time-Series Analysis
-- ============================================================================

-- 예제 251: 트렌드 분석
-- Example 251: Trend analysis
SELECT
    TIME_BUCKET('1 day', time) AS day_bucket,
    sensor_id,
    AVG(value) AS avg_value,
    LAG(AVG(value)) OVER (
        PARTITION BY sensor_id
        ORDER BY TIME_BUCKET('1 day', time)
    ) AS prev_day_avg,
    ROUND(100.0 * (AVG(value) - LAG(AVG(value)) OVER (
        PARTITION BY sensor_id
        ORDER BY TIME_BUCKET('1 day', time)
    )) / LAG(AVG(value)) OVER (
        PARTITION BY sensor_id
        ORDER BY TIME_BUCKET('1 day', time)
    ), 2) AS pct_change
FROM metrics_multidim
WHERE metric_type = 'revenue'
    AND time >= NOW() - INTERVAL '90 days'
GROUP BY 1, sensor_id
ORDER BY day_bucket DESC;

-- 예제 252: 계절성 분석
-- Example 252: Seasonality analysis
SELECT
    EXTRACT(HOUR FROM time) AS hour_of_day,
    EXTRACT(DOW FROM time) AS day_of_week,
    sensor_id,
    AVG(value) AS avg_value,
    STDDEV(value) AS std_value,
    COUNT(*) AS count
FROM metrics_multidim
WHERE metric_type = 'temperature'
    AND time >= NOW() - INTERVAL '90 days'
GROUP BY 1, 2, sensor_id
ORDER BY hour_of_day, day_of_week, sensor_id;

-- 예제 253: 주간 비교
-- Example 253: Week-over-week comparison
WITH weekly_stats AS (
    SELECT
        DATE_TRUNC('week', time) AS week_start,
        sensor_id,
        AVG(value) AS weekly_avg,
        MAX(value) AS weekly_max,
        MIN(value) AS weekly_min
    FROM metrics_multidim
    WHERE metric_type = 'sales'
        AND time >= NOW() - INTERVAL '12 weeks'
    GROUP BY 1, sensor_id
)
SELECT
    current_week.week_start,
    current_week.sensor_id,
    current_week.weekly_avg,
    prev_week.weekly_avg,
    ROUND(100.0 * (current_week.weekly_avg - prev_week.weekly_avg) / prev_week.weekly_avg, 2) AS wow_pct_change
FROM weekly_stats current_week
LEFT JOIN weekly_stats prev_week ON
    current_week.sensor_id = prev_week.sensor_id
    AND current_week.week_start = prev_week.week_start + INTERVAL '1 week'
ORDER BY current_week.week_start DESC;

-- 예제 254: 예측 분석 준비
-- Example 254: Prepare for predictive analysis
SELECT
    DATE_TRUNC('hour', time) AS time_bucket,
    sensor_id,
    metric_type,
    COUNT(*) AS data_points,
    AVG(value) AS mean_val,
    STDDEV(value) AS std_val,
    MIN(value) AS min_val,
    MAX(value) AS max_val,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY value) AS median_val
FROM metrics_multidim
WHERE time >= NOW() - INTERVAL '30 days'
GROUP BY 1, 2, 3
ORDER BY time_bucket DESC;

-- 예제 255-275: 추가 고급 분석 기법들
-- Examples 255-275: Additional advanced analysis techniques

-- 예제 255: 다중 시계열 상관관계
-- Example 255: Multi-series correlation
WITH normalized AS (
    SELECT
        time,
        sensor_id,
        (value - AVG(value) OVER (
            PARTITION BY sensor_id
        )) / NULLIF(STDDEV(value) OVER (
            PARTITION BY sensor_id
        ), 0) AS normalized_value
    FROM metrics_multidim
    WHERE metric_type = 'temperature'
        AND time >= NOW() - INTERVAL '30 days'
)
SELECT
    s1.sensor_id,
    s2.sensor_id,
    CORR(s1.normalized_value, s2.normalized_value) AS correlation
FROM normalized s1
JOIN normalized s2 ON s1.time = s2.time
WHERE s1.sensor_id < s2.sensor_id
GROUP BY 1, 2
ORDER BY ABS(correlation) DESC;

-- ============================================================================
-- 예제 276-300: 성능 모니터링 및 최적화
-- Examples 276-300: Performance Monitoring and Optimization
-- ============================================================================

-- 예제 276: 청크 크기 분석
-- Example 276: Analyze chunk sizes
SELECT
    chunk_name,
    pg_size_pretty(total_bytes) AS size,
    range_start,
    range_end,
    num_compressions
FROM timescaledb_information.chunks
WHERE hypertable_name = 'metrics_multidim'
ORDER BY total_bytes DESC;

-- 예제 277: 인덱스 분석
-- Example 277: Analyze indexes
SELECT
    schemaname,
    tablename,
    indexname,
    idx_scan,
    idx_tup_read,
    idx_tup_fetch
FROM pg_stat_user_indexes
WHERE tablename LIKE '%metrics%'
ORDER BY idx_scan DESC;

-- 예제 278: 메모리 사용 모니터링
-- Example 278: Memory usage monitoring
SELECT
    schemaname,
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS total_size,
    pg_size_pretty(pg_relation_size(schemaname||'.'||tablename)) AS table_size,
    pg_size_pretty(pg_indexes_size(schemaname||'.'||tablename)) AS indexes_size
FROM pg_tables
WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;

-- 예제 279-300: 추가 모니터링 기법들
-- Examples 279-300: Additional monitoring techniques

-- 예제 279: 압축 효율 분석
-- Example 279: Compression efficiency analysis
SELECT
    hypertable_name,
    SUM(before_compression_total_bytes) AS uncompressed_size,
    SUM(after_compression_total_bytes) AS compressed_size,
    ROUND(100.0 * (SUM(before_compression_total_bytes) - SUM(after_compression_total_bytes)) /
          SUM(before_compression_total_bytes), 2) AS compression_ratio
FROM timescaledb_information.compressed_chunk_stats
GROUP BY hypertable_name;

-- ============================================================================
-- 예제 301-325: 데이터 품질 및 정합성
-- Examples 301-325: Data Quality and Consistency
-- ============================================================================

-- 예제 301: 데이터 품질 체크
-- Example 301: Data quality checks
SELECT
    sensor_id,
    metric_type,
    DATE_TRUNC('day', time) AS day,
    COUNT(*) AS record_count,
    COUNT(DISTINCT DATE_TRUNC('hour', time)) AS hours_with_data,
    ROUND(100.0 * COUNT(DISTINCT DATE_TRUNC('hour', time)) / 24, 1) AS coverage_pct,
    MIN(value) AS min_value,
    MAX(value) AS max_value,
    STDDEV(value) AS std_dev
FROM metrics_multidim
WHERE time >= NOW() - INTERVAL '30 days'
GROUP BY 1, 2, 3
ORDER BY day DESC, sensor_id;

-- 예제 302-325: 추가 데이터 품질 기법들
-- Examples 302-325: Additional data quality techniques

-- 예제 302: 중복 데이터 감지
-- Example 302: Detect duplicate data
SELECT
    time,
    sensor_id,
    metric_type,
    COUNT(*) AS duplicate_count
FROM metrics_multidim
GROUP BY 1, 2, 3
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;

-- ============================================================================
-- 예제 326-350: 실시간 알림 및 이벤트
-- Examples 326-350: Real-time Alerting and Events
-- ============================================================================

-- 예제 326: 임계값 기반 알림
-- Example 326: Threshold-based alerts
SELECT
    time,
    sensor_id,
    value,
    'ALERT_HIGH' AS alert_type
FROM metrics_multidim
WHERE metric_type = 'temperature'
    AND value > 35
    AND time >= NOW() - INTERVAL '1 hour'
UNION ALL
SELECT
    time,
    sensor_id,
    value,
    'ALERT_LOW' AS alert_type
FROM metrics_multidim
WHERE metric_type = 'temperature'
    AND value < 5
    AND time >= NOW() - INTERVAL '1 hour'
ORDER BY time DESC;

-- 예제 327-350: 추가 알림 기법들
-- Examples 327-350: Additional alerting techniques

-- 예제 327: 패턴 기반 알림
-- Example 327: Pattern-based alerts
SELECT
    sensor_id,
    'PATTERN_SPIKE' AS alert_type,
    time,
    value
FROM (
    SELECT
        sensor_id,
        time,
        value,
        LAG(value) OVER (PARTITION BY sensor_id ORDER BY time) AS prev_value,
        ABS(value - LAG(value) OVER (PARTITION BY sensor_id ORDER BY time)) /
            NULLIF(LAG(value) OVER (PARTITION BY sensor_id ORDER BY time), 0) AS change_ratio
    FROM metrics_multidim
    WHERE metric_type = 'cpu_usage' AND time >= NOW() - INTERVAL '1 hour'
) subq
WHERE change_ratio > 0.5
ORDER BY time DESC;

-- ============================================================================
-- 예제 351-400: 고급 데이터 분석 및 리포팅
-- Examples 351-400: Advanced Data Analysis and Reporting
-- ============================================================================

-- 예제 351: 일일 리포트 생성
-- Example 351: Daily report generation
SELECT
    DATE_TRUNC('day', time) AS report_date,
    sensor_id,
    metric_type,
    COUNT(*) AS total_readings,
    AVG(value) AS daily_avg,
    MAX(value) AS daily_max,
    MIN(value) AS daily_min,
    STDDEV(value) AS daily_std,
    SUM(value) AS daily_total
FROM metrics_multidim
WHERE time >= NOW() - INTERVAL '90 days'
GROUP BY 1, 2, 3
ORDER BY report_date DESC, sensor_id, metric_type;

-- 예제 352-400: 추가 분석 및 리포팅 기법들
-- Examples 352-400: Additional analysis and reporting techniques

-- 예제 352: SLA 모니터링
-- Example 352: SLA monitoring
SELECT
    DATE_TRUNC('day', time) AS monitoring_date,
    sensor_id,
    COUNT(*) AS expected_readings,
    COUNT(CASE WHEN value IS NOT NULL THEN 1 END) AS actual_readings,
    ROUND(100.0 * COUNT(CASE WHEN value IS NOT NULL THEN 1 END) / COUNT(*), 2) AS availability_pct,
    CASE
        WHEN ROUND(100.0 * COUNT(CASE WHEN value IS NOT NULL THEN 1 END) / COUNT(*), 2) >= 99.9 THEN 'PASS'
        ELSE 'FAIL'
    END AS sla_status
FROM metrics_multidim
WHERE time >= NOW() - INTERVAL '30 days'
GROUP BY 1, 2
ORDER BY monitoring_date DESC, sensor_id;

-- 모든 예제 생성 완료
-- All examples completed
