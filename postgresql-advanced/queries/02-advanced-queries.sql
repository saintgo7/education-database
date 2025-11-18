-- Advanced PostgreSQL Queries
-- Window functions, CTEs, aggregations, and more

-- 1. Window Functions
-- ===================

-- Row number within partition
SELECT
    username,
    email,
    created_at,
    ROW_NUMBER() OVER (PARTITION BY status ORDER BY created_at) as row_num
FROM users
ORDER BY status, row_num;

-- Rank products by price within category
SELECT
    name,
    category,
    price,
    RANK() OVER (PARTITION BY category ORDER BY price DESC) as price_rank,
    DENSE_RANK() OVER (PARTITION BY category ORDER BY price DESC) as dense_price_rank
FROM products
WHERE category IS NOT NULL;

-- Running total of order amounts
SELECT
    order_number,
    created_at,
    total_amount,
    SUM(total_amount) OVER (ORDER BY created_at) as running_total
FROM orders
WHERE status = 'delivered'
ORDER BY created_at;

-- Moving average (7-order window)
SELECT
    order_number,
    total_amount,
    AVG(total_amount) OVER (
        ORDER BY created_at
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) as moving_avg_7
FROM orders
ORDER BY created_at;

-- Lag and Lead functions
SELECT
    order_id,
    created_at,
    total_amount,
    LAG(total_amount, 1) OVER (ORDER BY created_at) as previous_order_amount,
    LEAD(total_amount, 1) OVER (ORDER BY created_at) as next_order_amount,
    total_amount - LAG(total_amount, 1) OVER (ORDER BY created_at) as amount_diff
FROM orders
ORDER BY created_at;

-- 2. Common Table Expressions (CTEs)
-- ===================================

-- Simple CTE
WITH active_users AS (
    SELECT user_id, username, email
    FROM users
    WHERE status = 'active'
)
SELECT
    au.username,
    COUNT(o.order_id) as order_count,
    SUM(o.total_amount) as total_spent
FROM active_users au
LEFT JOIN orders o ON au.user_id = o.user_id
GROUP BY au.username
ORDER BY total_spent DESC NULLS LAST;

-- Recursive CTE - Generate date series
WITH RECURSIVE date_series AS (
    SELECT CURRENT_DATE - INTERVAL '30 days' as date
    UNION ALL
    SELECT date + INTERVAL '1 day'
    FROM date_series
    WHERE date < CURRENT_DATE
)
SELECT
    ds.date,
    COUNT(o.order_id) as orders_count,
    COALESCE(SUM(o.total_amount), 0) as daily_revenue
FROM date_series ds
LEFT JOIN orders o ON DATE(o.created_at) = ds.date
GROUP BY ds.date
ORDER BY ds.date;

-- Multiple CTEs
WITH product_stats AS (
    SELECT
        product_id,
        COUNT(*) as review_count,
        AVG(rating) as avg_rating
    FROM reviews
    GROUP BY product_id
),
order_stats AS (
    SELECT
        product_id,
        SUM(quantity) as total_sold,
        SUM(subtotal) as total_revenue
    FROM order_items
    GROUP BY product_id
)
SELECT
    p.name,
    p.category,
    p.price,
    COALESCE(ps.review_count, 0) as reviews,
    COALESCE(ps.avg_rating, 0) as rating,
    COALESCE(os.total_sold, 0) as units_sold,
    COALESCE(os.total_revenue, 0) as revenue
FROM products p
LEFT JOIN product_stats ps ON p.product_id = ps.product_id
LEFT JOIN order_stats os ON p.product_id = os.product_id
ORDER BY revenue DESC
LIMIT 20;

-- 3. Advanced Aggregations
-- =========================

-- GROUPING SETS
SELECT
    category,
    EXTRACT(YEAR FROM created_at) as year,
    COUNT(*) as product_count,
    AVG(price) as avg_price
FROM products
GROUP BY GROUPING SETS (
    (category),
    (EXTRACT(YEAR FROM created_at)),
    (category, EXTRACT(YEAR FROM created_at)),
    ()
)
ORDER BY category NULLS FIRST, year NULLS FIRST;

-- ROLLUP (hierarchical aggregation)
SELECT
    category,
    CASE WHEN rating >= 4 THEN 'High' ELSE 'Low' END as rating_group,
    COUNT(*) as review_count,
    AVG(rating) as avg_rating
FROM reviews r
JOIN products p ON r.product_id = p.product_id
GROUP BY ROLLUP(category, CASE WHEN rating >= 4 THEN 'High' ELSE 'Low' END);

-- CUBE (all combinations)
SELECT
    status,
    EXTRACT(MONTH FROM created_at) as month,
    COUNT(*) as order_count,
    SUM(total_amount) as total_revenue
FROM orders
WHERE created_at >= CURRENT_DATE - INTERVAL '3 months'
GROUP BY CUBE(status, EXTRACT(MONTH FROM created_at));

-- FILTER clause in aggregations
SELECT
    category,
    COUNT(*) as total_products,
    COUNT(*) FILTER (WHERE price > 1000) as expensive_products,
    COUNT(*) FILTER (WHERE stock_quantity > 100) as high_stock_products,
    AVG(price) as avg_price,
    AVG(price) FILTER (WHERE stock_quantity > 0) as avg_price_in_stock
FROM products
GROUP BY category;

-- 4. JSONB Operations
-- ===================

-- Extract JSON fields
SELECT
    username,
    preferences->>'theme' as theme,
    preferences->>'language' as language,
    preferences->'notifications' as notifications
FROM users
WHERE preferences IS NOT NULL
LIMIT 10;

-- JSONB aggregation
SELECT
    category,
    jsonb_object_agg(
        attributes->>'brand',
        COUNT(*)
    ) as brand_counts
FROM products
WHERE attributes->>'brand' IS NOT NULL
GROUP BY category;

-- Build complex JSON objects
SELECT
    u.username,
    jsonb_build_object(
        'user_id', u.user_id,
        'email', u.email,
        'total_orders', COUNT(o.order_id),
        'total_spent', COALESCE(SUM(o.total_amount), 0),
        'orders', jsonb_agg(
            jsonb_build_object(
                'order_number', o.order_number,
                'status', o.status,
                'amount', o.total_amount
            ) ORDER BY o.created_at DESC
        ) FILTER (WHERE o.order_id IS NOT NULL)
    ) as user_data
FROM users u
LEFT JOIN orders o ON u.user_id = o.user_id
GROUP BY u.user_id, u.username, u.email
LIMIT 5;

-- 5. Full-Text Search
-- ====================

-- Simple text search
SELECT
    name,
    description,
    similarity(name, 'laptop') as name_similarity
FROM products
WHERE name ILIKE '%laptop%' OR description ILIKE '%laptop%'
ORDER BY name_similarity DESC;

-- Advanced search with ranking
SELECT
    name,
    category,
    price,
    ts_rank(
        to_tsvector('english', name || ' ' || COALESCE(description, '')),
        to_tsquery('english', 'laptop | computer')
    ) as rank
FROM products
WHERE to_tsvector('english', name || ' ' || COALESCE(description, '')) @@
      to_tsquery('english', 'laptop | computer')
ORDER BY rank DESC;

-- 6. Array Operations
-- ====================

-- Create array aggregation
SELECT
    category,
    array_agg(name ORDER BY price DESC) as products,
    array_agg(price ORDER BY price DESC) as prices
FROM products
WHERE category = 'Electronics'
GROUP BY category;

-- Unnest array
WITH product_array AS (
    SELECT array_agg(product_id) as product_ids
    FROM products
    WHERE category = 'Electronics'
    LIMIT 1
)
SELECT unnest(product_ids) as product_id
FROM product_array;

-- 7. Statistical Functions
-- =========================

-- Percentile calculations
SELECT
    category,
    COUNT(*) as product_count,
    percentile_cont(0.5) WITHIN GROUP (ORDER BY price) as median_price,
    percentile_cont(0.25) WITHIN GROUP (ORDER BY price) as p25_price,
    percentile_cont(0.75) WITHIN GROUP (ORDER BY price) as p75_price,
    percentile_cont(0.95) WITHIN GROUP (ORDER BY price) as p95_price
FROM products
GROUP BY category
HAVING COUNT(*) > 10;

-- Correlation analysis
SELECT
    corr(rating, helpful_count) as rating_helpful_correlation,
    regr_slope(helpful_count, rating) as regression_slope,
    regr_intercept(helpful_count, rating) as regression_intercept
FROM reviews;

-- 8. Date/Time Functions
-- =======================

-- Time bucketing
SELECT
    DATE_TRUNC('day', created_at) as day,
    COUNT(*) as order_count,
    SUM(total_amount) as daily_revenue
FROM orders
WHERE created_at >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY DATE_TRUNC('day', created_at)
ORDER BY day;

-- Age and interval calculations
SELECT
    username,
    created_at,
    AGE(CURRENT_TIMESTAMP, created_at) as account_age,
    EXTRACT(EPOCH FROM (CURRENT_TIMESTAMP - created_at))/86400 as days_since_creation
FROM users
ORDER BY account_age DESC
LIMIT 10;

-- 9. Lateral Joins
-- =================

-- Top 3 products per category
SELECT
    p1.category,
    p2.name,
    p2.price
FROM (SELECT DISTINCT category FROM products WHERE category IS NOT NULL) p1
CROSS JOIN LATERAL (
    SELECT name, price
    FROM products p
    WHERE p.category = p1.category
    ORDER BY price DESC
    LIMIT 3
) p2
ORDER BY p1.category, p2.price DESC;

-- 10. Set Operations
-- ===================

-- UNION - Users who ordered OR reviewed
(SELECT DISTINCT user_id, 'customer' as type FROM orders)
UNION
(SELECT DISTINCT user_id, 'reviewer' as type FROM reviews)
ORDER BY user_id;

-- INTERSECT - Users who both ordered AND reviewed
(SELECT DISTINCT user_id FROM orders)
INTERSECT
(SELECT DISTINCT user_id FROM reviews)
ORDER BY user_id;

-- EXCEPT - Users who ordered but never reviewed
(SELECT DISTINCT user_id FROM orders)
EXCEPT
(SELECT DISTINCT user_id FROM reviews)
ORDER BY user_id;
