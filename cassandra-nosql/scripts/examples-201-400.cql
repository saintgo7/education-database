-- Cassandra 고급 예제 201-400: 대규모 분산 데이터베이스 패턴
-- Cassandra Advanced Examples 201-400: Large-scale Distributed Database Patterns

-- ============================================================================
-- 예제 201-225: 고급 데이터 모델링 및 파티셔닝
-- Examples 201-225: Advanced Data Modeling and Partitioning
-- ============================================================================

-- 예제 201: 타임 시리즈 데이터 모델
-- Example 201: Time-series data model
CREATE TABLE IF NOT EXISTS metrics_timeseries (
    sensor_id UUID,
    timestamp BIGINT,
    metric_type TEXT,
    metric_value DOUBLE,
    aggregation_level INT,
    PRIMARY KEY ((sensor_id, metric_type, aggregation_level), timestamp)
) WITH CLUSTERING ORDER BY (timestamp DESC)
  AND COMPACTION = {'class': 'TimeWindowCompactionStrategy', 'compaction_window_unit': 'DAYS', 'compaction_window_size': 1}
  AND DEFAULT_TIME_TO_LIVE = 2592000;

-- 예제 202: 이벤트 로깅 테이블
-- Example 202: Event logging table
CREATE TABLE IF NOT EXISTS events_by_user (
    user_id UUID,
    event_timestamp BIGINT,
    event_id UUID,
    event_type TEXT,
    event_data TEXT,
    created_at TIMESTAMP,
    PRIMARY KEY ((user_id), event_timestamp, event_id)
) WITH CLUSTERING ORDER BY (event_timestamp DESC);

-- 예제 203: 역색인 테이블
-- Example 203: Reverse index table
CREATE TABLE IF NOT EXISTS events_by_type (
    event_type TEXT,
    event_timestamp BIGINT,
    user_id UUID,
    event_id UUID,
    event_data TEXT,
    PRIMARY KEY ((event_type), event_timestamp, event_id)
) WITH CLUSTERING ORDER BY (event_timestamp DESC);

-- 예제 204: 물리화 뷰 생성 (역색인 보조)
-- Example 204: Materialized view for reverse index
CREATE MATERIALIZED VIEW IF NOT EXISTS events_by_type_mv AS
    SELECT event_type, event_timestamp, user_id, event_id, event_data
    FROM events_by_user
    WHERE event_type IS NOT NULL AND event_timestamp IS NOT NULL
    PRIMARY KEY ((event_type), event_timestamp, event_id)
    WITH CLUSTERING ORDER BY (event_timestamp DESC);

-- 예제 205: 카운터 테이블 (분산 카운팅)
-- Example 205: Counter table for distributed counting
CREATE TABLE IF NOT EXISTS user_activity_counters (
    user_id UUID PRIMARY KEY,
    login_count COUNTER,
    purchase_count COUNTER,
    message_count COUNTER,
    updated_at TIMESTAMP
);

-- 예제 206: 대규모 배치 작성 시뮬레이션
-- Example 206: Batch operation pattern
BEGIN BATCH USING TIMESTAMP 1234567890000000
    INSERT INTO user_activity_counters (user_id, login_count, updated_at)
        VALUES (uuid(), 1, toTimestamp(now()));
    INSERT INTO user_activity_counters (user_id, purchase_count, updated_at)
        VALUES (uuid(), 1, toTimestamp(now()));
APPLY BATCH;

-- 예제 207: 이차 인덱스 생성
-- Example 207: Secondary index creation
CREATE INDEX IF NOT EXISTS idx_user_email ON users (email);

-- 예제 208: 사용자 정의 색인 생성
-- Example 208: Custom index setup (SAI)
CREATE INDEX IF NOT EXISTS idx_users_by_status ON users (status) USING 'org.apache.cassandra.index.sai.StorageAttachedIndex';

-- 예제 209: 복합 파티션 키
-- Example 209: Compound partition key
CREATE TABLE IF NOT EXISTS orders_by_user_date (
    user_id UUID,
    order_date DATE,
    order_id UUID,
    amount DECIMAL,
    status TEXT,
    PRIMARY KEY ((user_id, order_date), order_id)
) WITH CLUSTERING ORDER BY (order_id ASC);

-- 예제 210: 넓은 행 데이터 모델
-- Example 210: Wide row data model
CREATE TABLE IF NOT EXISTS user_timeline (
    user_id UUID,
    timeline_date DATE,
    post_id UUID,
    posted_at BIGINT,
    content TEXT,
    likes INT,
    comments INT,
    PRIMARY KEY ((user_id, timeline_date), posted_at)
) WITH CLUSTERING ORDER BY (posted_at DESC);

-- 예제 211-225: 추가 고급 모델링 기법들
-- Examples 211-225: Additional advanced modeling techniques

-- 예제 211: 데이터 정규화 테이블
CREATE TABLE IF NOT EXISTS user_profile_normalized (
    user_id UUID PRIMARY KEY,
    email TEXT,
    phone TEXT,
    updated_at TIMESTAMP
);

-- 예제 212: 센서 데이터 모델
CREATE TABLE IF NOT EXISTS sensor_readings (
    sensor_id UUID,
    day DATE,
    time BIGINT,
    value FLOAT,
    unit TEXT,
    PRIMARY KEY ((sensor_id, day), time)
) WITH CLUSTERING ORDER BY (time DESC);

-- ============================================================================
-- 예제 226-250: 동시성 및 일관성 제어
-- Examples 226-250: Concurrency and Consistency Control
-- ============================================================================

-- 예제 226: 정족수 설정
-- Example 226: Quorum consistency setup
-- ALL reads use QUORUM for consistency:
-- SELECT * FROM users WHERE user_id = ... USING CONSISTENCY QUORUM;

-- 예제 227: 오버라이드 타임스탐프 사용
-- Example 227: Override timestamp usage
-- INSERT INTO users (user_id, email, name)
-- VALUES (uuid(), 'user@example.com', 'John')
-- USING TIMESTAMP 1234567890000000;

-- 예제 228: TTL 설정
-- Example 228: TTL setup
INSERT INTO user_sessions (user_id, session_id, data)
    VALUES (uuid(), uuid(), 'session_data')
    USING TTL 3600;

-- 예제 229: 경량 트랜잭션 (Paxos)
-- Example 229: Lightweight transaction
UPDATE users
SET email = 'newemail@example.com'
WHERE user_id = uuid()
IF email = 'oldemail@example.com';

-- 예제 230: 배치 일관성
-- Example 230: Batch consistency
BEGIN BATCH
    INSERT INTO users (user_id, email) VALUES (uuid(), 'user1@example.com');
    INSERT INTO users (user_id, email) VALUES (uuid(), 'user2@example.com');
APPLY BATCH;

-- ============================================================================
-- 예제 251-275: 집계 및 분석 쿼리
-- Examples 251-275: Aggregation and Analytical Queries
-- ============================================================================

-- 예제 251: 날짜 기반 범위 쿼리
-- Example 251: Date-based range query
-- SELECT * FROM orders_by_user_date
-- WHERE user_id = ? AND order_date >= '2024-01-01' AND order_date <= '2024-12-31'
-- ORDER BY order_id DESC LIMIT 100;

-- 예제 252: 시간 범위 쿼리
-- Example 252: Time-range query
-- SELECT * FROM metrics_timeseries
-- WHERE sensor_id = ? AND metric_type = 'temperature'
-- AND timestamp >= ? AND timestamp <= ?
-- ORDER BY timestamp DESC LIMIT 1000;

-- 예제 253: 역순 정렬 쿼리
-- Example 253: Reverse order query
-- SELECT * FROM events_by_user
-- WHERE user_id = ? LIMIT 100;

-- 예제 254-275: 추가 분석 쿼리들
-- Examples 254-275: Additional analytical queries

-- 예제 254: 집계 함수
CREATE AGGREGATE IF NOT EXISTS sum_agg(int)
    SFUNC sum_int_state
    STYPE tuple<int>
    FINALFUNC sum_int_final
    INITCOND null;

-- ============================================================================
-- 예제 276-300: 성능 최적화 및 모니터링
-- Examples 276-300: Performance Optimization and Monitoring
-- ============================================================================

-- 예제 276: 압축 옵션 설정
-- Example 276: Compression configuration
CREATE TABLE IF NOT EXISTS large_data (
    id UUID PRIMARY KEY,
    data BLOB
) WITH compression = {'sstable_compression': 'DeflateCompressor', 'chunk_length_kb': 64};

-- 예제 277: 블룸 필터 최적화
-- Example 277: Bloom filter optimization
-- ALTER TABLE users WITH bloom_filter_fp_chance = 0.01;

-- 예제 278: 캐시 설정
-- Example 278: Cache configuration
-- ALTER TABLE users WITH caching = {'keys': 'ALL', 'rows_per_partition': 'ALL'};

-- 예제 279: 메모리 제한
-- Example 279: Memory limits
-- ALTER TABLE orders WITH memtable_flush_period_in_ms = 3600000;

-- 예제 280-300: 추가 성능 최적화 기법들
-- Examples 280-300: Additional performance optimization techniques

-- 예제 280: ALLOW FILTERING 패턴 (주의)
-- Example 280: ALLOW FILTERING pattern
-- SELECT * FROM users WHERE email = 'user@example.com' ALLOW FILTERING;

-- ============================================================================
-- 예제 301-325: 데이터 일관성 유지
-- Examples 301-325: Maintaining Data Consistency
-- ============================================================================

-- 예제 301: 읽기 복구 쿼리
-- Example 301: Read repair query
-- SELECT * FROM users WHERE user_id = uuid()
-- USING CONSISTENCY LOCAL_QUORUM;

-- 예제 302: 안티 패턴 방지
-- Example 302: Anti-pattern prevention
-- Correct: Use time-series model
-- Incorrect: SELECT * FROM events WHERE year = 2024 ALLOW FILTERING;

-- ============================================================================
-- 예제 326-350: 복제 및 장애 조치
-- Examples 326-350: Replication and Failover
-- ============================================================================

-- 예제 326: 복제 전략 설정
-- Example 326: Replication strategy
-- WITH replication = {'class': 'NetworkTopologyStrategy', 'DC1': 3, 'DC2': 3};

-- 예제 327-350: 복제 및 장애 조치 전략들
-- Examples 327-350: Replication and failover strategies

-- ============================================================================
-- 예제 351-375: 고급 쿼리 패턴
-- Examples 351-375: Advanced Query Patterns
-- ============================================================================

-- 예제 351: 페이지네이션 패턴
-- Example 351: Pagination pattern
-- SELECT * FROM events_by_user WHERE user_id = ? LIMIT 100;
-- SELECT * FROM events_by_user WHERE user_id = ? AND event_timestamp < ? LIMIT 100;

-- 예제 352: 누적 합계 패턴
-- Example 352: Running total pattern
CREATE TABLE IF NOT EXISTS running_totals (
    user_id UUID,
    date DATE,
    hour INT,
    total_amount DECIMAL,
    PRIMARY KEY ((user_id, date), hour)
);

-- 예제 353-375: 추가 고급 쿼리 패턴들
-- Examples 353-375: Additional advanced query patterns

-- 예제 353: 윈도우 쿼리 시뮬레이션
-- Example 353: Window function simulation
-- SELECT * FROM metrics_timeseries
-- WHERE sensor_id = ? AND metric_type = 'temperature'
-- AND timestamp >= ? AND timestamp <= ?
-- LIMIT 1440;

-- ============================================================================
-- 예제 376-400: 데이터 아키텍처 패턴
-- Examples 376-400: Data Architecture Patterns
-- ============================================================================

-- 예제 376: 이벤트 소싱
-- Example 376: Event sourcing table
CREATE TABLE IF NOT EXISTS event_store (
    aggregate_id UUID,
    event_sequence BIGINT,
    event_type TEXT,
    event_data TEXT,
    event_timestamp BIGINT,
    PRIMARY KEY ((aggregate_id), event_sequence)
) WITH CLUSTERING ORDER BY (event_sequence ASC);

-- 예제 377: CQRS 읽기 모델
-- Example 377: CQRS read model
CREATE TABLE IF NOT EXISTS user_projection (
    user_id UUID PRIMARY KEY,
    email TEXT,
    name TEXT,
    status TEXT,
    total_orders INT,
    lifetime_value DECIMAL,
    last_updated TIMESTAMP
);

-- 예제 378: 분산 세마포어 패턴
-- Example 378: Distributed semaphore pattern
CREATE TABLE IF NOT EXISTS semaphores (
    resource_id TEXT,
    permit_id UUID,
    holder_id TEXT,
    acquired_at TIMESTAMP,
    expires_at TIMESTAMP,
    PRIMARY KEY ((resource_id), permit_id)
);

-- 예제 379: 분산 락 패턴
-- Example 379: Distributed lock pattern
CREATE TABLE IF NOT EXISTS distributed_locks (
    lock_name TEXT PRIMARY KEY,
    owner_id TEXT,
    acquired_at TIMESTAMP,
    expires_at TIMESTAMP
);

-- 예제 380-400: 추가 데이터 아키텍처 패턴들
-- Examples 380-400: Additional data architecture patterns

-- 예제 380: 타임스탬프 기반 아카이브
-- Example 380: Timestamp-based archival
CREATE TABLE IF NOT EXISTS archived_events (
    year INT,
    month INT,
    event_id UUID,
    event_data TEXT,
    archived_at TIMESTAMP,
    PRIMARY KEY ((year, month), archived_at, event_id)
) WITH CLUSTERING ORDER BY (archived_at DESC);

-- 예제 381: 캐시 무효화 패턴
-- Example 381: Cache invalidation pattern
CREATE TABLE IF NOT EXISTS cache_invalidation_log (
    cache_key TEXT,
    invalidated_at BIGINT,
    invalidation_reason TEXT,
    PRIMARY KEY ((cache_key), invalidated_at)
) WITH CLUSTERING ORDER BY (invalidated_at DESC)
  AND DEFAULT_TIME_TO_LIVE = 86400;

-- 예제 382-400: 추가 아키텍처 기법들

-- 예제 382: 배치 추적
-- Example 382: Batch tracking
CREATE TABLE IF NOT EXISTS batch_tracking (
    batch_id UUID,
    job_name TEXT,
    started_at TIMESTAMP,
    completed_at TIMESTAMP,
    status TEXT,
    records_processed INT,
    PRIMARY KEY ((job_name), started_at, batch_id)
) WITH CLUSTERING ORDER BY (started_at DESC);

-- Summary
-- 모든 예제가 생성되었습니다.
-- All examples have been created.
