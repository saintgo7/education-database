-- Index Optimization Examples
-- Demonstrates different index types and their usage

-- 1. B-tree Index (Default) - Best for equality and range queries
-- ================================================================

-- Query without index (SLOW)
EXPLAIN ANALYZE
SELECT * FROM users WHERE email = 'user_100@example.com';
-- Uses Seq Scan - reads all rows

-- Query with B-tree index (FAST)
-- Already have: CREATE INDEX idx_users_email ON users(email);
EXPLAIN ANALYZE
SELECT * FROM users WHERE email = 'user_100@example.com';
-- Uses Index Scan - directly finds the row

-- Range query with B-tree index
EXPLAIN ANALYZE
SELECT * FROM products WHERE price BETWEEN 500 AND 1000
ORDER BY price;
-- Uses Index Scan on idx_products_price

-- 2. Composite Index - Multiple columns
-- ======================================

-- Query that benefits from composite index
EXPLAIN ANALYZE
SELECT * FROM orders
WHERE user_id = (SELECT user_id FROM users LIMIT 1)
  AND status = 'delivered';
-- Uses idx_orders_user_status (user_id, status)

-- Order matters in composite indexes
EXPLAIN ANALYZE
SELECT * FROM orders WHERE status = 'pending';
-- Can still use the index for the second column

-- 3. Partial Index - Index subset of rows
-- ========================================

-- Query that uses partial index
EXPLAIN ANALYZE
SELECT * FROM orders
WHERE status = 'pending'
ORDER BY created_at;
-- Uses idx_orders_pending (partial index)

-- Query outside partial index scope
EXPLAIN ANALYZE
SELECT * FROM orders
WHERE status = 'delivered'
ORDER BY created_at;
-- Uses different index or seq scan

-- 4. GIN Index - Full-text search and JSONB
-- ==========================================

-- Full-text search with GIN trigram index
EXPLAIN ANALYZE
SELECT * FROM products
WHERE name ILIKE '%laptop%';
-- Uses idx_products_name_trgm

-- JSONB query with GIN index
EXPLAIN ANALYZE
SELECT * FROM users
WHERE preferences @> '{"theme": "dark"}';
-- Uses idx_users_preferences

-- JSONB contains query
EXPLAIN ANALYZE
SELECT * FROM products
WHERE attributes @> '{"brand": "TechCorp"}';
-- Uses idx_products_attributes

-- 5. Expression Index - Index on computed values
-- ===============================================

-- Create expression index
CREATE INDEX idx_users_lower_username ON users(LOWER(username));

-- Case-insensitive search
EXPLAIN ANALYZE
SELECT * FROM users WHERE LOWER(username) = 'user_50';
-- Uses idx_users_lower_username

-- 6. Covering Index - Include all needed columns
-- ===============================================

-- Create covering index
CREATE INDEX idx_products_category_covering
ON products(category) INCLUDE (name, price);

-- Query covered by index (Index-Only Scan)
EXPLAIN ANALYZE
SELECT name, price FROM products WHERE category = 'Electronics';
-- Uses Index-Only Scan - no table access needed

-- 7. Index Usage Statistics
-- ==========================

-- Check index usage
SELECT
    schemaname,
    tablename,
    indexname,
    idx_scan,
    idx_tup_read,
    idx_tup_fetch
FROM pg_stat_user_indexes
WHERE schemaname = 'public'
ORDER BY idx_scan DESC;

-- Find unused indexes
SELECT
    schemaname,
    tablename,
    indexname,
    idx_scan
FROM pg_stat_user_indexes
WHERE schemaname = 'public'
  AND idx_scan = 0
  AND indexname NOT LIKE '%_pkey';

-- 8. Index Size Analysis
-- =======================

-- Check index sizes
SELECT
    tablename,
    indexname,
    pg_size_pretty(pg_relation_size(indexname::regclass)) as index_size
FROM pg_indexes
WHERE schemaname = 'public'
ORDER BY pg_relation_size(indexname::regclass) DESC;

-- 9. Query Performance Comparison
-- ================================

-- Disable sequential scan to force index usage
SET enable_seqscan = OFF;

EXPLAIN ANALYZE
SELECT * FROM users WHERE email LIKE 'user_1%@example.com';

-- Re-enable sequential scan
SET enable_seqscan = ON;

-- 10. Multi-column WHERE clause optimization
-- ===========================================

-- Inefficient query (no index can help)
EXPLAIN ANALYZE
SELECT * FROM products
WHERE UPPER(name) = 'LAPTOP PRO 1'
  AND price > 1000;

-- Efficient query (uses indexes)
EXPLAIN ANALYZE
SELECT * FROM products
WHERE name ILIKE 'laptop pro%'
  AND price > 1000;

-- 11. JOIN optimization with indexes
-- ===================================

-- Well-indexed JOIN
EXPLAIN ANALYZE
SELECT u.username, COUNT(o.order_id) as order_count
FROM users u
JOIN orders o ON u.user_id = o.user_id
GROUP BY u.username
ORDER BY order_count DESC
LIMIT 10;

-- 12. Subquery optimization
-- ==========================

-- Inefficient subquery
EXPLAIN ANALYZE
SELECT * FROM products
WHERE product_id IN (
    SELECT product_id FROM order_items
);

-- Better: JOIN instead of IN
EXPLAIN ANALYZE
SELECT DISTINCT p.*
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id;

-- Even better: EXISTS
EXPLAIN ANALYZE
SELECT p.*
FROM products p
WHERE EXISTS (
    SELECT 1 FROM order_items oi
    WHERE oi.product_id = p.product_id
);

-- 13. Index Maintenance
-- ======================

-- Rebuild index (after heavy updates)
REINDEX INDEX idx_users_email;

-- Rebuild all indexes on a table
REINDEX TABLE products;

-- Analyze table statistics
ANALYZE users;

-- Vacuum and analyze
VACUUM ANALYZE products;

-- Check for bloated indexes
SELECT
    schemaname,
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS total_size,
    pg_size_pretty(pg_relation_size(schemaname||'.'||tablename)) AS table_size,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename) -
                   pg_relation_size(schemaname||'.'||tablename)) AS indexes_size
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;
