-- PostgreSQL 50 Practice Examples
-- Comprehensive examples covering various SQL concepts

-- ============================================
-- 1-10: Basic SELECT Queries
-- ============================================

-- 1. Simple SELECT all users
SELECT * FROM users LIMIT 10;

-- 2. SELECT with WHERE clause
SELECT username, email FROM users WHERE status = 'active';

-- 3. SELECT with DISTINCT
SELECT DISTINCT category FROM products;

-- 4. SELECT with ORDER BY
SELECT * FROM products ORDER BY price DESC LIMIT 5;

-- 5. SELECT with LIMIT and OFFSET (pagination)
SELECT * FROM products LIMIT 10 OFFSET 20;

-- 6. SELECT with COUNT aggregate
SELECT COUNT(*) as total_users FROM users;

-- 7. SELECT with AVG aggregate
SELECT AVG(price) as average_price FROM products;

-- 8. SELECT with SUM aggregate
SELECT category, SUM(stock_quantity) as total_stock FROM products GROUP BY category;

-- 9. SELECT with GROUP BY
SELECT category, COUNT(*) as product_count FROM products GROUP BY category ORDER BY product_count DESC;

-- 10. SELECT with HAVING clause
SELECT category, AVG(price) as avg_price FROM products GROUP BY category HAVING AVG(price) > 100;

-- ============================================
-- 11-20: JOIN Queries
-- ============================================

-- 11. INNER JOIN
SELECT u.username, COUNT(o.id) as order_count
FROM users u
INNER JOIN orders o ON u.id = o.user_id
GROUP BY u.id, u.username;

-- 12. LEFT JOIN
SELECT u.username, COALESCE(COUNT(o.id), 0) as order_count
FROM users u
LEFT JOIN orders o ON u.id = o.user_id
GROUP BY u.id, u.username;

-- 13. FULL OUTER JOIN
SELECT u.username, o.id FROM users u
FULL OUTER JOIN orders o ON u.id = o.user_id;

-- 14. Self JOIN
SELECT p1.id, p2.id FROM products p1, products p2
WHERE p1.category = p2.category AND p1.id < p2.id;

-- 15. Multiple JOINs
SELECT u.username, o.id, p.name, oi.quantity
FROM users u
JOIN orders o ON u.id = o.user_id
JOIN order_items oi ON o.id = oi.order_id
JOIN products p ON oi.product_id = p.id;

-- 16. JOIN with WHERE condition
SELECT u.username, o.total_amount FROM users u
JOIN orders o ON u.id = o.user_id
WHERE o.total_amount > 100 AND o.status = 'completed';

-- 17. JOIN with aggregation
SELECT u.username, SUM(o.total_amount) as total_spent
FROM users u
JOIN orders o ON u.id = o.user_id
GROUP BY u.id, u.username
HAVING SUM(o.total_amount) > 500;

-- 18. JOIN with DISTINCT
SELECT DISTINCT u.username FROM users u
JOIN orders o ON u.id = o.user_id
JOIN order_items oi ON o.id = oi.order_id
WHERE oi.quantity > 5;

-- 19. Complex JOIN with subquery
SELECT u.username FROM users u
WHERE u.id IN (SELECT DISTINCT user_id FROM orders WHERE total_amount > 1000);

-- 20. JOIN with UNION
SELECT u.username FROM users u
JOIN orders o ON u.id = o.user_id WHERE o.status = 'completed'
UNION
SELECT u.username FROM users u
JOIN orders o ON u.id = o.user_id WHERE o.status = 'pending';

-- ============================================
-- 21-30: Subqueries and Common Table Expressions
-- ============================================

-- 21. Subquery in WHERE clause
SELECT * FROM products
WHERE price > (SELECT AVG(price) FROM products);

-- 22. Subquery with IN operator
SELECT * FROM users WHERE id IN
(SELECT user_id FROM orders WHERE total_amount > 500);

-- 23. Subquery with EXISTS
SELECT * FROM users u WHERE EXISTS
(SELECT 1 FROM orders o WHERE o.user_id = u.id AND o.status = 'completed');

-- 24. Correlated subquery
SELECT p.name,
(SELECT COUNT(*) FROM order_items WHERE product_id = p.id) as times_ordered
FROM products p;

-- 25. CTE (Common Table Expression)
WITH user_orders AS (
  SELECT user_id, COUNT(*) as order_count, SUM(total_amount) as total_spent
  FROM orders
  GROUP BY user_id
)
SELECT u.username, uo.order_count, uo.total_spent
FROM users u
JOIN user_orders uo ON u.id = uo.user_id;

-- 26. Recursive CTE
WITH RECURSIVE numbers AS (
  SELECT 1 as n
  UNION ALL
  SELECT n + 1 FROM numbers WHERE n < 10
)
SELECT * FROM numbers;

-- 27. Multiple CTEs
WITH recent_orders AS (
  SELECT * FROM orders WHERE order_date >= NOW() - INTERVAL '30 days'
),
high_value_orders AS (
  SELECT * FROM recent_orders WHERE total_amount > 500
)
SELECT * FROM high_value_orders;

-- 28. CTE with Window functions
WITH order_stats AS (
  SELECT user_id, SUM(total_amount) as total,
  ROW_NUMBER() OVER (ORDER BY SUM(total_amount) DESC) as rank
  FROM orders GROUP BY user_id
)
SELECT * FROM order_stats WHERE rank <= 10;

-- 29. Subquery in FROM clause (inline view)
SELECT category, avg_price FROM (
  SELECT category, AVG(price) as avg_price FROM products
  GROUP BY category
) AS category_averages
WHERE avg_price > 100;

-- 30. Scalar subquery in SELECT
SELECT username,
(SELECT COUNT(*) FROM orders WHERE user_id = users.id) as total_orders,
(SELECT AVG(total_amount) FROM orders WHERE user_id = users.id) as avg_order_value
FROM users;

-- ============================================
-- 31-40: Window Functions
-- ============================================

-- 31. ROW_NUMBER() function
SELECT ROW_NUMBER() OVER (ORDER BY price DESC) as rank, name, price FROM products;

-- 32. RANK() function
SELECT RANK() OVER (PARTITION BY category ORDER BY price DESC) as rank, category, name, price FROM products;

-- 33. DENSE_RANK() function
SELECT DENSE_RANK() OVER (ORDER BY price DESC) as rank, name, price FROM products;

-- 34. LAG() function - previous row value
SELECT id, order_date, total_amount,
LAG(total_amount) OVER (PARTITION BY user_id ORDER BY order_date) as previous_order_amount
FROM orders;

-- 35. LEAD() function - next row value
SELECT id, order_date, total_amount,
LEAD(total_amount) OVER (PARTITION BY user_id ORDER BY order_date) as next_order_amount
FROM orders;

-- 36. FIRST_VALUE() function
SELECT id, price,
FIRST_VALUE(price) OVER (PARTITION BY category ORDER BY price) as cheapest_in_category
FROM products;

-- 37. LAST_VALUE() function
SELECT id, price,
LAST_VALUE(price) OVER (PARTITION BY category ORDER BY price ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as most_expensive
FROM products;

-- 38. SUM() as window function
SELECT id, total_amount,
SUM(total_amount) OVER (PARTITION BY user_id ORDER BY order_date) as running_total
FROM orders;

-- 39. AVG() as window function
SELECT id, total_amount,
AVG(total_amount) OVER (PARTITION BY user_id) as user_avg_order_value
FROM orders;

-- 40. NTILE() function - dividing into percentiles
SELECT id, total_amount,
NTILE(4) OVER (ORDER BY total_amount) as quartile
FROM orders;

-- ============================================
-- 41-50: Advanced Queries
-- ============================================

-- 41. CASE statement
SELECT username, status,
CASE
  WHEN status = 'active' THEN 'Active User'
  WHEN status = 'inactive' THEN 'Inactive User'
  ELSE 'Unknown'
END as user_status_label
FROM users;

-- 42. CASE with aggregation
SELECT category,
SUM(CASE WHEN stock_quantity > 10 THEN 1 ELSE 0 END) as well_stocked,
SUM(CASE WHEN stock_quantity <= 10 THEN 1 ELSE 0 END) as low_stock
FROM products GROUP BY category;

-- 43. UNION operator
SELECT 'User' as type, username as name FROM users
UNION
SELECT 'Product' as type, name FROM products;

-- 44. INTERSECT operator
SELECT user_id FROM orders WHERE total_amount > 500
INTERSECT
SELECT user_id FROM orders WHERE status = 'completed';

-- 45. EXCEPT operator (set difference)
SELECT id FROM users
EXCEPT
SELECT DISTINCT user_id FROM orders;

-- 46. JSON operations
SELECT username,
(preferences->>'theme') as theme,
(preferences->>'notifications')::boolean as notifications_enabled
FROM users
WHERE preferences IS NOT NULL;

-- 47. ARRAY operations
SELECT id, name,
array_length(tags, 1) as tag_count,
UNNEST(tags) as individual_tag
FROM products;

-- 48. String functions
SELECT username,
UPPER(username) as uppercase,
LENGTH(username) as name_length,
SUBSTRING(email, 1, POSITION('@' IN email) - 1) as email_local_part
FROM users;

-- 49. Date functions
SELECT order_date,
DATE_TRUNC('month', order_date) as month,
EXTRACT(YEAR FROM order_date) as year,
EXTRACT(QUARTER FROM order_date) as quarter,
AGE(NOW(), order_date) as age
FROM orders;

-- 50. Mathematical functions
SELECT id, price,
ROUND(price, 2) as rounded_price,
CEIL(price) as ceiling_price,
FLOOR(price) as floor_price,
ABS(price - 100) as difference_from_100
FROM products;
