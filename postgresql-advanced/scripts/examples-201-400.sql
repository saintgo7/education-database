-- PostgreSQL 고급 예제 201-400: 심화 데이터베이스 패턴 및 고성능 기법
-- Advanced PostgreSQL Examples 201-400: Advanced Patterns and High-Performance Techniques

-- 기본 설정
SET search_path TO public;

-- ============================================================================
-- 예제 201-225: 파티셔닝 및 대용량 데이터 관리
-- Examples 201-225: Partitioning and Large-Scale Data Management
-- ============================================================================

-- 예제 201: 범위 기반 파티셔닝 테이블 생성
-- Example 201: Create range-partitioned table
CREATE TABLE IF NOT EXISTS sales_partitioned (
    id BIGSERIAL,
    order_date DATE NOT NULL,
    customer_id INT NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    product_id INT NOT NULL,
    region VARCHAR(50),
    PRIMARY KEY (id, order_date)
) PARTITION BY RANGE (EXTRACT(YEAR FROM order_date));

CREATE TABLE IF NOT EXISTS sales_2022 PARTITION OF sales_partitioned
    FOR VALUES FROM (2022) TO (2023);
CREATE TABLE IF NOT EXISTS sales_2023 PARTITION OF sales_partitioned
    FOR VALUES FROM (2023) TO (2024);
CREATE TABLE IF NOT EXISTS sales_2024 PARTITION OF sales_partitioned
    FOR VALUES FROM (2024) TO (2025);

-- 예제 202: 리스트 기반 파티셔닝
-- Example 202: List-based partitioning
CREATE TABLE IF NOT EXISTS customer_regions (
    id SERIAL PRIMARY KEY,
    customer_id INT,
    name VARCHAR(100),
    region VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) PARTITION BY LIST (region);

CREATE TABLE IF NOT EXISTS customers_asia PARTITION OF customer_regions FOR VALUES IN ('Seoul', 'Tokyo', 'Bangkok', 'Singapore');
CREATE TABLE IF NOT EXISTS customers_europe PARTITION OF customer_regions FOR VALUES IN ('London', 'Paris', 'Berlin', 'Amsterdam');
CREATE TABLE IF NOT EXISTS customers_americas PARTITION OF customer_regions FOR VALUES IN ('New York', 'Toronto', 'Mexico City', 'Sao Paulo');

-- 예제 203: 해시 기반 파티셔닝
-- Example 203: Hash-based partitioning
CREATE TABLE IF NOT EXISTS user_events (
    id BIGSERIAL,
    user_id INT NOT NULL,
    event_type VARCHAR(50),
    event_data JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id, user_id)
) PARTITION BY HASH (user_id);

CREATE TABLE user_events_0 PARTITION OF user_events FOR VALUES WITH (MODULUS 4, REMAINDER 0);
CREATE TABLE user_events_1 PARTITION OF user_events FOR VALUES WITH (MODULUS 4, REMAINDER 1);
CREATE TABLE user_events_2 PARTITION OF user_events FOR VALUES WITH (MODULUS 4, REMAINDER 2);
CREATE TABLE user_events_3 PARTITION OF user_events FOR VALUES WITH (MODULUS 4, REMAINDER 3);

-- 예제 204: 파티션 자동 유지관리
-- Example 204: Automatic partition maintenance
CREATE OR REPLACE FUNCTION create_monthly_partitions()
RETURNS void AS $$
DECLARE
    v_partition_date DATE;
BEGIN
    v_partition_date := DATE_TRUNC('month', CURRENT_DATE + INTERVAL '1 month')::DATE;

    EXECUTE format('CREATE TABLE IF NOT EXISTS sales_%s PARTITION OF sales_partitioned
                   FOR VALUES FROM (%L) TO (%L)',
        TO_CHAR(v_partition_date, 'YYYY_MM'),
        v_partition_date,
        v_partition_date + INTERVAL '1 month');
END;
$$ LANGUAGE plpgsql;

-- 예제 205: 파티션 쿼리 최적화 확인
-- Example 205: Check partition query optimization
EXPLAIN (ANALYZE, BUFFERS)
SELECT COUNT(*) FROM sales_partitioned WHERE order_date >= '2024-01-01' AND order_date < '2024-02-01';

-- 예제 206: 대용량 배치 삽입 최적화
-- Example 206: Batch insert optimization for large datasets
CREATE TABLE IF NOT EXISTS batch_staging (LIKE sales_partitioned);

INSERT INTO batch_staging VALUES
(1, '2024-01-15', 1001, 99.99, 5001, 'Seoul'),
(2, '2024-01-16', 1002, 149.99, 5002, 'Seoul'),
(3, '2024-01-17', 1003, 79.99, 5003, 'Tokyo');

-- COPY를 사용한 고성능 삽입
-- Copy to sales using high-performance batch
INSERT INTO sales_partitioned SELECT * FROM batch_staging;
TRUNCATE batch_staging;

-- 예제 207: 파티션 통계 업데이트
-- Example 207: Update partition statistics
ANALYZE sales_partitioned;
ANALYZE customer_regions;

-- 예제 208: 파티션 제거 (오래된 파티션 정리)
-- Example 208: Drop old partitions (cleanup)
-- DROP TABLE IF EXISTS sales_2022; -- 주의: 실제 운영환경에서는 신중하게 사용

-- 예제 209: 인덱스 사용 파티셔닝
-- Example 209: Partitioned indexes
CREATE INDEX idx_sales_partitioned_customer ON sales_partitioned (customer_id)
    WHERE order_date >= '2024-01-01';

-- 예제 210: 파티션별 통계 확인
-- Example 210: Check partition statistics
SELECT
    schemaname,
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS size
FROM pg_tables
WHERE tablename LIKE 'sales_%'
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;

-- 예제 211: 동적 파티션 쿼리
-- Example 211: Dynamic partition query
CREATE OR REPLACE FUNCTION get_sales_for_period(
    p_start_date DATE,
    p_end_date DATE
)
RETURNS TABLE (customer_id INT, total_amount DECIMAL) AS $$
BEGIN
    RETURN QUERY
    EXECUTE format('SELECT customer_id, SUM(amount)::DECIMAL
                   FROM sales_partitioned
                   WHERE order_date >= %L AND order_date <= %L
                   GROUP BY customer_id',
                   p_start_date, p_end_date);
END;
$$ LANGUAGE plpgsql;

-- 예제 212: 파티션 제약 확인
-- Example 212: Check partition constraints
SELECT
    parent.relname as parent_table,
    child.relname as partition_name,
    pg_get_expr(pt.partconstraint, pt.partrelid) as partition_constraint
FROM pg_inherits
JOIN pg_class parent ON pg_inherits.inhrelid = parent.oid
JOIN pg_class child ON pg_inherits.inhparent = child.oid
JOIN pg_partitioned_table pt ON pt.partrelid = child.oid
WHERE parent.relname = 'sales_partitioned';

-- 예제 213: 파티션 교환 (EXCHANGE PARTITION)
-- Example 213: Partition exchange pattern
-- PostgreSQL에서는 직접적인 EXCHANGE PARTITION이 없으므로 ATTACH/DETACH 사용
ALTER TABLE sales_partitioned DETACH PARTITION sales_2022;
-- ALTER TABLE sales_partitioned ATTACH PARTITION sales_2022 FOR VALUES FROM (2022) TO (2023);

-- 예제 214: 파티션 기반 최적화된 집계
-- Example 214: Optimized aggregation with partitions
SELECT
    EXTRACT(YEAR FROM order_date) as year,
    EXTRACT(MONTH FROM order_date) as month,
    COUNT(*) as order_count,
    SUM(amount) as total_amount,
    AVG(amount) as avg_amount
FROM sales_partitioned
WHERE order_date >= '2024-01-01'
GROUP BY 1, 2
ORDER BY 1, 2;

-- 예제 215: 파티션별 ROW_NUMBER 계산
-- Example 215: ROW_NUMBER per partition
SELECT
    customer_id,
    order_date,
    amount,
    ROW_NUMBER() OVER (PARTITION BY EXTRACT(MONTH FROM order_date) ORDER BY amount DESC) as rank_in_month
FROM sales_partitioned
WHERE order_date >= '2024-01-01'
LIMIT 20;

-- 예제 216: 파티션 프루닝을 고려한 쿼리 작성
-- Example 216: Query with partition pruning consideration
EXPLAIN (ANALYZE)
SELECT customer_id, amount
FROM sales_partitioned
WHERE order_date = '2024-06-15';

-- 예제 217: 파티션 내 부분 인덱싱
-- Example 217: Partial index within partition
CREATE INDEX idx_sales_2024_high_value ON sales_2024 (customer_id)
WHERE amount > 1000;

-- 예제 218: 파티션 기반 스트리밍 처리
-- Example 218: Partition-based streaming process
SELECT
    CURRENT_TIMESTAMP as processing_time,
    COUNT(*) as batch_size,
    SUM(amount) as batch_total
FROM sales_partitioned
WHERE order_date = CURRENT_DATE
GROUP BY 1;

-- 예제 219: 파티션 메타데이터 쿼리
-- Example 219: Partition metadata query
SELECT
    schemaname,
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) as table_size,
    CASE
        WHEN tablename LIKE '%2022' THEN 'Archive'
        WHEN tablename LIKE '%2023' THEN 'Archive'
        ELSE 'Active'
    END as partition_status
FROM pg_tables
WHERE tablename LIKE 'sales_%'
ORDER BY tablename;

-- 예제 220: 파티션별 데이터 마이그레이션
-- Example 220: Data migration between partitions
WITH ranked_sales AS (
    SELECT
        *,
        ROW_NUMBER() OVER (PARTITION BY EXTRACT(YEAR FROM order_date) ORDER BY id) as rn
    FROM sales_partitioned
)
SELECT COUNT(*) FROM ranked_sales WHERE rn % 10 = 0;

-- 예제 221: 파티션 병합 시뮬레이션
-- Example 221: Partition merge simulation
SELECT
    EXTRACT(YEAR FROM order_date) as year,
    COUNT(*) as record_count,
    SUM(amount) as yearly_total,
    ROUND(AVG(amount), 2) as avg_transaction
FROM sales_partitioned
GROUP BY 1
ORDER BY 1;

-- 예제 222: 파티션 모니터링 함수
-- Example 222: Partition monitoring function
CREATE OR REPLACE FUNCTION monitor_partitions()
RETURNS TABLE (
    partition_name TEXT,
    record_count BIGINT,
    size_bytes BIGINT,
    size_pretty TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        tablename::TEXT,
        (SELECT COUNT(*) FROM ONLY sales_2024)::BIGINT,
        pg_total_relation_size(schemaname||'.'||tablename)::BIGINT,
        pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename))::TEXT
    FROM pg_tables
    WHERE tablename LIKE 'sales_%';
END;
$$ LANGUAGE plpgsql;

-- 예제 223: 파티션 활용 공간절감
-- Example 223: Space optimization with partitioning
SELECT
    tablename,
    pg_size_pretty(pg_relation_size(schemaname||'.'||tablename)) as table_only_size,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) as with_indexes_size
FROM pg_tables
WHERE tablename LIKE 'sales_%'
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;

-- 예제 224: 파티션 기반 병렬 처리
-- Example 224: Parallel processing with partitions
SET max_parallel_workers_per_gather = 4;
EXPLAIN (ANALYZE, BUFFERS)
SELECT
    customer_id,
    COUNT(*) as purchase_count,
    SUM(amount) as total_spent
FROM sales_partitioned
WHERE order_date >= '2024-01-01'
GROUP BY customer_id;

-- 예제 225: 파티션 통계 고급 분석
-- Example 225: Advanced partition statistics analysis
SELECT
    tablename,
    (SELECT COUNT(*) FROM pg_class WHERE relname = tablename) as index_count,
    pg_size_pretty(pg_relation_size(schemaname||'.'||tablename)) as main_table_size,
    pg_size_pretty(pg_indexes_size(schemaname||'.'||tablename)) as indexes_size
FROM pg_tables
WHERE tablename LIKE '%2024'
ORDER BY tablename;

-- ============================================================================
-- 예제 226-250: 고급 성능 최적화 기법
-- Examples 226-250: Advanced Performance Optimization Techniques
-- ============================================================================

-- 예제 226: BRIN 인덱스 (Block Range Index) 생성
-- Example 226: Create BRIN index
CREATE TABLE IF NOT EXISTS timeseries_data (
    id BIGSERIAL PRIMARY KEY,
    measurement_time TIMESTAMP NOT NULL,
    sensor_id INT,
    value FLOAT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_timeseries_brin ON timeseries_data USING BRIN (measurement_time) WITH (pages_per_range=128);

-- 예제 227: BRIN 인덱스 성능 비교
-- Example 227: BRIN index performance comparison
EXPLAIN (ANALYZE)
SELECT * FROM timeseries_data
WHERE measurement_time >= NOW() - INTERVAL '7 days'
ORDER BY measurement_time DESC;

-- 예제 228: 필터 인덱스 (Filtered Index)로 저장공간 절감
-- Example 228: Filtered index for space optimization
CREATE INDEX idx_active_users ON users (id)
WHERE is_active = true;

-- 예제 229: 인덱스 열 정렬 최적화
-- Example 229: Index column sort optimization
CREATE INDEX idx_product_sales ON products (
    category ASC,
    created_at DESC,
    price ASC
) WHERE status = 'active';

-- 예제 230: 인덱스 힌트 및 쿼리 계획 강제
-- Example 230: Query planning with index hints
SET enable_seqscan = OFF;
EXPLAIN SELECT * FROM users WHERE id > 1000 LIMIT 10;
RESET enable_seqscan;

-- 예제 231: 쿼리 플랜 캐싱
-- Example 231: Query plan caching
PREPARE get_user_by_id (INT) AS
SELECT id, email, name FROM users WHERE id = $1;

EXPLAIN EXECUTE get_user_by_id(1001);

-- 예제 232: 통계 업데이트 자동화
-- Example 232: Automated statistics update
CREATE OR REPLACE FUNCTION update_stats_schedule()
RETURNS void AS $$
BEGIN
    ANALYZE users;
    ANALYZE products;
    ANALYZE orders;
    ANALYZE sales_partitioned;
END;
$$ LANGUAGE plpgsql;

-- 예제 233: 실행 계획 분석 및 최적화
-- Example 233: Query plan analysis and optimization
EXPLAIN (ANALYZE, BUFFERS, TIMING, VERBOSE)
SELECT
    u.id,
    u.email,
    COUNT(o.id) as order_count,
    SUM(o.total_amount) as lifetime_value
FROM users u
LEFT JOIN orders o ON u.id = o.user_id
GROUP BY u.id, u.email
HAVING COUNT(o.id) > 0
ORDER BY lifetime_value DESC
LIMIT 100;

-- 예제 234: Hot/Cold 데이터 분리
-- Example 234: Hot/Cold data separation
CREATE TABLE IF NOT EXISTS logs_hot (
    id BIGSERIAL PRIMARY KEY,
    log_level VARCHAR(10),
    message TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) TABLESPACE pg_default;

-- 예제 235: 인덱스 정렬 순서 활용
-- Example 235: Index sort order optimization
CREATE INDEX idx_customer_purchases ON customer_regions (customer_id, created_at DESC NULLS LAST)
INCLUDE (region);

-- 예제 236: 부분 인덱스로 조인 성능 개선
-- Example 236: Partial index for join optimization
CREATE INDEX idx_active_orders ON orders (user_id, created_at DESC)
WHERE status IN ('pending', 'processing', 'shipped');

-- 예제 237: 멀티컬럼 인덱스 순서 최적화
-- Example 237: Multi-column index ordering
CREATE INDEX idx_sales_analysis ON sales_partitioned (region, customer_id, order_date DESC)
WHERE amount > 100;

-- 예제 238: 인덱스 블로비시우스 (Bloat) 모니터링
-- Example 238: Index bloat monitoring
SELECT
    tablename,
    indexname,
    idx_blks_read,
    idx_blks_hit,
    CASE
        WHEN (idx_blks_read + idx_blks_hit) = 0 THEN 0
        ELSE ROUND(100.0 * idx_blks_hit / (idx_blks_read + idx_blks_hit), 2)
    END as hit_ratio_percent
FROM pg_stat_user_indexes
ORDER BY idx_blks_read DESC
LIMIT 20;

-- 예제 239: 테이블 청소 (VACUUM) 자동화
-- Example 239: Automated table cleanup
CREATE OR REPLACE FUNCTION aggressive_vacuum()
RETURNS void AS $$
BEGIN
    VACUUM (ANALYZE, VERBOSE) users;
    VACUUM (ANALYZE, VERBOSE) orders;
    VACUUM (ANALYZE, VERBOSE) products;
END;
$$ LANGUAGE plpgsql;

-- 예제 240: 데드 로우 추정 및 정리
-- Example 240: Estimate and clean dead rows
SELECT
    schemaname,
    tablename,
    n_dead_tup as dead_rows,
    last_vacuum,
    last_autovacuum
FROM pg_stat_user_tables
WHERE n_dead_tup > 1000
ORDER BY n_dead_tup DESC;

-- 예제 241: 자동분석 설정 최적화
-- Example 241: Autovacuum configuration optimization
ALTER TABLE users SET (
    autovacuum_vacuum_scale_factor = 0.01,
    autovacuum_analyze_scale_factor = 0.005,
    autovacuum_vacuum_cost_delay = 20,
    autovacuum_vacuum_cost_limit = 1000
);

-- 예제 242: 쿼리 성능 벤치마크
-- Example 242: Query performance benchmark
DO $$
DECLARE
    v_start TIMESTAMP;
    v_end TIMESTAMP;
    v_duration INTERVAL;
BEGIN
    v_start := CLOCK_TIMESTAMP();

    PERFORM COUNT(*) FROM users WHERE id > 0;

    v_end := CLOCK_TIMESTAMP();
    v_duration := v_end - v_start;

    RAISE NOTICE 'Query execution time: %', v_duration;
END;
$$;

-- 예제 243: 샤딩 시뮬레이션
-- Example 243: Sharding simulation
CREATE OR REPLACE FUNCTION get_shard_id(p_user_id BIGINT, p_shard_count INT DEFAULT 16)
RETURNS INT AS $$
BEGIN
    RETURN (p_user_id % p_shard_count)::INT;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- 예제 244: 캐시 친화적 테이블 설계
-- Example 244: Cache-friendly table design
CREATE TABLE IF NOT EXISTS user_cache (
    id INT PRIMARY KEY,
    email VARCHAR(255),
    name VARCHAR(100),
    last_login TIMESTAMP,
    login_count INT,
    created_at TIMESTAMP
) WITH (fillfactor=70);

-- 예제 245: 버퍼 풀 활용률 분석
-- Example 245: Buffer pool utilization analysis
SELECT
    ROUND(100.0 * heap_blks_hit / (heap_blks_hit + heap_blks_read), 2) as heap_hit_ratio,
    ROUND(100.0 * idx_blks_hit / (idx_blks_hit + idx_blks_read), 2) as index_hit_ratio,
    ROUND(100.0 * toast_blks_hit / (toast_blks_hit + toast_blks_read), 2) as toast_hit_ratio
FROM pg_stat_database
WHERE datname = CURRENT_DATABASE();

-- 예제 246: 워킹셋 분석
-- Example 246: Working set analysis
SELECT
    schemaname,
    tablename,
    ROUND(heap_blks_read::numeric / (heap_blks_read + heap_blks_hit), 4) as miss_ratio,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) as size
FROM pg_statio_user_tables
WHERE (heap_blks_read + heap_blks_hit) > 0
ORDER BY miss_ratio DESC
LIMIT 20;

-- 예제 247: 쿼리 병렬화 설정
-- Example 247: Query parallelization configuration
SET max_parallel_workers = 8;
SET max_parallel_workers_per_gather = 4;
SET parallel_tuple_cost = 0.01;
SET parallel_setup_cost = 500;

EXPLAIN (ANALYZE)
SELECT COUNT(*) FROM users WHERE id > 0;

-- 예제 248: 메모리 사용량 모니터링
-- Example 248: Memory usage monitoring
SELECT
    query_id,
    query,
    calls,
    ROUND((total_time / 1000)::numeric, 2) as total_time_seconds,
    ROUND((mean_time)::numeric, 2) as mean_time_ms,
    rows
FROM pg_stat_statements
ORDER BY mean_time DESC
LIMIT 20;

-- 예제 249: 잠금 대기 분석
-- Example 249: Lock contention analysis
SELECT
    pid,
    usename,
    query,
    state,
    wait_event_type,
    wait_event
FROM pg_stat_activity
WHERE state != 'idle'
ORDER BY query_start ASC;

-- 예제 250: 성능 베이스라인 수집
-- Example 250: Performance baseline collection
CREATE TABLE IF NOT EXISTS performance_baseline (
    id SERIAL PRIMARY KEY,
    metric_name VARCHAR(100),
    metric_value NUMERIC,
    recorded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    database_name NAME,
    table_name VARCHAR(100)
);

INSERT INTO performance_baseline (metric_name, metric_value, database_name)
SELECT
    'total_relations' as metric_name,
    COUNT(*)::NUMERIC as metric_value,
    CURRENT_DATABASE() as database_name
FROM pg_stat_user_tables;

-- ============================================================================
-- 예제 251-275: 병렬 처리 및 분산 쿼리
-- Examples 251-275: Parallel Processing and Distributed Queries
-- ============================================================================

-- 예제 251: 병렬 테이블 스캔 활용
-- Example 251: Parallel sequential scans
SET enable_parallel_seq_scan = ON;
EXPLAIN (ANALYZE)
SELECT COUNT(*) FROM large_dataset WHERE status = 'active';

-- 예제 252: 병렬 쿼리 수행 계획
-- Example 252: Parallel query execution plan
EXPLAIN (ANALYZE, BUFFERS)
SELECT
    category,
    COUNT(*) as count,
    AVG(price) as avg_price
FROM products
GROUP BY category;

-- 예제 253: 병렬 집계 함수
-- Example 253: Parallel aggregate functions
EXPLAIN (ANALYZE)
SELECT
    SUM(amount) as total,
    AVG(amount) as average,
    MAX(amount) as maximum,
    MIN(amount) as minimum
FROM orders;

-- 예제 254: 병렬 정렬 연산
-- Example 254: Parallel sort operation
EXPLAIN (ANALYZE)
SELECT *
FROM users
ORDER BY created_at DESC
LIMIT 1000;

-- 예제 255: 병렬 해시 조인
-- Example 255: Parallel hash join
SET enable_hashjoin = ON;
EXPLAIN (ANALYZE)
SELECT u.id, o.id
FROM users u
INNER JOIN orders o ON u.id = o.user_id
WHERE u.is_active = true;

-- 예제 256: 병렬 작업 분배
-- Example 256: Parallel work distribution
SELECT
    pid,
    state,
    query_start,
    query
FROM pg_stat_activity
WHERE query NOT ILIKE '%pg_stat_activity%'
ORDER BY query_start DESC;

-- 예제 257: 병렬 I/O 최적화
-- Example 257: Parallel I/O optimization
EXPLAIN (ANALYZE, BUFFERS, VERBOSE)
SELECT *
FROM large_table
WHERE created_at >= CURRENT_DATE - INTERVAL '30 days'
ORDER BY created_at DESC;

-- 예제 258: CTEs의 병렬 처리
-- Example 258: Parallel CTEs
EXPLAIN (ANALYZE)
WITH ranked_users AS (
    SELECT
        id,
        email,
        ROW_NUMBER() OVER (ORDER BY created_at DESC) as rn
    FROM users
)
SELECT * FROM ranked_users WHERE rn <= 100;

-- 예제 259: 병렬 서브쿼리
-- Example 259: Parallel subqueries
EXPLAIN (ANALYZE)
SELECT
    user_id,
    (SELECT COUNT(*) FROM orders o WHERE o.user_id = u.id) as order_count
FROM users u;

-- 예제 260: 병렬 UNION ALL
-- Example 260: Parallel UNION ALL
EXPLAIN (ANALYZE)
SELECT id, email FROM users WHERE is_active = true
UNION ALL
SELECT id, email FROM archived_users WHERE archive_date >= CURRENT_DATE - INTERVAL '1 year';

-- 예제 261: 병렬 처리 비용 계산
-- Example 261: Parallel execution cost calculation
SELECT
    query_id,
    calls,
    ROUND((total_time / calls)::numeric, 2) as avg_time_ms,
    rows,
    rows * calls as total_rows_processed
FROM pg_stat_statements
WHERE query NOT ILIKE '%pg_stat_statements%'
ORDER BY total_time DESC
LIMIT 10;

-- 예제 262: 병렬 윈도우 함수
-- Example 262: Parallel window functions
EXPLAIN (ANALYZE)
SELECT
    customer_id,
    amount,
    SUM(amount) OVER (PARTITION BY customer_id ORDER BY created_at) as running_total,
    RANK() OVER (PARTITION BY customer_id ORDER BY amount DESC) as rank
FROM orders;

-- 예제 263: 적응형 병렬화
-- Example 263: Adaptive parallelism
SET adaptive_query_tuning = ON;
EXPLAIN (ANALYZE)
SELECT COUNT(DISTINCT user_id) FROM orders WHERE created_at >= CURRENT_DATE - INTERVAL '1 year';

-- 예제 264: 병렬 처리 리소스 관리
-- Example 264: Parallel processing resource management
SELECT
    setting,
    unit,
    short_desc,
    CASE
        WHEN setting ~ '^[0-9]+$' THEN setting || ' ' || COALESCE(unit, '')
        ELSE setting
    END as current_value
FROM pg_settings
WHERE name LIKE '%parallel%'
ORDER BY name;

-- 예제 265: 병렬 실행 큐 모니터링
-- Example 265: Parallel execution queue monitoring
SELECT
    pid,
    usename,
    state,
    state_change,
    query
FROM pg_stat_activity
WHERE wait_event_type = 'ParallelWorkerQueue'
ORDER BY state_change DESC;

-- 예제 266: 교착 상태 감지 및 회피
-- Example 266: Deadlock detection and avoidance
CREATE OR REPLACE FUNCTION check_deadlock_risk()
RETURNS TABLE (
    blocker_pid INT,
    blocked_pid INT,
    blocked_statement TEXT
) AS $$
SELECT
    blocking_locks.pid as blocker_pid,
    blocked_locks.pid as blocked_pid,
    blocked_activity.query as blocked_statement
FROM pg_catalog.pg_locks blocked_locks
JOIN pg_catalog.pg_stat_activity blocked_activity ON blocked_activity.pid = blocked_locks.pid
JOIN pg_catalog.pg_locks blocking_locks ON blocking_locks.locktype = blocked_locks.locktype
    AND blocking_locks.database IS NOT DISTINCT FROM blocked_locks.database
    AND blocking_locks.relation IS NOT DISTINCT FROM blocked_locks.relation
    AND blocking_locks.page IS NOT DISTINCT FROM blocked_locks.page
    AND blocking_locks.tuple IS NOT DISTINCT FROM blocked_locks.tuple
    AND blocking_locks.virtualxid IS NOT DISTINCT FROM blocked_locks.virtualxid
    AND blocking_locks.transactionid IS NOT DISTINCT FROM blocked_locks.transactionid
    AND blocking_locks.classid IS NOT DISTINCT FROM blocked_locks.classid
    AND blocking_locks.objid IS NOT DISTINCT FROM blocked_locks.objid
    AND blocking_locks.objsubid IS NOT DISTINCT FROM blocked_locks.objsubid
    AND blocking_locks.pid != blocked_locks.pid
JOIN pg_catalog.pg_stat_activity blocking_activity ON blocking_activity.pid = blocking_locks.pid
WHERE NOT blocked_locks.granted;
$$ LANGUAGE SQL;

-- 예제 267: 병렬 처리 성능 비교
-- Example 267: Parallel vs sequential performance
DO $$
DECLARE
    v_start TIMESTAMP;
    v_parallel_time INTERVAL;
    v_sequential_time INTERVAL;
BEGIN
    SET enable_parallel_seq_scan = ON;
    v_start := CLOCK_TIMESTAMP();
    PERFORM COUNT(*) FROM users;
    v_parallel_time := CLOCK_TIMESTAMP() - v_start;

    SET enable_parallel_seq_scan = OFF;
    v_start := CLOCK_TIMESTAMP();
    PERFORM COUNT(*) FROM users;
    v_sequential_time := CLOCK_TIMESTAMP() - v_start;

    RAISE NOTICE 'Parallel: %, Sequential: %', v_parallel_time, v_sequential_time;
    RESET enable_parallel_seq_scan;
END;
$$;

-- 예제 268: 병렬 처리 통계 수집
-- Example 268: Parallel statistics collection
CREATE TABLE IF NOT EXISTS parallel_execution_stats (
    id SERIAL PRIMARY KEY,
    query_pattern VARCHAR(255),
    parallel_time_ms NUMERIC,
    sequential_time_ms NUMERIC,
    parallelization_ratio NUMERIC,
    collected_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 예제 269: 병렬 드라이버 작업 분배
-- Example 269: Parallel worker task distribution
SELECT
    pid,
    usename,
    application_name,
    query_start,
    state_change,
    query
FROM pg_stat_activity
WHERE query LIKE '%EXPLAIN%'
ORDER BY query_start DESC
LIMIT 10;

-- 예제 270: 병렬 처리 디버깅
-- Example 270: Parallel processing debugging
SET log_min_messages = DEBUG2;
EXPLAIN (ANALYZE, BUFFERS, VERBOSE)
SELECT COUNT(*) FROM users WHERE id > 1000;
RESET log_min_messages;

-- ============================================================================
-- 예제 271-300: 실시간 데이터 처리 및 스트리밍
-- Examples 271-300: Real-time Data Processing and Streaming
-- ============================================================================

-- 예제 271: 변경 데이터 캡처 (CDC) 테이블 설정
-- Example 271: Change Data Capture table setup
CREATE TABLE IF NOT EXISTS events_log (
    id BIGSERIAL PRIMARY KEY,
    event_type VARCHAR(50) NOT NULL,
    entity_type VARCHAR(50) NOT NULL,
    entity_id BIGINT NOT NULL,
    old_values JSONB,
    new_values JSONB,
    changed_by VARCHAR(100),
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_events_entity ON events_log (entity_type, entity_id, changed_at DESC);

-- 예제 272: 트리거 기반 이벤트 로깅
-- Example 272: Trigger-based event logging
CREATE OR REPLACE FUNCTION log_user_changes()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO events_log (event_type, entity_type, entity_id, old_values, new_values, changed_at)
    VALUES (
        TG_OP,
        'users',
        COALESCE(NEW.id, OLD.id),
        to_jsonb(OLD),
        to_jsonb(NEW),
        CURRENT_TIMESTAMP
    );
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

-- 예제 273: 실시간 카운터 업데이트
-- Example 273: Real-time counter update
CREATE TABLE IF NOT EXISTS real_time_counters (
    counter_key VARCHAR(100) PRIMARY KEY,
    counter_value BIGINT DEFAULT 0,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE OR REPLACE FUNCTION increment_counter(p_key VARCHAR, p_increment INT DEFAULT 1)
RETURNS BIGINT AS $$
DECLARE
    v_new_value BIGINT;
BEGIN
    INSERT INTO real_time_counters (counter_key, counter_value)
    VALUES (p_key, p_increment)
    ON CONFLICT (counter_key)
    DO UPDATE SET
        counter_value = real_time_counters.counter_value + EXCLUDED.counter_value,
        last_updated = CURRENT_TIMESTAMP
    RETURNING counter_value INTO v_new_value;

    RETURN v_new_value;
END;
$$ LANGUAGE plpgsql;

-- 예제 274: 윈도우 기반 시계열 집계
-- Example 274: Time-window aggregation
CREATE OR REPLACE FUNCTION get_window_stats(
    p_minutes INT DEFAULT 5
)
RETURNS TABLE (
    window_start TIMESTAMP,
    event_count BIGINT,
    avg_amount NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        DATE_TRUNC('minute', changed_at)::TIMESTAMP as window_start,
        COUNT(*)::BIGINT as event_count,
        ROUND(AVG((new_values->>'amount')::NUMERIC), 2) as avg_amount
    FROM events_log
    WHERE changed_at >= NOW() - (p_minutes || ' minutes')::INTERVAL
    GROUP BY DATE_TRUNC('minute', changed_at)
    ORDER BY window_start DESC;
END;
$$ LANGUAGE plpgsql;

-- 예제 275: 스트림 처리 컨슈머 상태 관리
-- Example 275: Stream consumer status tracking
CREATE TABLE IF NOT EXISTS stream_consumer_state (
    consumer_id VARCHAR(100) PRIMARY KEY,
    topic VARCHAR(100) NOT NULL,
    last_offset BIGINT DEFAULT 0,
    last_processed TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) DEFAULT 'active',
    lag_bytes BIGINT DEFAULT 0
);

-- 예제 276: 증분 마이그레이션 커서
-- Example 276: Incremental migration cursor
CREATE TABLE IF NOT EXISTS migration_cursor (
    migration_id VARCHAR(100) PRIMARY KEY,
    last_processed_id BIGINT DEFAULT 0,
    total_processed BIGINT DEFAULT 0,
    status VARCHAR(20) DEFAULT 'running',
    started_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 예제 277: 배치 처리 상태 추적
-- Example 277: Batch processing status tracking
CREATE TABLE IF NOT EXISTS batch_jobs (
    job_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    job_name VARCHAR(255) NOT NULL,
    batch_size INT DEFAULT 1000,
    records_processed BIGINT DEFAULT 0,
    records_failed BIGINT DEFAULT 0,
    status VARCHAR(20) DEFAULT 'pending',
    started_at TIMESTAMP,
    completed_at TIMESTAMP,
    error_message TEXT
);

-- 예제 278: 실시간 모니터링 대시보드 쿼리
-- Example 278: Real-time monitoring dashboard query
CREATE OR REPLACE FUNCTION get_realtime_stats()
RETURNS TABLE (
    metric_name TEXT,
    metric_value NUMERIC,
    recorded_at TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY
    SELECT 'total_users'::TEXT, COUNT(*)::NUMERIC, CURRENT_TIMESTAMP FROM users
    UNION ALL
    SELECT 'active_users'::TEXT, COUNT(*)::NUMERIC, CURRENT_TIMESTAMP FROM users WHERE is_active = true
    UNION ALL
    SELECT 'total_orders'::TEXT, COUNT(*)::NUMERIC, CURRENT_TIMESTAMP FROM orders
    UNION ALL
    SELECT 'pending_orders'::TEXT, COUNT(*)::NUMERIC, CURRENT_TIMESTAMP FROM orders WHERE status = 'pending'
    UNION ALL
    SELECT 'events_today'::TEXT, COUNT(*)::NUMERIC, CURRENT_TIMESTAMP FROM events_log WHERE DATE(changed_at) = CURRENT_DATE;
END;
$$ LANGUAGE plpgsql;

-- 예제 279: 실시간 이상 탐지
-- Example 279: Real-time anomaly detection
CREATE OR REPLACE FUNCTION detect_anomalies(p_std_multiplier FLOAT DEFAULT 3.0)
RETURNS TABLE (
    window_time TIMESTAMP,
    anomaly_score NUMERIC,
    expected_value NUMERIC,
    actual_value NUMERIC,
    is_anomaly BOOLEAN
) AS $$
WITH stats AS (
    SELECT
        DATE_TRUNC('hour', changed_at) as hour_window,
        COUNT(*) as event_count,
        AVG(COUNT(*)) OVER () as avg_count,
        STDDEV(COUNT(*)) OVER () as std_dev
    FROM events_log
    WHERE changed_at >= NOW() - INTERVAL '7 days'
    GROUP BY DATE_TRUNC('hour', changed_at)
)
SELECT
    hour_window,
    ABS((event_count - avg_count)::NUMERIC / NULLIF(std_dev, 0))::NUMERIC as anomaly_score,
    ROUND(avg_count::NUMERIC, 2) as expected_value,
    event_count::NUMERIC as actual_value,
    ABS((event_count - avg_count)::NUMERIC / NULLIF(std_dev, 0)) > p_std_multiplier as is_anomaly
FROM stats
ORDER BY hour_window DESC;
$$ LANGUAGE plpgsql;

-- 예제 280: 우선순위 기반 이벤트 처리
-- Example 280: Priority-based event processing
CREATE TABLE IF NOT EXISTS priority_events (
    id BIGSERIAL PRIMARY KEY,
    event_type VARCHAR(50),
    priority INT DEFAULT 5,
    payload JSONB,
    processed BOOLEAN DEFAULT false,
    processed_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_priority_events ON priority_events (priority DESC, created_at ASC)
WHERE processed = false;

-- 예제 281: 실시간 세션 관리
-- Example 281: Real-time session management
CREATE TABLE IF NOT EXISTS user_sessions (
    session_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id INT NOT NULL,
    ip_address INET,
    user_agent VARCHAR(255),
    last_activity TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    session_data JSONB,
    status VARCHAR(20) DEFAULT 'active'
);

CREATE INDEX idx_user_active_sessions ON user_sessions (user_id, status)
WHERE status = 'active'
AND last_activity > NOW() - INTERVAL '1 day';

-- 예제 282: 실시간 알림 큐
-- Example 282: Real-time notification queue
CREATE TABLE IF NOT EXISTS notification_queue (
    notification_id BIGSERIAL PRIMARY KEY,
    recipient_id INT NOT NULL,
    notification_type VARCHAR(50),
    content TEXT,
    priority INT DEFAULT 5,
    scheduled_for TIMESTAMP,
    sent_at TIMESTAMP,
    status VARCHAR(20) DEFAULT 'pending'
);

CREATE INDEX idx_notifications_pending ON notification_queue (scheduled_for, priority DESC)
WHERE status = 'pending';

-- 예제 283: 시간 기반 자동 정리
-- Example 283: Time-based automatic cleanup
CREATE OR REPLACE FUNCTION cleanup_old_data()
RETURNS void AS $$
BEGIN
    DELETE FROM events_log WHERE changed_at < NOW() - INTERVAL '90 days';
    DELETE FROM user_sessions WHERE last_activity < NOW() - INTERVAL '30 days';
    DELETE FROM notification_queue WHERE sent_at < NOW() - INTERVAL '7 days' AND status = 'sent';
    VACUUM ANALYZE events_log;
    VACUUM ANALYZE user_sessions;
    VACUUM ANALYZE notification_queue;
END;
$$ LANGUAGE plpgsql;

-- 예제 284: 실시간 용량 모니터링
-- Example 284: Real-time capacity monitoring
CREATE OR REPLACE FUNCTION check_table_capacity()
RETURNS TABLE (
    table_name TEXT,
    row_count BIGINT,
    table_size_mb NUMERIC,
    capacity_percentage NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        t.tablename::TEXT,
        (SELECT COUNT(*) FROM ONLY orders)::BIGINT,
        ROUND((pg_total_relation_size(t.schemaname||'.'||t.tablename)::NUMERIC / 1024 / 1024), 2),
        ROUND((pg_total_relation_size(t.schemaname||'.'||t.tablename)::NUMERIC / (1024 * 1024 * 1024))::NUMERIC, 2)
    FROM pg_tables t
    WHERE t.tablename IN ('orders', 'events_log', 'users')
    ORDER BY pg_total_relation_size(t.schemaname||'.'||t.tablename) DESC;
END;
$$ LANGUAGE plpgsql;

-- 예제 285: 스트림 처리 체크포인트
-- Example 285: Stream processing checkpoints
CREATE TABLE IF NOT EXISTS processing_checkpoints (
    checkpoint_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    job_id VARCHAR(100) NOT NULL,
    checkpoint_type VARCHAR(50),
    checkpoint_data JSONB,
    sequence_number BIGINT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_checkpoints_job ON processing_checkpoints (job_id, sequence_number DESC);

-- ============================================================================
-- 예제 286-300: 고급 분석 및 리포팅
-- Examples 286-300: Advanced Analytics and Reporting
-- ============================================================================

-- 예제 286: 고급 코호트 분석
-- Example 286: Advanced cohort analysis
CREATE OR REPLACE FUNCTION cohort_analysis(p_months INT DEFAULT 12)
RETURNS TABLE (
    cohort_month DATE,
    month_index INT,
    cohort_size BIGINT,
    retained_count BIGINT,
    retention_rate NUMERIC
) AS $$
WITH cohort_data AS (
    SELECT
        DATE_TRUNC('month', created_at)::DATE as cohort_month,
        id as user_id,
        EXTRACT(YEAR FROM DATE_TRUNC('month', created_at))::INT as cohort_year,
        EXTRACT(MONTH FROM DATE_TRUNC('month', created_at))::INT as cohort_month_num
    FROM users
    WHERE created_at >= NOW() - (p_months || ' months')::INTERVAL
),
retention_data AS (
    SELECT
        c.cohort_month,
        (EXTRACT(YEAR FROM el.changed_at)::INT - c.cohort_year) * 12 +
        (EXTRACT(MONTH FROM el.changed_at)::INT - c.cohort_month_num) as month_index,
        COUNT(DISTINCT c.user_id) as retained_count
    FROM cohort_data c
    LEFT JOIN events_log el ON c.user_id = el.entity_id
    GROUP BY c.cohort_month, month_index
)
SELECT
    c.cohort_month,
    r.month_index,
    COUNT(DISTINCT c.user_id)::BIGINT as cohort_size,
    r.retained_count::BIGINT,
    ROUND((r.retained_count::NUMERIC / COUNT(DISTINCT c.user_id)) * 100, 2) as retention_rate
FROM cohort_data c
LEFT JOIN retention_data r ON c.cohort_month = r.cohort_month
GROUP BY c.cohort_month, r.month_index, r.retained_count
ORDER BY c.cohort_month, r.month_index;
$$ LANGUAGE plpgsql;

-- 예제 287: RFM (Recency, Frequency, Monetary) 분석
-- Example 287: RFM Analysis
CREATE OR REPLACE FUNCTION rfm_analysis()
RETURNS TABLE (
    user_id INT,
    recency_days INT,
    purchase_frequency INT,
    monetary_value NUMERIC,
    rfm_score VARCHAR(3)
) AS $$
WITH rfm AS (
    SELECT
        u.id as user_id,
        EXTRACT(DAY FROM NOW() - MAX(o.created_at))::INT as recency_days,
        COUNT(o.id)::INT as purchase_frequency,
        COALESCE(SUM(o.total_amount), 0)::NUMERIC as monetary_value
    FROM users u
    LEFT JOIN orders o ON u.id = o.user_id
    GROUP BY u.id
),
rfm_segments AS (
    SELECT
        *,
        NTILE(5) OVER (ORDER BY recency_days DESC) as r_score,
        NTILE(5) OVER (ORDER BY purchase_frequency) as f_score,
        NTILE(5) OVER (ORDER BY monetary_value) as m_score
    FROM rfm
)
SELECT
    user_id,
    recency_days,
    purchase_frequency,
    monetary_value,
    (r_score::TEXT || f_score::TEXT || m_score::TEXT) as rfm_score
FROM rfm_segments
ORDER BY rfm_score DESC;
$$ LANGUAGE plpgsql;

-- 예제 288: 트렌드 분석
-- Example 288: Trend analysis
CREATE OR REPLACE FUNCTION trend_analysis(p_metric VARCHAR, p_days INT DEFAULT 90)
RETURNS TABLE (
    trend_date DATE,
    metric_value NUMERIC,
    moving_average_7 NUMERIC,
    moving_average_30 NUMERIC,
    trend_direction VARCHAR(10)
) AS $$
WITH daily_metrics AS (
    SELECT
        DATE(changed_at) as metric_date,
        COUNT(*)::NUMERIC as daily_count
    FROM events_log
    WHERE changed_at >= NOW() - (p_days || ' days')::INTERVAL
    GROUP BY DATE(changed_at)
),
with_averages AS (
    SELECT
        metric_date,
        daily_count,
        AVG(daily_count) OVER (ORDER BY metric_date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) as ma_7,
        AVG(daily_count) OVER (ORDER BY metric_date ROWS BETWEEN 29 PRECEDING AND CURRENT ROW) as ma_30
    FROM daily_metrics
)
SELECT
    metric_date,
    daily_count,
    ROUND(ma_7, 2),
    ROUND(ma_30, 2),
    CASE
        WHEN LAG(daily_count) OVER (ORDER BY metric_date) < daily_count THEN 'Up'
        WHEN LAG(daily_count) OVER (ORDER BY metric_date) > daily_count THEN 'Down'
        ELSE 'Stable'
    END as trend_direction
FROM with_averages
ORDER BY metric_date DESC;
$$ LANGUAGE plpgsql;

-- 예제 289: 예측 분석
-- Example 289: Predictive analytics
CREATE OR REPLACE FUNCTION predict_next_period(p_days INT DEFAULT 30)
RETURNS TABLE (
    prediction_date DATE,
    predicted_value NUMERIC,
    confidence_interval NUMERIC,
    prediction_method TEXT
) AS $$
WITH historical_data AS (
    SELECT
        DATE(changed_at) as data_date,
        COUNT(*)::NUMERIC as daily_count
    FROM events_log
    WHERE changed_at >= NOW() - INTERVAL '90 days'
    GROUP BY DATE(changed_at)
),
statistics AS (
    SELECT
        AVG(daily_count) as avg_value,
        STDDEV(daily_count) as std_dev,
        MAX(daily_count) as max_value,
        MIN(daily_count) as min_value
    FROM historical_data
)
SELECT
    (CURRENT_DATE + (n || ' days')::INTERVAL)::DATE,
    (SELECT avg_value FROM statistics)::NUMERIC,
    (SELECT std_dev FROM statistics)::NUMERIC,
    'Moving Average'::TEXT
FROM GENERATE_SERIES(1, p_days) AS n;
$$ LANGUAGE plpgsql;

-- 예제 290: 비교 분석 (YoY, MoM)
-- Example 290: Comparative analysis (YoY, MoM)
CREATE OR REPLACE FUNCTION comparative_period_analysis()
RETURNS TABLE (
    current_month DATE,
    current_month_value NUMERIC,
    previous_month_value NUMERIC,
    mom_change_percent NUMERIC,
    previous_year_value NUMERIC,
    yoy_change_percent NUMERIC
) AS $$
WITH monthly_data AS (
    SELECT
        DATE_TRUNC('month', changed_at)::DATE as month_start,
        COUNT(*)::NUMERIC as monthly_count
    FROM events_log
    WHERE changed_at >= NOW() - INTERVAL '24 months'
    GROUP BY DATE_TRUNC('month', changed_at)
)
SELECT
    m.month_start,
    m.monthly_count,
    LAG(m.monthly_count) OVER (ORDER BY m.month_start) as prev_month,
    ROUND(((m.monthly_count - LAG(m.monthly_count) OVER (ORDER BY m.month_start)) /
           LAG(m.monthly_count) OVER (ORDER BY m.month_start) * 100), 2) as mom_change,
    LAG(m.monthly_count, 12) OVER (ORDER BY m.month_start) as prev_year,
    ROUND(((m.monthly_count - LAG(m.monthly_count, 12) OVER (ORDER BY m.month_start)) /
           LAG(m.monthly_count, 12) OVER (ORDER BY m.month_start) * 100), 2) as yoy_change
FROM monthly_data m
ORDER BY m.month_start DESC
LIMIT 13;
$$ LANGUAGE plpgsql;

-- 예제 291: 세분화 분석
-- Example 291: Segmentation analysis
CREATE OR REPLACE FUNCTION customer_segmentation()
RETURNS TABLE (
    segment_name VARCHAR,
    customer_count INT,
    avg_order_value NUMERIC,
    total_revenue NUMERIC,
    segment_percentage NUMERIC
) AS $$
WITH customer_stats AS (
    SELECT
        u.id,
        COUNT(o.id) as order_count,
        COALESCE(SUM(o.total_amount), 0) as lifetime_value,
        COALESCE(AVG(o.total_amount), 0) as avg_order_value
    FROM users u
    LEFT JOIN orders o ON u.id = o.user_id
    GROUP BY u.id
),
segmented AS (
    SELECT
        CASE
            WHEN lifetime_value = 0 THEN 'Inactive'
            WHEN lifetime_value > 10000 AND order_count > 20 THEN 'VIP'
            WHEN lifetime_value > 5000 AND order_count > 10 THEN 'Premium'
            WHEN lifetime_value > 1000 THEN 'Regular'
            ELSE 'New'
        END as segment,
        id,
        avg_order_value,
        lifetime_value
    FROM customer_stats
)
SELECT
    segment::VARCHAR,
    COUNT(*)::INT,
    ROUND(AVG(avg_order_value), 2)::NUMERIC,
    ROUND(SUM(lifetime_value), 2)::NUMERIC,
    ROUND((COUNT(*)::NUMERIC / (SELECT COUNT(*) FROM segmented) * 100), 2)::NUMERIC
FROM segmented
GROUP BY segment
ORDER BY SUM(lifetime_value) DESC;
$$ LANGUAGE plpgsql;

-- 예제 292: 이탈 분석
-- Example 292: Churn analysis
CREATE OR REPLACE FUNCTION churn_prediction()
RETURNS TABLE (
    user_id INT,
    last_activity_days INT,
    order_frequency_90days INT,
    churn_risk_score NUMERIC,
    churn_likelihood VARCHAR
) AS $$
WITH user_activity AS (
    SELECT
        u.id,
        EXTRACT(DAY FROM NOW() - MAX(o.created_at))::INT as days_since_last_order,
        COUNT(o.id) FILTER (WHERE o.created_at >= NOW() - INTERVAL '90 days')::INT as orders_in_90days
    FROM users u
    LEFT JOIN orders o ON u.id = o.user_id
    WHERE u.created_at < NOW() - INTERVAL '90 days'
    GROUP BY u.id
)
SELECT
    id,
    days_since_last_order,
    orders_in_90days,
    ROUND((days_since_last_order::NUMERIC / 30 * (5 - orders_in_90days)), 2) as risk_score,
    CASE
        WHEN days_since_last_order > 180 AND orders_in_90days = 0 THEN 'High'
        WHEN days_since_last_order > 90 AND orders_in_90days < 2 THEN 'Medium'
        ELSE 'Low'
    END as churn_likelihood
FROM user_activity
WHERE days_since_last_order > 30
ORDER BY days_since_last_order DESC;
$$ LANGUAGE plpgsql;

-- 예제 293: 자동 리포팅 생성
-- Example 293: Automated report generation
CREATE TABLE IF NOT EXISTS scheduled_reports (
    report_id SERIAL PRIMARY KEY,
    report_name VARCHAR(255) NOT NULL,
    report_type VARCHAR(50),
    schedule_frequency VARCHAR(50),
    last_generated TIMESTAMP,
    next_scheduled TIMESTAMP,
    status VARCHAR(20) DEFAULT 'enabled'
);

-- 예제 294: 리포트 배포
-- Example 294: Report distribution
CREATE TABLE IF NOT EXISTS report_recipients (
    recipient_id SERIAL PRIMARY KEY,
    report_id INT REFERENCES scheduled_reports(report_id),
    recipient_email VARCHAR(255),
    notification_method VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 예제 295: 커스텀 대시보드 데이터
-- Example 295: Custom dashboard data
CREATE OR REPLACE FUNCTION get_dashboard_summary()
RETURNS TABLE (
    metric_key VARCHAR,
    metric_label VARCHAR,
    metric_value NUMERIC,
    previous_period_value NUMERIC,
    change_percent NUMERIC,
    trend VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT 'total_users'::VARCHAR, 'Total Users'::VARCHAR,
           COUNT(*)::NUMERIC,
           LAG(COUNT(*)) OVER ()::NUMERIC,
           ROUND(((COUNT(*) - LAG(COUNT(*)) OVER ()) / LAG(COUNT(*)) OVER () * 100), 2)::NUMERIC,
           'up'::VARCHAR
    FROM users;
END;
$$ LANGUAGE plpgsql;

-- 예제 296-300: 추가 분석 함수들
-- Examples 296-300: Additional analytics functions

-- 예제 296: 다차원 분석 큐브
-- Example 296: Multi-dimensional analysis cube
CREATE OR REPLACE FUNCTION olap_cube()
RETURNS TABLE (
    region VARCHAR,
    product_category VARCHAR,
    year INT,
    month INT,
    sales_amount NUMERIC,
    order_count INT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        sp.region::VARCHAR,
        'product_category'::VARCHAR,
        EXTRACT(YEAR FROM sp.order_date)::INT,
        EXTRACT(MONTH FROM sp.order_date)::INT,
        SUM(sp.amount)::NUMERIC,
        COUNT(*)::INT
    FROM sales_partitioned sp
    GROUP BY sp.region, EXTRACT(YEAR FROM sp.order_date), EXTRACT(MONTH FROM sp.order_date);
END;
$$ LANGUAGE plpgsql;

-- 예제 297: 분산 분석
-- Example 297: Distribution analysis
CREATE OR REPLACE FUNCTION distribution_analysis(p_table VARCHAR, p_column VARCHAR)
RETURNS TABLE (
    min_value NUMERIC,
    q1_value NUMERIC,
    median_value NUMERIC,
    q3_value NUMERIC,
    max_value NUMERIC,
    std_dev NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    EXECUTE format('
        SELECT
            MIN(%I)::NUMERIC,
            PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY %I)::NUMERIC,
            PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY %I)::NUMERIC,
            PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY %I)::NUMERIC,
            MAX(%I)::NUMERIC,
            ROUND(STDDEV(%I), 2)::NUMERIC
        FROM %I
    ', p_column, p_column, p_column, p_column, p_column, p_column, p_table);
END;
$$ LANGUAGE plpgsql;

-- 예제 298: 모멘트 계산
-- Example 298: Statistical moments
CREATE OR REPLACE FUNCTION calculate_moments(p_column VARCHAR, p_table VARCHAR)
RETURNS TABLE (
    mean_value NUMERIC,
    variance NUMERIC,
    skewness NUMERIC,
    kurtosis NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    EXECUTE format('
        SELECT
            ROUND(AVG(%I), 4)::NUMERIC,
            ROUND(VARIANCE(%I), 4)::NUMERIC,
            0::NUMERIC,
            0::NUMERIC
        FROM %I
    ', p_column, p_column, p_table);
END;
$$ LANGUAGE plpgsql;

-- 예제 299: 클러스터링 준비
-- Example 299: Clustering preparation
CREATE OR REPLACE FUNCTION prepare_clustering_data()
RETURNS TABLE (
    user_id INT,
    feature_1 NUMERIC,
    feature_2 NUMERIC,
    feature_3 NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        u.id,
        COUNT(o.id)::NUMERIC as orders_count,
        COALESCE(SUM(o.total_amount), 0)::NUMERIC as total_spent,
        EXTRACT(DAY FROM NOW() - MAX(o.created_at))::NUMERIC as days_since_purchase
    FROM users u
    LEFT JOIN orders o ON u.id = o.user_id
    GROUP BY u.id;
END;
$$ LANGUAGE plpgsql;

-- 예제 300: 종합 KPI 대시보드
-- Example 300: Comprehensive KPI dashboard
CREATE OR REPLACE FUNCTION comprehensive_kpi_dashboard()
RETURNS TABLE (
    kpi_category VARCHAR,
    kpi_name VARCHAR,
    kpi_value NUMERIC,
    target_value NUMERIC,
    variance_percent NUMERIC,
    status VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT 'Sales'::VARCHAR, 'Monthly Revenue'::VARCHAR,
           (SELECT SUM(amount) FROM sales_partitioned WHERE DATE(order_date) >= DATE_TRUNC('month', NOW()))::NUMERIC,
           100000::NUMERIC,
           ROUND(((SELECT SUM(amount) FROM sales_partitioned WHERE DATE(order_date) >= DATE_TRUNC('month', NOW())) / 100000 - 1) * 100, 2)::NUMERIC,
           'In Progress'::VARCHAR
    UNION ALL
    SELECT 'Users'::VARCHAR, 'Active Users'::VARCHAR,
           COUNT(*)::NUMERIC, 10000::NUMERIC,
           ROUND((COUNT(*)::NUMERIC / 10000 - 1) * 100, 2)::NUMERIC,
           'On Track'::VARCHAR
    FROM users WHERE is_active = true;
END;
$$ LANGUAGE plpgsql;

-- 마무리 정보
-- Cleanup information
COMMIT;
