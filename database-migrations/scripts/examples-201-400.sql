-- Database Migrations 고급 예제 201-400: 스키마 진화 및 마이그레이션 패턴
-- Database Migrations Advanced Examples 201-400: Schema Evolution and Migration Patterns

-- ============================================================================
-- 예제 201-225: 복잡한 스키마 변경
-- Examples 201-225: Complex Schema Changes
-- ============================================================================

-- 예제 201: 컬럼 분리 (Column Splitting)
-- Example 201: Column splitting migration
BEGIN;
-- Step 1: Add new columns
ALTER TABLE users ADD COLUMN first_name VARCHAR(100);
ALTER TABLE users ADD COLUMN last_name VARCHAR(100);

-- Step 2: Migrate data
UPDATE users
SET first_name = SPLIT_PART(full_name, ' ', 1),
    last_name = SPLIT_PART(full_name, ' ', 2)
WHERE full_name IS NOT NULL;

-- Step 3: Add NOT NULL constraint if data is complete
-- ALTER TABLE users ALTER COLUMN first_name SET NOT NULL;
-- Step 4: Drop old column (with proper backup)
-- ALTER TABLE users DROP COLUMN full_name;
COMMIT;

-- 예제 202: 컬럼 병합 (Column Merging)
-- Example 202: Column merging migration
BEGIN;
-- Step 1: Add new column
ALTER TABLE users ADD COLUMN full_name VARCHAR(200);

-- Step 2: Migrate data
UPDATE users
SET full_name = CONCAT(first_name, ' ', last_name)
WHERE first_name IS NOT NULL OR last_name IS NOT NULL;

-- Step 3: Create index on new column
CREATE INDEX idx_users_full_name ON users (full_name);

-- Step 4: Drop old columns (after verification)
-- ALTER TABLE users DROP COLUMN first_name;
-- ALTER TABLE users DROP COLUMN last_name;
COMMIT;

-- 예제 203: 데이터 타입 변경
-- Example 203: Data type conversion
BEGIN;
-- Step 1: Create new column with target type
ALTER TABLE orders ADD COLUMN amount_new NUMERIC(10,2);

-- Step 2: Migrate data
UPDATE orders
SET amount_new = amount::NUMERIC(10,2)
WHERE amount IS NOT NULL;

-- Step 3: Verify data integrity
-- SELECT COUNT(*) FROM orders WHERE amount_new IS NULL AND amount IS NOT NULL;

-- Step 4: Drop old column and rename
-- ALTER TABLE orders DROP COLUMN amount;
-- ALTER TABLE orders RENAME COLUMN amount_new TO amount;
COMMIT;

-- 예제 204: 테이블 정규화 (Table Normalization)
-- Example 204: Table normalization
BEGIN;
-- Step 1: Create new table
CREATE TABLE IF NOT EXISTS product_categories (
    id SERIAL PRIMARY KEY,
    category_name VARCHAR(100) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Step 2: Insert distinct values
INSERT INTO product_categories (category_name)
SELECT DISTINCT category FROM products
WHERE category IS NOT NULL
ON CONFLICT DO NOTHING;

-- Step 3: Add foreign key column to products
ALTER TABLE products ADD COLUMN category_id INT;

-- Step 4: Migrate data
UPDATE products
SET category_id = (
    SELECT id FROM product_categories
    WHERE product_categories.category_name = products.category
);

-- Step 5: Add constraint
-- ALTER TABLE products ADD CONSTRAINT fk_products_category
-- FOREIGN KEY (category_id) REFERENCES product_categories(id);

-- Step 6: Drop old column
-- ALTER TABLE products DROP COLUMN category;
COMMIT;

-- 예제 205: 역정규화 (Denormalization)
-- Example 205: Denormalization for performance
BEGIN;
-- Step 1: Add denormalized column
ALTER TABLE orders ADD COLUMN customer_email VARCHAR(255);

-- Step 2: Populate with current data
UPDATE orders o
SET customer_email = u.email
FROM users u
WHERE o.user_id = u.id;

-- Step 3: Create trigger to maintain consistency
CREATE OR REPLACE FUNCTION update_order_customer_email()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE orders
    SET customer_email = NEW.email
    WHERE user_id = NEW.id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Step 4: Create trigger
CREATE TRIGGER trg_user_email_update
AFTER UPDATE ON users
FOR EACH ROW
EXECUTE FUNCTION update_order_customer_email();

COMMIT;

-- 예제 206: 파티션 테이블로 마이그레이션
-- Example 206: Migrate to partitioned table
BEGIN;
-- Step 1: Create partitioned table
CREATE TABLE IF NOT EXISTS orders_partitioned (
    id BIGSERIAL,
    user_id INT,
    order_date DATE,
    amount DECIMAL(10,2),
    status VARCHAR(50),
    PRIMARY KEY (id, order_date)
) PARTITION BY RANGE (EXTRACT(YEAR FROM order_date));

-- Step 2: Create partitions
CREATE TABLE IF NOT EXISTS orders_2023 PARTITION OF orders_partitioned
    FOR VALUES FROM (2023) TO (2024);
CREATE TABLE IF NOT EXISTS orders_2024 PARTITION OF orders_partitioned
    FOR VALUES FROM (2024) TO (2025);

-- Step 3: Copy data
INSERT INTO orders_partitioned
SELECT * FROM orders;

-- Step 4: Verify counts
-- SELECT COUNT(*) FROM orders;
-- SELECT COUNT(*) FROM orders_partitioned;

-- Step 5: Swap tables
-- ALTER TABLE orders RENAME TO orders_old;
-- ALTER TABLE orders_partitioned RENAME TO orders;

COMMIT;

-- 예제 207-225: 추가 스키마 변경 패턴들
-- Examples 207-225: Additional schema change patterns

-- 예제 207: 제약조건 추가 (Constraint Addition)
-- Example 207: Add constraints with data validation
BEGIN;
-- Step 1: Add check constraint
ALTER TABLE products ADD CONSTRAINT check_price_positive
CHECK (price > 0);

-- Step 2: Add unique constraint
-- ALTER TABLE users ADD CONSTRAINT unique_email UNIQUE(email);

-- Step 3: Add not null constraint
-- ALTER TABLE orders ALTER COLUMN user_id SET NOT NULL;

COMMIT;

-- ============================================================================
-- 예제 226-250: 인덱스 전략 및 마이그레이션
-- Examples 226-250: Index Strategies and Migration
-- ============================================================================

-- 예제 226: 온라인 인덱스 생성
-- Example 226: Online index creation
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_orders_user_id
ON orders (user_id) INCLUDE (order_date, amount);

-- 예제 227: 인덱스 마이그레이션 (교체)
-- Example 227: Index migration (replacement)
BEGIN;
-- Step 1: Create new index
CREATE INDEX idx_products_name_new ON products (name ASC, price DESC)
INCLUDE (category_id);

-- Step 2: Verify performance
EXPLAIN ANALYZE
SELECT * FROM products WHERE name LIKE 'Samsung%'
ORDER BY price DESC LIMIT 10;

-- Step 3: Atomic swap
-- DROP INDEX idx_products_name;
-- ALTER INDEX idx_products_name_new RENAME TO idx_products_name;

COMMIT;

-- 예제 228: 부분 인덱스 마이그레이션
-- Example 228: Partial index migration
CREATE INDEX idx_active_users ON users (id)
WHERE is_active = true;

-- 예제 229: 표현식 인덱스 생성
-- Example 229: Expression-based index
CREATE INDEX idx_orders_month ON orders
(DATE_TRUNC('month', order_date));

-- 예제 230: BRIN 인덱스로 변경
-- Example 230: Migrate to BRIN index
CREATE INDEX idx_timeseries_brin ON metrics_timeseries
USING BRIN (measurement_time)
WITH (pages_per_range=128);

-- 예제 231-250: 추가 인덱스 전략들
-- Examples 231-250: Additional indexing strategies

-- 예제 231: 커버링 인덱스
-- Example 231: Covering index
CREATE INDEX idx_order_summary ON orders
(user_id, order_date DESC) INCLUDE (amount, status);

-- ============================================================================
-- 예제 251-275: 데이터 검증 및 일관성
-- Examples 251-275: Data Validation and Consistency
-- ============================================================================

-- 예제 251: 데이터 검증 전 마이그레이션
-- Example 251: Pre-migration data validation
BEGIN;
-- Step 1: Identify problematic records
SELECT user_id, COUNT(*) as duplicate_count
FROM orders
GROUP BY user_id
HAVING COUNT(*) > 1000;

-- Step 2: Check for null values in critical columns
SELECT COUNT(*) as null_users
FROM orders
WHERE user_id IS NULL;

-- Step 3: Validate data ranges
SELECT
    COUNT(*) as invalid_amounts
FROM orders
WHERE amount <= 0;

COMMIT;

-- 예제 252: 사전 및 사후 검증
-- Example 252: Before/after validation
BEGIN;
-- Step 1: Create validation table
CREATE TABLE IF NOT EXISTS migration_validation (
    id SERIAL PRIMARY KEY,
    step_name VARCHAR(100),
    record_count_before BIGINT,
    record_count_after BIGINT,
    validation_status VARCHAR(50),
    executed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Step 2: Record pre-migration state
INSERT INTO migration_validation (step_name, record_count_before)
SELECT 'data_migration', COUNT(*)
FROM orders;

-- Step 3: Perform migration
-- ... migration logic ...

-- Step 4: Verify post-migration
UPDATE migration_validation
SET record_count_after = (SELECT COUNT(*) FROM orders),
    validation_status = CASE
        WHEN (SELECT COUNT(*) FROM orders) = record_count_before THEN 'PASSED'
        ELSE 'FAILED'
    END
WHERE step_name = 'data_migration'
    AND validation_status IS NULL;

COMMIT;

-- 예제 253: 해시 기반 검증
-- Example 253: Hash-based validation
BEGIN;
-- Step 1: Create hash column
ALTER TABLE users ADD COLUMN data_hash VARCHAR(64);

-- Step 2: Calculate hash before migration
UPDATE users
SET data_hash = MD5(email || name || COALESCE(phone, ''))::text;

-- Step 3: After migration, recalculate and compare
-- SELECT COUNT(*) FROM users
-- WHERE data_hash != MD5(email || name || COALESCE(phone, ''))::text;

COMMIT;

-- 예제 254-275: 추가 검증 기법들
-- Examples 254-275: Additional validation techniques

-- 예제 254: 행 개수 검증
-- Example 254: Row count validation
SELECT
    schemaname,
    tablename,
    n_live_tup as live_rows,
    n_dead_tup as dead_rows,
    ROUND(100.0 * n_dead_tup / (n_live_tup + n_dead_tup), 2) as dead_ratio
FROM pg_stat_user_tables
WHERE n_live_tup > 0
ORDER BY dead_ratio DESC;

-- ============================================================================
-- 예제 276-300: 롤백 전략 및 안전 메커니즘
-- Examples 276-300: Rollback Strategies and Safety Mechanisms
-- ============================================================================

-- 예제 276: 세이프포인트를 사용한 부분 롤백
-- Example 276: Savepoint for partial rollback
BEGIN;
    INSERT INTO users (email, name) VALUES ('user1@example.com', 'User 1');
    SAVEPOINT sp1;

    INSERT INTO users (email, name) VALUES ('user2@example.com', 'User 2');
    SAVEPOINT sp2;

    -- If error occurs:
    -- ROLLBACK TO sp2;
    -- Resume from here

COMMIT;

-- 예제 277: 더블 라이트 (Double Write)
-- Example 277: Double write pattern for safety
BEGIN;
-- Step 1: Write to both old and new tables
INSERT INTO users_new (id, email, name)
SELECT id, email, name FROM users
WHERE id NOT IN (SELECT id FROM users_new);

-- Step 2: Verify counts match
-- SELECT COUNT(*) FROM users, (SELECT COUNT(*) FROM users_new);

-- Step 3: Switch traffic gradually
-- Update application to read from new table while writing to both

-- Step 4: Clean up old table
-- DELETE FROM users WHERE id IN (SELECT id FROM users_new);

COMMIT;

-- 예제 278: 섀도우 테이블 (Shadow Tables)
-- Example 278: Shadow table pattern
BEGIN;
-- Create shadow table
CREATE TABLE IF NOT EXISTS products_shadow AS
SELECT * FROM products WHERE FALSE;

-- Copy data
INSERT INTO products_shadow SELECT * FROM products;

-- Test queries
-- SELECT * FROM products_shadow WHERE category = 'Electronics' LIMIT 10;

-- Swap if successful
-- ALTER TABLE products RENAME TO products_old;
-- ALTER TABLE products_shadow RENAME TO products;

COMMIT;

-- 예제 279-300: 추가 안전 메커니즘들
-- Examples 279-300: Additional safety mechanisms

-- 예제 279: 감사 로그 (Audit Log)
-- Example 279: Audit log for migrations
CREATE TABLE IF NOT EXISTS migration_audit (
    id SERIAL PRIMARY KEY,
    table_name VARCHAR(100),
    operation VARCHAR(50),
    old_value TEXT,
    new_value TEXT,
    changed_by VARCHAR(100),
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 예제 280: 백업 검증
-- Example 280: Backup validation
BEGIN;
-- Create backup table
CREATE TABLE IF NOT EXISTS users_backup_20240101 AS
SELECT * FROM users;

-- Verify backup completeness
SELECT COUNT(*) as backup_count
FROM users_backup_20240101;

COMMIT;

-- ============================================================================
-- 예제 301-325: 성능 영향 최소화
-- Examples 301-325: Minimizing Performance Impact
-- ============================================================================

-- 예제 301: CONCURRENTLY로 인덱스 생성
-- Example 301: Non-blocking index creation
CREATE INDEX CONCURRENTLY idx_large_table_column
ON large_table(column_name);

-- 예제 302: 배치 업데이트
-- Example 302: Batch updates
CREATE OR REPLACE FUNCTION batch_update_users(batch_size INT DEFAULT 1000)
RETURNS void AS $$
DECLARE
    v_offset INT := 0;
    v_count INT := 0;
BEGIN
    LOOP
        UPDATE users
        SET updated_at = CURRENT_TIMESTAMP
        WHERE id IN (
            SELECT id FROM users
            WHERE updated_at < NOW() - INTERVAL '30 days'
            LIMIT batch_size
            OFFSET v_offset
        );

        v_count := ROW_COUNT;
        v_offset := v_offset + batch_size;

        IF v_count = 0 THEN
            EXIT;
        END IF;

        -- Add delay between batches
        PERFORM pg_sleep(0.1);
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- 예제 303: 대기 시간 없는 TRUNCATE
-- Example 303: Minimal downtime data refresh
BEGIN;
-- Step 1: Create new table
CREATE TABLE IF NOT EXISTS metrics_new AS
SELECT * FROM metrics WHERE FALSE;

-- Step 2: Load data
INSERT INTO metrics_new
SELECT * FROM metrics_source
WHERE date >= CURRENT_DATE - INTERVAL '365 days';

-- Step 3: Create indexes
CREATE INDEX idx_metrics_new_date ON metrics_new (date DESC);

-- Step 4: Atomic swap
LOCK TABLE metrics IN EXCLUSIVE MODE;
ALTER TABLE metrics RENAME TO metrics_old;
ALTER TABLE metrics_new RENAME TO metrics;
COMMIT;

-- 예제 304-325: 추가 성능 최적화 기법들
-- Examples 304-325: Additional performance optimization techniques

-- 예제 304: 병렬 테이블 스캔
-- Example 304: Parallel operations
SET max_parallel_workers_per_gather = 4;
UPDATE large_table
SET status = 'processed'
WHERE status = 'pending';
RESET max_parallel_workers_per_gather;

-- ============================================================================
-- 예제 326-400: 고급 마이그레이션 패턴
-- Examples 326-400: Advanced Migration Patterns
-- ============================================================================

-- 예제 326: 피처 플래그 기반 마이그레이션
-- Example 326: Feature flag migration pattern
BEGIN;
-- Create feature flag table
CREATE TABLE IF NOT EXISTS feature_flags (
    id SERIAL PRIMARY KEY,
    flag_name VARCHAR(100) UNIQUE,
    enabled BOOLEAN DEFAULT FALSE,
    rollout_percentage INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert migration flag
INSERT INTO feature_flags (flag_name, enabled, rollout_percentage)
VALUES ('new_user_table', FALSE, 0);

-- Update feature flag gradually
-- UPDATE feature_flags SET rollout_percentage = 10 WHERE flag_name = 'new_user_table';
-- UPDATE feature_flags SET rollout_percentage = 50 WHERE flag_name = 'new_user_table';
-- UPDATE feature_flags SET enabled = TRUE WHERE flag_name = 'new_user_table';

COMMIT;

-- 예제 327: 점진적 마이그레이션 (Gradual Cutover)
-- Example 327: Gradual migration
BEGIN;
-- Step 1: Create new table
CREATE TABLE IF NOT EXISTS users_v2 LIKE users;

-- Step 2: Dual write setup (handled in application)
-- Application writes to both users and users_v2

-- Step 3: Batch copy existing data
INSERT INTO users_v2
SELECT * FROM users
WHERE id NOT IN (SELECT id FROM users_v2);

-- Step 4: Read from new table for new users
-- Step 5: Verify data consistency
SELECT COUNT(*) FROM users
EXCEPT
SELECT COUNT(*) FROM users_v2;

COMMIT;

-- 예제 328-400: 최종 마이그레이션 패턴들
-- Examples 328-400: Final migration patterns

-- 예제 328: 마이그레이션 상태 추적
-- Example 328: Track migration progress
CREATE TABLE IF NOT EXISTS migration_progress (
    id SERIAL PRIMARY KEY,
    migration_name VARCHAR(100),
    total_records BIGINT,
    migrated_records BIGINT,
    status VARCHAR(50),
    started_at TIMESTAMP,
    completed_at TIMESTAMP,
    error_message TEXT
);

-- 모든 예제 생성 완료
-- All examples completed
