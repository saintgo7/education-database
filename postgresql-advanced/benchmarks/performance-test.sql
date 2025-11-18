-- PostgreSQL Performance Benchmarks
-- Tests query performance with and without optimization

-- Setup: Enable timing
\timing on

-- ============================================
-- Benchmark 1: Index vs Sequential Scan
-- ============================================

\echo '=== Benchmark 1: Index vs Sequential Scan ==='

-- Sequential scan (disable index)
SET enable_indexscan = OFF;
SET enable_bitmapscan = OFF;

SELECT * FROM users WHERE email = 'user_100@example.com';

-- Index scan (enable index)
SET enable_indexscan = ON;
SET enable_bitmapscan = ON;

SELECT * FROM users WHERE email = 'user_100@example.com';

-- ============================================
-- Benchmark 2: JOIN Performance
-- ============================================

\echo ''
\echo '=== Benchmark 2: JOIN Performance ==='

-- Test without statistics
ANALYZE users, orders;

-- Simple JOIN
SELECT COUNT(*)
FROM users u
JOIN orders o ON u.user_id = o.user_id;

-- JOIN with WHERE clause
SELECT COUNT(*)
FROM users u
JOIN orders o ON u.user_id = o.user_id
WHERE u.status = 'active';

-- Multiple JOINs
SELECT COUNT(*)
FROM users u
JOIN orders o ON u.user_id = o.user_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id;

-- ============================================
-- Benchmark 3: Aggregation Performance
-- ============================================

\echo ''
\echo '=== Benchmark 3: Aggregation Performance ==='

-- Simple COUNT
SELECT COUNT(*) FROM orders;

-- GROUP BY with aggregation
SELECT
    status,
    COUNT(*) as count,
    AVG(total_amount) as avg_amount,
    SUM(total_amount) as total_amount
FROM orders
GROUP BY status;

-- Complex aggregation with JOIN
SELECT
    p.category,
    COUNT(DISTINCT oi.order_id) as orders,
    SUM(oi.quantity) as total_quantity,
    SUM(oi.subtotal) as revenue
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY p.category
ORDER BY revenue DESC;

-- ============================================
-- Benchmark 4: Subquery vs JOIN
-- ============================================

\echo ''
\echo '=== Benchmark 4: Subquery vs JOIN ==='

-- Subquery with IN
SELECT *
FROM products
WHERE product_id IN (
    SELECT DISTINCT product_id
    FROM order_items
);

-- JOIN alternative
SELECT DISTINCT p.*
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id;

-- EXISTS alternative (usually fastest)
SELECT p.*
FROM products p
WHERE EXISTS (
    SELECT 1
    FROM order_items oi
    WHERE oi.product_id = p.product_id
);

-- ============================================
-- Benchmark 5: JSONB Operations
-- ============================================

\echo ''
\echo '=== Benchmark 5: JSONB Operations ==='

-- JSONB contains query (with GIN index)
SELECT COUNT(*)
FROM users
WHERE preferences @> '{"theme": "dark"}';

-- JSONB key exists
SELECT COUNT(*)
FROM users
WHERE preferences ? 'theme';

-- JSONB extraction
SELECT
    username,
    preferences->>'theme' as theme
FROM users
WHERE preferences IS NOT NULL
LIMIT 1000;

-- ============================================
-- Benchmark 6: Full-Text Search
-- ============================================

\echo ''
\echo '=== Benchmark 6: Full-Text Search ==='

-- ILIKE without index
SELECT COUNT(*)
FROM products
WHERE name ILIKE '%laptop%';

-- ILIKE with trigram index
SELECT COUNT(*)
FROM products
WHERE name ILIKE '%laptop%';

-- Full-text search with ts_vector
SELECT COUNT(*)
FROM products
WHERE to_tsvector('english', name) @@ to_tsquery('english', 'laptop');

-- ============================================
-- Benchmark 7: Window Functions
-- ============================================

\echo ''
\echo '=== Benchmark 7: Window Functions ==='

-- Row number
SELECT
    username,
    created_at,
    ROW_NUMBER() OVER (ORDER BY created_at) as row_num
FROM users
LIMIT 1000;

-- Running total
SELECT
    order_id,
    total_amount,
    SUM(total_amount) OVER (ORDER BY created_at) as running_total
FROM orders
LIMIT 1000;

-- Rank within partition
SELECT
    name,
    category,
    price,
    RANK() OVER (PARTITION BY category ORDER BY price DESC) as rank
FROM products
WHERE category IS NOT NULL;

-- ============================================
-- Benchmark 8: CTE Performance
-- ============================================

\echo ''
\echo '=== Benchmark 8: CTE Performance ==='

-- Simple CTE
WITH recent_orders AS (
    SELECT * FROM orders
    WHERE created_at >= CURRENT_DATE - INTERVAL '30 days'
)
SELECT COUNT(*) FROM recent_orders;

-- CTE with JOIN
WITH user_orders AS (
    SELECT
        user_id,
        COUNT(*) as order_count,
        SUM(total_amount) as total_spent
    FROM orders
    GROUP BY user_id
)
SELECT
    u.username,
    uo.order_count,
    uo.total_spent
FROM users u
JOIN user_orders uo ON u.user_id = uo.user_id
ORDER BY uo.total_spent DESC
LIMIT 10;

-- ============================================
-- Benchmark 9: Batch Insert Performance
-- ============================================

\echo ''
\echo '=== Benchmark 9: Batch Insert Performance ==='

-- Create temp table for testing
CREATE TEMP TABLE temp_test (
    id SERIAL PRIMARY KEY,
    data TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Single-row inserts (slow)
DO $$
BEGIN
    FOR i IN 1..100 LOOP
        INSERT INTO temp_test (data) VALUES ('test_' || i);
    END LOOP;
END $$;

-- Batch insert (fast)
INSERT INTO temp_test (data)
SELECT 'test_batch_' || generate_series
FROM generate_series(1, 1000);

-- Multi-row VALUES insert
INSERT INTO temp_test (data) VALUES
    ('multi_1'),
    ('multi_2'),
    ('multi_3'),
    ('multi_4'),
    ('multi_5');

DROP TABLE temp_test;

-- ============================================
-- Benchmark 10: Connection Pooling Impact
-- ============================================

\echo ''
\echo '=== Benchmark 10: Query Plan Cache ==='

-- First execution (cold)
PREPARE user_query AS
SELECT * FROM users WHERE email = $1;

EXECUTE user_query('user_100@example.com');

-- Subsequent executions (warm)
EXECUTE user_query('user_200@example.com');
EXECUTE user_query('user_300@example.com');

DEALLOCATE user_query;

-- ============================================
-- Performance Summary
-- ============================================

\echo ''
\echo '=== Performance Summary ==='

-- Query statistics
SELECT
    queryid,
    query,
    calls,
    total_exec_time,
    mean_exec_time,
    max_exec_time
FROM pg_stat_statements
ORDER BY mean_exec_time DESC
LIMIT 10;

-- Index usage
SELECT
    schemaname,
    tablename,
    indexname,
    idx_scan,
    idx_tup_read,
    idx_tup_fetch
FROM pg_stat_user_indexes
WHERE schemaname = 'public'
ORDER BY idx_scan DESC
LIMIT 10;

-- Cache hit ratio
SELECT
    schemaname,
    tablename,
    heap_blks_read,
    heap_blks_hit,
    CASE
        WHEN heap_blks_hit + heap_blks_read = 0 THEN 0
        ELSE ROUND(100.0 * heap_blks_hit / (heap_blks_hit + heap_blks_read), 2)
    END as cache_hit_ratio
FROM pg_statio_user_tables
WHERE schemaname = 'public'
ORDER BY heap_blks_read DESC;

\timing off
