-- PostgreSQL 200 Complete Examples (Extended)
-- Add this to the end of runnable-examples.sql

-- ============================================
-- Example 51-70: Advanced CTEs and Recursion
-- ============================================

-- 51. Hierarchical data with recursive CTE
SELECT '=== Example 51: Hierarchical Data ===' as info;
WITH RECURSIVE category_hierarchy AS (
  SELECT id, name, 1 as level FROM products WHERE category = 'Electronics'
  UNION ALL
  SELECT p.id, p.name, ch.level + 1 FROM products p
  JOIN category_hierarchy ch ON p.category = ch.name
)
SELECT * FROM category_hierarchy LIMIT 5;

-- 52. Generate series with CTE
SELECT '=== Example 52: Generate Series ===' as info;
WITH RECURSIVE numbers AS (
  SELECT 1 as n
  UNION ALL
  SELECT n + 1 FROM numbers WHERE n < 20
)
SELECT * FROM numbers;

-- 53. Multi-level CTE
SELECT '=== Example 53: Multi-Level CTE ===' as info;
WITH order_summary AS (
  SELECT user_id, COUNT(*) as order_count, SUM(total_amount) as total_spent
  FROM orders GROUP BY user_id
),
user_with_orders AS (
  SELECT u.id, u.username, os.order_count, os.total_spent
  FROM users u
  LEFT JOIN order_summary os ON u.id = os.user_id
)
SELECT * FROM user_with_orders WHERE order_count > 0;

-- 54. CTE with multiple unions
SELECT '=== Example 54: Multiple Unions ===' as info;
WITH sales AS (
  SELECT user_id, total_amount FROM orders WHERE status = 'completed'
  UNION ALL
  SELECT user_id, 0 FROM users WHERE id NOT IN (SELECT user_id FROM orders)
)
SELECT user_id, SUM(total_amount) FROM sales GROUP BY user_id;

-- 55. Nested CTEs
SELECT '=== Example 55: Nested CTEs ===' as info;
WITH RECURSIVE all_levels AS (
  SELECT id, name, 0 as depth FROM products
  UNION ALL
  SELECT id, name, depth + 1 FROM all_levels WHERE depth < 3
)
SELECT COUNT(*) FROM all_levels;

-- 56. CTE with aggregation and filtering
SELECT '=== Example 56: CTE with Filtering ===' as info;
WITH active_products AS (
  SELECT * FROM products WHERE stock_quantity > 10
),
expensive_active AS (
  SELECT * FROM active_products WHERE price > 100
)
SELECT * FROM expensive_active;

-- 57. Tree structure with CTE
SELECT '=== Example 57: Tree Structure ===' as info;
WITH RECURSIVE tree AS (
  SELECT id, 'Root' as parent, 1 as level FROM users WHERE id = 1
  UNION ALL
  SELECT u.id, t.parent, t.level + 1 FROM users u
  JOIN tree t ON u.id = t.id + 1
)
SELECT * FROM tree LIMIT 10;

-- 58. Path aggregation
SELECT '=== Example 58: Path Aggregation ===' as info;
WITH RECURSIVE paths AS (
  SELECT id, username::text as path, 1 as depth FROM users WHERE id = 1
  UNION ALL
  SELECT u.id, p.path || '->' || u.username, p.depth + 1
  FROM users u, paths p WHERE u.id = p.id + 1 AND p.depth < 5
)
SELECT * FROM paths;

-- 59. Cycle detection
SELECT '=== Example 59: Cycle Detection ===' as info;
WITH RECURSIVE cycle_test AS (
  SELECT 1 as n
  UNION ALL
  SELECT (n % 10) + 1 FROM cycle_test WHERE n < 10
)
SELECT DISTINCT n FROM cycle_test;

-- 60. Date range expansion
SELECT '=== Example 60: Date Range ===' as info;
WITH RECURSIVE date_range AS (
  SELECT NOW()::date as current_date
  UNION ALL
  SELECT current_date - INTERVAL '1 day' FROM date_range
  WHERE current_date > NOW()::date - INTERVAL '7 days'
)
SELECT * FROM date_range;

-- 61. Factorial calculation
SELECT '=== Example 61: Factorial ===' as info;
WITH RECURSIVE factorial AS (
  SELECT 1 as n, 1 as result
  UNION ALL
  SELECT n + 1, (n + 1) * result FROM factorial WHERE n < 10
)
SELECT * FROM factorial;

-- 62. Fibonacci sequence
SELECT '=== Example 62: Fibonacci ===' as info;
WITH RECURSIVE fib AS (
  SELECT 0 as a, 1 as b
  UNION ALL
  SELECT b, a + b FROM fib WHERE b < 1000
)
SELECT a FROM fib;

-- 63. CTE with window functions
SELECT '=== Example 63: CTE with Window ===' as info;
WITH ranked_products AS (
  SELECT name, price,
  ROW_NUMBER() OVER (ORDER BY price DESC) as rank
  FROM products
)
SELECT * FROM ranked_products WHERE rank <= 5;

-- 64. CTE for data migration
SELECT '=== Example 64: Data Migration ===' as info;
WITH migrated_data AS (
  SELECT id, username, email, created_at as migrated_date
  FROM users WHERE created_at > NOW() - INTERVAL '30 days'
)
SELECT COUNT(*) as recent_users FROM migrated_data;

-- 65. CTE with conditional logic
SELECT '=== Example 65: Conditional Logic ===' as info;
WITH categorized AS (
  SELECT *,
  CASE
    WHEN price < 50 THEN 'Budget'
    WHEN price < 200 THEN 'Mid-Range'
    ELSE 'Premium'
  END as price_category
  FROM products
)
SELECT price_category, COUNT(*) FROM categorized GROUP BY price_category;

-- ============================================
-- Example 66-85: JSON and JSONB Operations
-- ============================================

-- 66. Create table with JSON
SELECT '=== Example 66: JSON Column ===' as info;
ALTER TABLE users ADD COLUMN IF NOT EXISTS metadata JSONB;
UPDATE users SET metadata = '{"preferences": "dark_mode", "notifications": true}' WHERE id = 1;

-- 67. Extract JSON field
SELECT '=== Example 67: Extract JSON ===' as info;
SELECT username, metadata->>'preferences' as preference FROM users WHERE metadata IS NOT NULL LIMIT 3;

-- 68. JSON path operations
SELECT '=== Example 68: JSON Path ===' as info;
SELECT username, metadata#>>'{preferences}' as pref FROM users WHERE metadata IS NOT NULL LIMIT 3;

-- 69. JSONB contains
SELECT '=== Example 69: JSONB Contains ===' as info;
SELECT username FROM users WHERE metadata @> '{"notifications": true}' LIMIT 3;

-- 70. JSONB array operations
SELECT '=== Example 70: JSONB Array ===' as info;
UPDATE users SET metadata = metadata || '{"tags": ["vip", "frequent_buyer"]}' WHERE id = 1 RETURNING metadata;

-- ============================================
-- Example 71-90: ARRAY Operations
-- ============================================

-- 71. Array column
SELECT '=== Example 71: Array Column ===' as info;
ALTER TABLE products ADD COLUMN IF NOT EXISTS tags TEXT[] DEFAULT '{}';
UPDATE products SET tags = '{"popular", "bestseller"}' WHERE id = 1;

-- 72. Array length
SELECT '=== Example 72: Array Length ===' as info;
SELECT name, array_length(tags, 1) as tag_count FROM products WHERE tags != '{}' LIMIT 5;

-- 73. Array contains
SELECT '=== Example 73: Array Contains ===' as info;
SELECT name FROM products WHERE 'bestseller' = ANY(tags) LIMIT 5;

-- 74. Array operations
SELECT '=== Example 74: Array Operations ===' as info;
SELECT array_agg(name) as products_list FROM products WHERE stock_quantity > 50;

-- 75. Array slicing
SELECT '=== Example 75: Array Slicing ===' as info;
SELECT name, tags[1:2] as first_two_tags FROM products WHERE array_length(tags, 1) > 0 LIMIT 5;

-- ============================================
-- Example 76-100: Full-Text Search
-- ============================================

-- 76. Create full-text index
SELECT '=== Example 76: Full-Text Index ===' as info;
ALTER TABLE products ADD COLUMN IF NOT EXISTS search_vector tsvector;
UPDATE products SET search_vector = to_tsvector('english', name || ' ' || COALESCE(category, ''));
CREATE INDEX IF NOT EXISTS products_search_idx ON products USING GIN(search_vector);

-- 77. Full-text search query
SELECT '=== Example 77: Full-Text Search ===' as info;
SELECT name FROM products
WHERE search_vector @@ to_tsquery('english', 'laptop')
LIMIT 5;

-- 78. Phrase search
SELECT '=== Example 78: Phrase Search ===' as info;
SELECT name FROM products
WHERE search_vector @@ phraseto_tsquery('english', 'desk lamp')
LIMIT 5;

-- 79. Search with ranking
SELECT '=== Example 79: Ranked Search ===' as info;
SELECT name, ts_rank(search_vector, query) as rank
FROM products,
to_tsquery('english', 'electronics') query
WHERE search_vector @@ query
ORDER BY rank DESC
LIMIT 5;

-- 80. Websearch
SELECT '=== Example 80: Websearch ===' as info;
SELECT name FROM products
WHERE search_vector @@ websearch_to_tsquery('electronics keyboard')
LIMIT 5;

-- ============================================
-- Example 81-100: Advanced Window Functions
-- ============================================

-- 81. Partition by multiple columns
SELECT '=== Example 81: Partition Multiple ===' as info;
SELECT user_id, total_amount,
ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY order_date DESC) as order_rank
FROM orders LIMIT 10;

-- 82. Running sum
SELECT '=== Example 82: Running Sum ===' as info;
SELECT order_date, total_amount,
SUM(total_amount) OVER (ORDER BY order_date) as cumulative_total
FROM orders LIMIT 10;

-- 83. Lag with offset
SELECT '=== Example 83: Lag with Offset ===' as info;
SELECT id, total_amount,
LAG(total_amount, 2) OVER (ORDER BY order_date) as two_orders_ago
FROM orders LIMIT 10;

-- 84. Lead function
SELECT '=== Example 84: Lead ===' as info;
SELECT id, total_amount,
LEAD(total_amount) OVER (ORDER BY order_date) as next_order
FROM orders LIMIT 10;

-- 85. First/Last value
SELECT '=== Example 85: First/Last Value ===' as info;
SELECT user_id, total_amount,
FIRST_VALUE(total_amount) OVER (PARTITION BY user_id ORDER BY order_date) as first_order_value,
LAST_VALUE(total_amount) OVER (PARTITION BY user_id ORDER BY order_date ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as last_order_value
FROM orders LIMIT 10;

-- ============================================
-- Example 86-105: Performance Tuning
-- ============================================

-- 86. Query explain analysis
SELECT '=== Example 86: Explain Analyze ===' as info;
EXPLAIN ANALYZE
SELECT u.username, COUNT(o.id) FROM users u
LEFT JOIN orders o ON u.id = o.user_id
GROUP BY u.id;

-- 87. Index suggestion
SELECT '=== Example 87: Missing Index ===' as info;
SELECT schemaname, tablename FROM pg_tables WHERE schemaname = 'public';

-- 88. Vacuum and analyze
SELECT '=== Example 88: Vacuum ===' as info;
VACUUM ANALYZE users;

-- 89. Index size
SELECT '=== Example 89: Index Size ===' as info;
SELECT indexname, pg_size_pretty(pg_relation_size(indexrelid)) as index_size
FROM pg_indexes
WHERE schemaname = 'public'
LIMIT 5;

-- 90. Table statistics
SELECT '=== Example 90: Table Stats ===' as info;
SELECT schemaname, tablename, pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) as size
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;

-- ============================================
-- Example 91-110: Custom Data Types
-- ============================================

-- 91. Enum type
SELECT '=== Example 91: Enum Type ===' as info;
CREATE TYPE IF NOT EXISTS order_status_enum AS ENUM ('pending', 'processing', 'shipped', 'delivered', 'cancelled');
ALTER TABLE orders ALTER COLUMN status DROP DEFAULT;
ALTER TABLE orders ALTER COLUMN status TYPE order_status_enum USING status::order_status_enum;

-- 92. Composite type
SELECT '=== Example 92: Composite Type ===' as info;
CREATE TYPE IF NOT EXISTS address AS (
  street VARCHAR(255),
  city VARCHAR(100),
  postal_code VARCHAR(20),
  country VARCHAR(100)
);

-- 93. Domain type
SELECT '=== Example 93: Domain Type ===' as info;
CREATE DOMAIN IF NOT EXISTS positive_decimal AS DECIMAL(10,2) CHECK (VALUE > 0);

-- 94. Range type
SELECT '=== Example 94: Range Type ===' as info;
SELECT int4range(1, 100) @> 50 as contains;

-- 95. Type casting
SELECT '=== Example 95: Type Casting ===' as info;
SELECT username, CAST(created_at AS DATE) as created_date FROM users LIMIT 5;

-- ============================================
-- Example 96-115: Security and Permissions
-- ============================================

-- 96. Create role
SELECT '=== Example 96: Create Role ===' as info;
-- CREATE ROLE app_user WITH LOGIN PASSWORD 'password';

-- 97. Grant permissions
SELECT '=== Example 97: Grant Permissions ===' as info;
-- GRANT CONNECT ON DATABASE education_db TO app_user;

-- 98. Row-level security
SELECT '=== Example 98: RLS ===' as info;
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
-- CREATE POLICY user_isolation ON users USING (id = current_user_id());

-- 99. Column-level security
SELECT '=== Example 99: Column Security ===' as info;
-- GRANT SELECT (id, username, email) ON users TO app_user;

-- 100. Audit logging
SELECT '=== Example 100: Audit Log ===' as info;
CREATE TABLE IF NOT EXISTS audit_log (
  id SERIAL PRIMARY KEY,
  table_name VARCHAR(100),
  operation VARCHAR(10),
  user_name VARCHAR(100),
  timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- Example 101-120: Triggers and Functions
-- ============================================

-- 101. Update trigger
SELECT '=== Example 101: Update Trigger ===' as info;
CREATE OR REPLACE FUNCTION update_product_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  NEW.created_at = CURRENT_TIMESTAMP;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER products_timestamp_trigger
BEFORE UPDATE ON products
FOR EACH ROW
EXECUTE FUNCTION update_product_timestamp();

-- 102. Insert trigger
SELECT '=== Example 102: Insert Trigger ===' as info;
CREATE OR REPLACE FUNCTION log_user_creation()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO audit_log (table_name, operation, user_name) VALUES ('users', 'INSERT', NEW.username);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 103. Delete trigger
SELECT '=== Example 103: Delete Trigger ===' as info;
CREATE OR REPLACE FUNCTION archive_deleted_orders()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO audit_log VALUES (DEFAULT, 'orders', 'DELETE', 'system');
  RETURN OLD;
END;
$$ LANGUAGE plpgsql;

-- 104. Stored procedure
SELECT '=== Example 104: Stored Procedure ===' as info;
CREATE OR REPLACE FUNCTION create_order(p_user_id INT, p_total DECIMAL)
RETURNS INT AS $$
DECLARE
  v_order_id INT;
BEGIN
  INSERT INTO orders (user_id, total_amount) VALUES (p_user_id, p_total)
  RETURNING id INTO v_order_id;
  RETURN v_order_id;
END;
$$ LANGUAGE plpgsql;

-- 105. Function with output parameters
SELECT '=== Example 105: Output Parameters ===' as info;
CREATE OR REPLACE FUNCTION get_user_stats(p_user_id INT, OUT order_count INT, OUT total_spent DECIMAL)
AS $$
BEGIN
  SELECT COUNT(*), SUM(total_amount) INTO order_count, total_spent
  FROM orders WHERE user_id = p_user_id;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- Example 106-125: Backup and Recovery
-- ============================================

-- 106. Backup to file
SELECT '=== Example 106: Backup ===' as info;
-- Command: pg_dump -U postgres education_db > backup.sql

-- 107. Restore from backup
SELECT '=== Example 107: Restore ===' as info;
-- Command: psql -U postgres education_db < backup.sql

-- 108. Point-in-time recovery
SELECT '=== Example 108: PITR ===' as info;
-- Configuration: wal_level = replica, archive_mode = on

-- 109. Tablespace management
SELECT '=== Example 109: Tablespace ===' as info;
-- CREATE TABLESPACE fast_space LOCATION '/var/lib/postgresql/fast_disk';

-- 110. Partial backup
SELECT '=== Example 110: Partial Backup ===' as info;
-- Command: pg_dump -U postgres -t users education_db > users_backup.sql

-- ============================================
-- Example 111-130: Advanced Queries
-- ============================================

-- 111. Materialized view
SELECT '=== Example 111: Materialized View ===' as info;
CREATE MATERIALIZED VIEW IF NOT EXISTS user_summary AS
SELECT u.id, u.username, COUNT(o.id) as order_count, SUM(o.total_amount) as total_spent
FROM users u
LEFT JOIN orders o ON u.id = o.user_id
GROUP BY u.id, u.username;

-- 112. Refresh materialized view
SELECT '=== Example 112: Refresh MV ===' as info;
REFRESH MATERIALIZED VIEW user_summary;

-- 113. Partial index
SELECT '=== Example 113: Partial Index ===' as info;
CREATE INDEX IF NOT EXISTS active_users_idx ON users(username) WHERE status = 'active';

-- 114. Expression index
SELECT '=== Example 114: Expression Index ===' as info;
CREATE INDEX IF NOT EXISTS lower_email_idx ON users(LOWER(email));

-- 115. GIN index
SELECT '=== Example 115: GIN Index ===' as info;
CREATE INDEX IF NOT EXISTS tags_gin_idx ON products USING GIN(tags);

-- 116. BRIN index
SELECT '=== Example 116: BRIN Index ===' as info;
CREATE INDEX IF NOT EXISTS orders_brin_idx ON orders USING BRIN(order_date);

-- 117. Multi-column index
SELECT '=== Example 117: Multi-Column Index ===' as info;
CREATE INDEX IF NOT EXISTS user_status_idx ON users(username, status);

-- 118. Covering index
SELECT '=== Example 118: Covering Index ===' as info;
CREATE INDEX IF NOT EXISTS products_price_idx ON products(category) INCLUDE (name, price);

-- 119. Concurrent index creation
SELECT '=== Example 119: Concurrent Index ===' as info;
CREATE INDEX CONCURRENTLY IF NOT EXISTS concurrent_idx ON users(email);

-- 120. Index statistics
SELECT '=== Example 120: Index Stats ===' as info;
SELECT indexname, idx_scan, idx_tup_read, idx_tup_fetch
FROM pg_stat_user_indexes
LIMIT 10;

-- ============================================
-- Example 121-150: Advanced Features
-- ============================================

-- 121. Partitioned table
SELECT '=== Example 121: Partitioned Table ===' as info;
-- CREATE TABLE orders_partitioned (LIKE orders) PARTITION BY RANGE (EXTRACT(YEAR FROM order_date));

-- 122. Inheritance
SELECT '=== Example 122: Inheritance ===' as info;
-- CREATE TABLE premium_users (tier VARCHAR) INHERITS (users);

-- 123. Foreign data wrapper
SELECT '=== Example 123: FDW ===' as info;
-- CREATE EXTENSION IF NOT EXISTS postgres_fdw;

-- 124. Listen/Notify
SELECT '=== Example 124: Notify ===' as info;
-- NOTIFY channel, 'message';

-- 125. Event triggers
SELECT '=== Example 125: Event Trigger ===' as info;
-- CREATE EVENT TRIGGER ddl_check ON ddl_command_end EXECUTE FUNCTION check_ddl();

-- 126. Parallel query execution
SELECT '=== Example 126: Parallel Query ===' as info;
SET max_parallel_workers_per_gather = 4;
SELECT COUNT(*) FROM orders;

-- 127. Unlogged table
SELECT '=== Example 127: Unlogged Table ===' as info;
-- CREATE UNLOGGED TABLE temp_data (id SERIAL PRIMARY KEY, data TEXT);

-- 128. Sequences
SELECT '=== Example 128: Sequences ===' as info;
CREATE SEQUENCE IF NOT EXISTS custom_id_seq;
SELECT NEXTVAL('custom_id_seq');

-- 129. Binary data
SELECT '=== Example 129: Binary Data ===' as info;
ALTER TABLE products ADD COLUMN IF NOT EXISTS binary_data BYTEA;

-- 130. UUID type
SELECT '=== Example 130: UUID ===' as info;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
SELECT uuid_generate_v4();

-- ============================================
-- Example 131-150: Data Analysis
-- ============================================

-- 131. Correlation analysis
SELECT '=== Example 131: Correlation ===' as info;
SELECT CORR(price, stock_quantity) FROM products;

-- 132. Percentile
SELECT '=== Example 132: Percentile ===' as info;
SELECT PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY price) FROM products;

-- 133. Mode (most frequent)
SELECT '=== Example 133: Mode ===' as info;
SELECT MODE() WITHIN GROUP (ORDER BY status) FROM orders;

-- 134. Variance
SELECT '=== Example 134: Variance ===' as info;
SELECT VAR_POP(price) FROM products;

-- 135. Standard deviation
SELECT '=== Example 135: Std Dev ===' as info;
SELECT STDDEV(total_amount) FROM orders;

-- 136. Skewness
SELECT '=== Example 136: Skewness ===' as info;
SELECT SKEW(total_amount) FROM orders;

-- 137. Kurtosis
SELECT '=== Example 137: Kurtosis ===' as info;
SELECT KURTOSIS(total_amount) FROM orders;

-- 138. Covariance
SELECT '=== Example 138: Covariance ===' as info;
SELECT COVAR_POP(price, stock_quantity) FROM products;

-- 139. Regression
SELECT '=== Example 139: Regression ===' as info;
SELECT REGR_SLOPE(total_amount, id) FROM orders;

-- 140. Histogram
SELECT '=== Example 140: Histogram ===' as info;
SELECT WIDTH_BUCKET(price, 0, 1000, 10) as bucket, COUNT(*)
FROM products GROUP BY bucket;

-- ============================================
-- Example 141-160: Real-World Scenarios
-- ============================================

-- 141. Product recommendations
SELECT '=== Example 141: Recommendations ===' as info;
SELECT p1.name, p2.name, COUNT(*) as co_purchases
FROM order_items oi1
JOIN order_items oi2 ON oi1.order_id = oi2.order_id AND oi1.product_id < oi2.product_id
JOIN products p1 ON oi1.product_id = p1.id
JOIN products p2 ON oi2.product_id = p2.id
GROUP BY p1.id, p2.id
ORDER BY co_purchases DESC LIMIT 5;

-- 142. Customer segmentation
SELECT '=== Example 142: Segmentation ===' as info;
SELECT username,
CASE
  WHEN total_spent > 5000 THEN 'Gold'
  WHEN total_spent > 2000 THEN 'Silver'
  WHEN total_spent > 500 THEN 'Bronze'
  ELSE 'Regular'
END as customer_segment
FROM (
  SELECT u.id, u.username, SUM(o.total_amount) as total_spent
  FROM users u LEFT JOIN orders o ON u.id = o.user_id
  GROUP BY u.id
) customer_summary;

-- 143. Churn prediction
SELECT '=== Example 143: Churn Analysis ===' as info;
SELECT u.username, MAX(o.order_date) as last_purchase,
NOW() - MAX(o.order_date) as days_since_purchase
FROM users u LEFT JOIN orders o ON u.id = o.user_id
GROUP BY u.id
HAVING NOW() - MAX(o.order_date) > INTERVAL '90 days'
ORDER BY days_since_purchase DESC;

-- 144. Inventory alerts
SELECT '=== Example 144: Low Inventory ===' as info;
SELECT name, stock_quantity FROM products
WHERE stock_quantity < 50 AND stock_quantity > 0
ORDER BY stock_quantity ASC;

-- 145. Revenue trends
SELECT '=== Example 145: Revenue Trends ===' as info;
SELECT DATE_TRUNC('month', order_date)::DATE as month,
COUNT(*) as orders, SUM(total_amount) as revenue,
AVG(total_amount) as avg_order_value
FROM orders WHERE status = 'completed'
GROUP BY month ORDER BY month DESC;

-- 146. Customer lifetime value
SELECT '=== Example 146: CLV ===' as info;
SELECT u.username, SUM(o.total_amount) as lifetime_value,
COUNT(o.id) as order_count,
AVG(o.total_amount) as avg_order_value,
MAX(o.order_date) as last_purchase
FROM users u LEFT JOIN orders o ON u.id = o.user_id
GROUP BY u.id ORDER BY lifetime_value DESC LIMIT 10;

-- 147. Product performance
SELECT '=== Example 147: Product Performance ===' as info;
SELECT p.name, COUNT(oi.id) as sales,
SUM(oi.quantity) as units, SUM(oi.quantity * oi.price) as revenue,
AVG(r.rating) as avg_rating
FROM products p
LEFT JOIN order_items oi ON p.id = oi.product_id
LEFT JOIN reviews r ON p.id = r.product_id
GROUP BY p.id ORDER BY revenue DESC;

-- 148. Repeat purchase rate
SELECT '=== Example 148: Repeat Purchases ===' as info;
SELECT ROUND(100.0 * repeat_customers / total_customers, 2) as repeat_rate
FROM (
  SELECT COUNT(DISTINCT CASE WHEN order_count > 1 THEN id END) as repeat_customers,
  COUNT(DISTINCT id) as total_customers
  FROM (SELECT u.id, COUNT(o.id) as order_count
    FROM users u LEFT JOIN orders o ON u.id = o.user_id
    GROUP BY u.id) t
) stats;

-- 149. Average order value by segment
SELECT '=== Example 149: AOV by Segment ===' as info;
SELECT EXTRACT(MONTH FROM order_date) as month,
ROUND(AVG(total_amount), 2) as avg_order_value
FROM orders WHERE status = 'completed'
GROUP BY EXTRACT(MONTH FROM order_date)
ORDER BY month;

-- 150. Year-over-year comparison
SELECT '=== Example 150: YoY Comparison ===' as info;
SELECT EXTRACT(MONTH FROM order_date) as month,
EXTRACT(YEAR FROM order_date) as year,
SUM(total_amount) as revenue
FROM orders WHERE status = 'completed'
GROUP BY EXTRACT(YEAR FROM order_date), EXTRACT(MONTH FROM order_date)
ORDER BY year DESC, month;

-- ============================================
-- Example 151-170: Optimization Techniques
-- ============================================

-- 151. UNION vs UNION ALL
SELECT '=== Example 151: UNION vs UNION ALL ===' as info;
SELECT username FROM users WHERE status = 'active'
UNION
SELECT username FROM users WHERE status = 'inactive';

-- 152. Lateral join
SELECT '=== Example 152: Lateral Join ===' as info;
SELECT u.username, o.id, o.total_amount
FROM users u,
LATERAL (SELECT * FROM orders WHERE user_id = u.id ORDER BY order_date DESC LIMIT 3) o;

-- 153. Subquery optimization
SELECT '=== Example 153: Subquery Optimization ===' as info;
SELECT username FROM users
WHERE EXISTS (SELECT 1 FROM orders WHERE orders.user_id = users.id);

-- 154. IN vs JOIN
SELECT '=== Example 154: IN vs JOIN ===' as info;
SELECT DISTINCT u.username FROM users u
JOIN orders o ON u.id = o.user_id;

-- 155. Batch operations
SELECT '=== Example 155: Batch Insert ===' as info;
INSERT INTO orders (user_id, total_amount, status)
SELECT id, RANDOM() * 1000, 'pending' FROM users LIMIT 5;

-- 156. Bulk update
SELECT '=== Example 156: Bulk Update ===' as info;
UPDATE orders SET status = 'processed' WHERE status = 'pending' AND order_date < NOW() - INTERVAL '7 days';

-- 157. Prepared statements
SELECT '=== Example 157: Prepared Statements ===' as info;
PREPARE get_user_orders (INT) AS
SELECT * FROM orders WHERE user_id = $1;

-- 158. Cursor operations
SELECT '=== Example 158: Cursor ===' as info;
-- Used in stored procedures

-- 159. Connection pooling
SELECT '=== Example 159: Connection Pooling ===' as info;
-- Configuration: max_connections = 200

-- 160. Memory optimization
SELECT '=== Example 160: Memory ===' as info;
SET work_mem = '256MB';

-- ============================================
-- Example 161-180: Data Quality
-- ============================================

-- 161. Null checking
SELECT '=== Example 161: Null Check ===' as info;
SELECT username FROM users WHERE email IS NULL;

-- 162. Duplicate detection
SELECT '=== Example 162: Duplicates ===' as info;
SELECT email, COUNT(*) FROM users GROUP BY email HAVING COUNT(*) > 1;

-- 163. Data inconsistency
SELECT '=== Example 163: Inconsistency ===' as info;
SELECT o.* FROM orders o
WHERE NOT EXISTS (SELECT 1 FROM users WHERE id = o.user_id);

-- 164. Range validation
SELECT '=== Example 164: Range Validation ===' as info;
SELECT name FROM products WHERE price < 0 OR stock_quantity < 0;

-- 165. Constraint violations
SELECT '=== Example 165: Constraints ===' as info;
SELECT CONSTRAINT_NAME FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
WHERE TABLE_SCHEMA = 'public' AND TABLE_NAME = 'products';

-- 166. Foreign key validation
SELECT '=== Example 166: FK Validation ===' as info;
SELECT COUNT(*) FROM order_items oi
WHERE NOT EXISTS (SELECT 1 FROM products WHERE id = oi.product_id);

-- 167. Data profiling
SELECT '=== Example 167: Data Profiling ===' as info;
SELECT 'users' as table_name, COUNT(*) as row_count FROM users
UNION ALL
SELECT 'products', COUNT(*) FROM products
UNION ALL
SELECT 'orders', COUNT(*) FROM orders;

-- 168. Missing values analysis
SELECT '=== Example 168: Missing Values ===' as info;
SELECT 'users.email' as column_name,
COUNT(*) FILTER (WHERE email IS NULL) as null_count,
ROUND(100.0 * COUNT(*) FILTER (WHERE email IS NULL) / COUNT(*), 2) as null_percentage
FROM users;

-- 169. Outlier detection
SELECT '=== Example 169: Outliers ===' as info;
SELECT * FROM orders
WHERE total_amount > (SELECT AVG(total_amount) + 3 * STDDEV(total_amount) FROM orders);

-- 170. Distribution analysis
SELECT '=== Example 170: Distribution ===' as info;
SELECT FLOOR(price / 100) * 100 as price_range, COUNT(*) as count
FROM products GROUP BY FLOOR(price / 100) ORDER BY price_range;

-- ============================================
-- Example 171-200: Advanced Features
-- ============================================

-- 171. Schema management
SELECT '=== Example 171: Schema ===' as info;
CREATE SCHEMA IF NOT EXISTS analytics;
SET search_path TO analytics, public;

-- 172. Extensions
SELECT '=== Example 172: Extensions ===' as info;
CREATE EXTENSION IF NOT EXISTS pg_stat_statements;
SELECT query, calls, total_time FROM pg_stat_statements LIMIT 5;

-- 173. Collation
SELECT '=== Example 173: Collation ===' as info;
SELECT username FROM users ORDER BY username COLLATE "C";

-- 174. Regular expressions
SELECT '=== Example 174: Regex ===' as info;
SELECT email FROM users WHERE email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}$';

-- 175. String functions
SELECT '=== Example 175: String Functions ===' as info;
SELECT username, LENGTH(username), SUBSTR(username, 1, 3), REVERSE(username)
FROM users LIMIT 5;

-- 176. Date arithmetic
SELECT '=== Example 176: Date Arithmetic ===' as info;
SELECT order_date, order_date + INTERVAL '7 days' as week_later,
order_date - INTERVAL '1 month' as month_ago
FROM orders LIMIT 5;

-- 177. Interval operations
SELECT '=== Example 177: Intervals ===' as info;
SELECT EXTRACT(DAY FROM NOW() - created_at) as days_old
FROM users LIMIT 5;

-- 178. Encryption
SELECT '=== Example 178: Encryption ===' as info;
CREATE EXTENSION IF NOT EXISTS pgcrypto;
SELECT encode(digest('password', 'sha256'), 'hex');

-- 179. UUID operations
SELECT '=== Example 179: UUID Ops ===' as info;
SELECT uuid_generate_v4() as new_uuid,
uuid_generate_v5(uuid_ns_dns(), 'example.com');

-- 180. JSON generation
SELECT '=== Example 180: JSON Generation ===' as info;
SELECT json_build_object('id', id, 'username', username, 'email', email)
FROM users LIMIT 3;

-- 181. Aggregate JSON
SELECT '=== Example 181: JSON Agg ===' as info;
SELECT json_agg(json_build_object('name', name, 'price', price))
FROM products LIMIT 1;

-- 182. Pretty print
SELECT '=== Example 182: Pretty JSON ===' as info;
SELECT jsonb_pretty(jsonb_build_object('user', 'john', 'active', true));

-- 183. Window frames
SELECT '=== Example 183: Window Frames ===' as info;
SELECT id, total_amount,
AVG(total_amount) OVER (ORDER BY id ROWS BETWEEN 2 PRECEDING AND 2 FOLLOWING) as moving_avg
FROM orders LIMIT 10;

-- 184. Recursive CTE depth limit
SELECT '=== Example 184: CTE Depth ===' as info;
-- SET max_recursive_nesting_depth = 100;

-- 185. Session variables
SELECT '=== Example 185: Session Variables ===' as info;
SET application_name = 'my_app';
SELECT current_setting('application_name');

-- 186. Client encoding
SELECT '=== Example 186: Encoding ===' as info;
SET CLIENT_ENCODING = 'UTF8';
SELECT current_setting('client_encoding');

-- 187. Transaction isolation
SELECT '=== Example 187: Isolation Levels ===' as info;
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

-- 188. Statement timeout
SELECT '=== Example 188: Timeout ===' as info;
SET statement_timeout = '10s';

-- 189. Lock timeouts
SELECT '=== Example 189: Lock Timeout ===' as info;
SET lock_timeout = '5s';

-- 190. Idle timeout
SELECT '=== Example 190: Idle Timeout ===' as info;
SET idle_in_transaction_session_timeout = '60s';

-- 191. Query cancellation
SELECT '=== Example 191: Cancel Query ===' as info;
-- Use: SELECT pg_cancel_backend(pid);

-- 192. Terminate session
SELECT '=== Example 192: Terminate ===' as info;
-- Use: SELECT pg_terminate_backend(pid);

-- 193. Deadlock prevention
SELECT '=== Example 193: Deadlock Prevention ===' as info;
SELECT * FROM pg_locks WHERE NOT granted;

-- 194. Lock information
SELECT '=== Example 194: Lock Info ===' as info;
SELECT relation::regclass, mode FROM pg_locks WHERE NOT granted;

-- 195. Active queries
SELECT '=== Example 195: Active Queries ===' as info;
SELECT pid, usename, application_name, query, query_start
FROM pg_stat_activity WHERE state = 'active';

-- 196. Slow queries
SELECT '=== Example 196: Slow Queries ===' as info;
SELECT query, calls, mean_exec_time FROM pg_stat_statements
ORDER BY mean_exec_time DESC LIMIT 5;

-- 197. Database size
SELECT '=== Example 197: DB Size ===' as info;
SELECT pg_size_pretty(pg_database_size(current_database()));

-- 198. Relation sizes
SELECT '=== Example 198: Relation Sizes ===' as info;
SELECT relname, pg_size_pretty(pg_total_relation_size(relid)) as size
FROM pg_stat_user_tables ORDER BY pg_total_relation_size(relid) DESC LIMIT 10;

-- 199. Cache hit ratio
SELECT '=== Example 199: Cache Ratio ===' as info;
SELECT heap_blks_read, heap_blks_hit,
ROUND(100.0 * heap_blks_hit / (heap_blks_hit + heap_blks_read), 2) as cache_hit_ratio
FROM pg_statio_user_tables WHERE heap_blks_read > 0 LIMIT 5;

-- 200. Final summary
SELECT '=== Example 200: Summary ===' as info;
SELECT
  (SELECT COUNT(*) FROM users) as users,
  (SELECT COUNT(*) FROM products) as products,
  (SELECT COUNT(*) FROM orders) as orders,
  (SELECT SUM(total_amount) FROM orders WHERE status = 'completed') as total_revenue;
