-- PostgreSQL 50 Runnable Examples
-- Complete executable examples with data setup and queries
-- Run with: psql -U postgres -d education_db -f runnable-examples.sql

-- ============================================
-- Setup: Create Tables and Insert Sample Data
-- ============================================

DROP TABLE IF EXISTS order_items CASCADE;
DROP TABLE IF EXISTS orders CASCADE;
DROP TABLE IF EXISTS reviews CASCADE;
DROP TABLE IF EXISTS products CASCADE;
DROP TABLE IF EXISTS users CASCADE;

-- Create users table
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  username VARCHAR(100) UNIQUE NOT NULL,
  email VARCHAR(100) UNIQUE NOT NULL,
  status VARCHAR(50) DEFAULT 'active',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create products table
CREATE TABLE products (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  category VARCHAR(100),
  price DECIMAL(10,2) NOT NULL,
  stock_quantity INT DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create orders table
CREATE TABLE orders (
  id SERIAL PRIMARY KEY,
  user_id INT NOT NULL REFERENCES users(id),
  total_amount DECIMAL(10,2),
  status VARCHAR(50) DEFAULT 'pending',
  order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create order_items table
CREATE TABLE order_items (
  id SERIAL PRIMARY KEY,
  order_id INT NOT NULL REFERENCES orders(id),
  product_id INT NOT NULL REFERENCES products(id),
  quantity INT NOT NULL,
  price DECIMAL(10,2)
);

-- Create reviews table
CREATE TABLE reviews (
  id SERIAL PRIMARY KEY,
  product_id INT NOT NULL REFERENCES products(id),
  user_id INT NOT NULL REFERENCES users(id),
  rating INT CHECK (rating >= 1 AND rating <= 5),
  comment TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert sample users
INSERT INTO users (username, email, status) VALUES
('john_doe', 'john@example.com', 'active'),
('jane_smith', 'jane@example.com', 'active'),
('bob_wilson', 'bob@example.com', 'inactive'),
('alice_johnson', 'alice@example.com', 'active'),
('charlie_brown', 'charlie@example.com', 'active'),
('diana_prince', 'diana@example.com', 'active'),
('eve_smith', 'eve@example.com', 'active'),
('frank_castle', 'frank@example.com', 'inactive'),
('grace_hopper', 'grace@example.com', 'active'),
('henry_ford', 'henry@example.com', 'active');

-- Insert sample products
INSERT INTO products (name, category, price, stock_quantity) VALUES
('Laptop', 'Electronics', 999.99, 50),
('Mouse', 'Electronics', 29.99, 200),
('Keyboard', 'Electronics', 79.99, 100),
('Monitor', 'Electronics', 299.99, 30),
('USB Cable', 'Accessories', 9.99, 500),
('Headphones', 'Electronics', 149.99, 80),
('Desk Chair', 'Furniture', 199.99, 25),
('Desk Lamp', 'Furniture', 49.99, 60),
('Phone Stand', 'Accessories', 14.99, 150),
('Webcam', 'Electronics', 89.99, 40);

-- Insert sample orders
INSERT INTO orders (user_id, total_amount, status) VALUES
(1, 1079.98, 'completed'),
(2, 339.98, 'completed'),
(1, 259.97, 'pending'),
(3, 149.99, 'completed'),
(4, 1269.95, 'completed'),
(5, 449.98, 'pending'),
(2, 99.98, 'completed'),
(6, 779.98, 'completed'),
(7, 189.98, 'pending'),
(8, 39.98, 'completed');

-- Insert sample order items
INSERT INTO order_items (order_id, product_id, quantity, price) VALUES
(1, 1, 1, 999.99),
(1, 5, 1, 9.99),
(1, 2, 3, 29.99),
(2, 3, 2, 79.99),
(2, 2, 2, 29.99),
(3, 6, 1, 149.99),
(3, 9, 1, 14.99),
(4, 6, 1, 149.99),
(5, 1, 1, 999.99),
(5, 4, 1, 299.99),
(6, 3, 3, 79.99),
(7, 2, 2, 29.99),
(7, 5, 1, 9.99),
(8, 1, 1, 999.99),
(8, 2, 1, 29.99),
(9, 3, 2, 79.99),
(10, 5, 4, 9.99);

-- Insert sample reviews
INSERT INTO reviews (product_id, user_id, rating, comment) VALUES
(1, 1, 5, 'Excellent laptop, very fast'),
(1, 2, 4, 'Good laptop, minor issues'),
(2, 3, 5, 'Perfect mouse'),
(3, 4, 4, 'Great keyboard'),
(4, 5, 5, 'Amazing monitor'),
(6, 1, 5, 'Best headphones ever'),
(7, 6, 4, 'Comfortable chair'),
(8, 7, 3, 'Good lamp'),
(9, 8, 5, 'Perfect stand'),
(10, 9, 4, 'Good webcam');

-- ============================================
-- Example 1-5: Basic SELECT Queries
-- ============================================

-- 1. Show all users
SELECT '=== Example 1: All Users ===' as info;
SELECT * FROM users LIMIT 5;

-- 2. Show active users only
SELECT '=== Example 2: Active Users ===' as info;
SELECT username, email FROM users WHERE status = 'active';

-- 3. Count total products
SELECT '=== Example 3: Product Count ===' as info;
SELECT COUNT(*) as total_products FROM products;

-- 4. Get products ordered by price
SELECT '=== Example 4: Products by Price ===' as info;
SELECT name, category, price FROM products ORDER BY price DESC LIMIT 5;

-- 5. Get user with their order count
SELECT '=== Example 5: User Order Count ===' as info;
SELECT username, COUNT(o.id) as order_count
FROM users u
LEFT JOIN orders o ON u.id = o.user_id
GROUP BY u.id, u.username
ORDER BY order_count DESC LIMIT 5;

-- ============================================
-- Example 6-10: JOIN Queries
-- ============================================

-- 6. Orders with customer names
SELECT '=== Example 6: Orders with Customer Names ===' as info;
SELECT u.username, o.id, o.total_amount, o.status
FROM users u
JOIN orders o ON u.id = o.user_id
LIMIT 5;

-- 7. Order items with product names
SELECT '=== Example 7: Order Details ===' as info;
SELECT o.id, p.name, oi.quantity, oi.price
FROM order_items oi
JOIN products p ON oi.product_id = p.id
JOIN orders o ON oi.order_id = o.id
LIMIT 5;

-- 8. Products with review count and average rating
SELECT '=== Example 8: Products with Reviews ===' as info;
SELECT p.name, COUNT(r.id) as review_count, AVG(r.rating) as avg_rating
FROM products p
LEFT JOIN reviews r ON p.id = r.product_id
GROUP BY p.id, p.name
LIMIT 5;

-- 9. Completed orders with order details
SELECT '=== Example 9: Completed Orders ===' as info;
SELECT u.username, o.id, COUNT(oi.id) as item_count, o.total_amount
FROM orders o
JOIN users u ON o.user_id = u.id
JOIN order_items oi ON o.id = oi.order_id
WHERE o.status = 'completed'
GROUP BY o.id, u.username
LIMIT 5;

-- 10. Users who never ordered
SELECT '=== Example 10: Users Without Orders ===' as info;
SELECT u.username FROM users u
WHERE NOT EXISTS (SELECT 1 FROM orders o WHERE o.user_id = u.id);

-- ============================================
-- Example 11-15: Aggregation Queries
-- ============================================

-- 11. Total sales by product
SELECT '=== Example 11: Sales by Product ===' as info;
SELECT p.name, SUM(oi.quantity) as total_sold, SUM(oi.quantity * oi.price) as revenue
FROM products p
JOIN order_items oi ON p.id = oi.product_id
GROUP BY p.id, p.name
ORDER BY revenue DESC LIMIT 5;

-- 12. Average order value
SELECT '=== Example 12: Average Order Value ===' as info;
SELECT AVG(total_amount) as avg_order_value FROM orders;

-- 13. Sales by category
SELECT '=== Example 13: Sales by Category ===' as info;
SELECT p.category, SUM(oi.quantity) as units_sold, SUM(oi.quantity * oi.price) as revenue
FROM products p
JOIN order_items oi ON p.id = oi.product_id
GROUP BY p.category
ORDER BY revenue DESC;

-- 14. User spending summary
SELECT '=== Example 14: User Spending ===' as info;
SELECT u.username, COUNT(o.id) as orders, SUM(o.total_amount) as total_spent, AVG(o.total_amount) as avg_spent
FROM users u
JOIN orders o ON u.id = o.user_id
GROUP BY u.id, u.username
ORDER BY total_spent DESC LIMIT 5;

-- 15. Product stock analysis
SELECT '=== Example 15: Stock Analysis ===' as info;
SELECT name, stock_quantity,
CASE
  WHEN stock_quantity > 100 THEN 'Well Stocked'
  WHEN stock_quantity > 50 THEN 'Adequate'
  WHEN stock_quantity > 0 THEN 'Low'
  ELSE 'Out of Stock'
END as stock_status
FROM products
ORDER BY stock_quantity DESC;

-- ============================================
-- Example 16-20: Subqueries
-- ============================================

-- 16. Products priced above average
SELECT '=== Example 16: Premium Products ===' as info;
SELECT name, price FROM products
WHERE price > (SELECT AVG(price) FROM products)
ORDER BY price DESC;

-- 17. Users who bought expensive items
SELECT '=== Example 17: VIP Customers ===' as info;
SELECT DISTINCT u.username FROM users u
WHERE u.id IN (
  SELECT DISTINCT user_id FROM orders
  WHERE total_amount > (SELECT AVG(total_amount) FROM orders)
);

-- 18. Top selling products
SELECT '=== Example 18: Top Products ===' as info;
SELECT p.name, SUM(oi.quantity) as units
FROM products p
JOIN order_items oi ON p.id = oi.product_id
GROUP BY p.id, p.name
HAVING SUM(oi.quantity) > (SELECT AVG(order_count) FROM (
  SELECT COUNT(*) as order_count FROM order_items GROUP BY product_id
) t)
ORDER BY units DESC;

-- 19. Orders with item count
SELECT '=== Example 19: Orders by Item Count ===' as info;
SELECT o.id, u.username, COUNT(oi.id) as items, o.total_amount
FROM orders o
JOIN users u ON o.user_id = u.id
JOIN order_items oi ON o.id = oi.order_id
GROUP BY o.id, u.username
HAVING COUNT(oi.id) >= 2
ORDER BY items DESC LIMIT 5;

-- 20. High-value customers
SELECT '=== Example 20: High-Value Customers ===' as info;
SELECT u.id, u.username, SUM(o.total_amount) as lifetime_value
FROM users u
JOIN orders o ON u.id = o.user_id
GROUP BY u.id, u.username
HAVING SUM(o.total_amount) > 200
ORDER BY lifetime_value DESC;

-- ============================================
-- Example 21-25: Window Functions
-- ============================================

-- 21. Rank products by price
SELECT '=== Example 21: Product Rank by Price ===' as info;
SELECT name, price,
RANK() OVER (ORDER BY price DESC) as price_rank
FROM products LIMIT 10;

-- 22. Running total of sales
SELECT '=== Example 22: Running Total ===' as info;
SELECT order_date, total_amount,
SUM(total_amount) OVER (ORDER BY order_date) as running_total
FROM orders LIMIT 10;

-- 23. Compare to previous order
SELECT '=== Example 23: Order Comparison ===' as info;
SELECT id, total_amount,
LAG(total_amount) OVER (ORDER BY order_date) as previous_order
FROM orders LIMIT 5;

-- 24. Percentile of prices
SELECT '=== Example 24: Price Percentiles ===' as info;
SELECT name, price,
PERCENT_RANK() OVER (ORDER BY price) as percentile
FROM products LIMIT 10;

-- 25. Row numbers for pagination
SELECT '=== Example 25: Pagination ===' as info;
SELECT ROW_NUMBER() OVER (ORDER BY id) as row_num, username, email
FROM users LIMIT 5;

-- ============================================
-- Example 26-30: Advanced Techniques
-- ============================================

-- 26. Orders with product list
SELECT '=== Example 26: Order Summary ===' as info;
SELECT o.id, u.username, STRING_AGG(p.name, ', ') as products, o.total_amount
FROM orders o
JOIN users u ON o.user_id = u.id
JOIN order_items oi ON o.id = oi.order_id
JOIN products p ON oi.product_id = p.id
GROUP BY o.id, u.username LIMIT 5;

-- 27. Monthly sales trend
SELECT '=== Example 27: Monthly Trend ===' as info;
SELECT DATE_TRUNC('month', order_date) as month, COUNT(*) as orders, SUM(total_amount) as revenue
FROM orders
WHERE status = 'completed'
GROUP BY month
ORDER BY month DESC;

-- 28. Customer lifecycle
SELECT '=== Example 28: Customer Lifecycle ===' as info;
SELECT u.username,
MIN(o.order_date) as first_order,
MAX(o.order_date) as last_order,
COUNT(o.id) as total_orders,
SUM(o.total_amount) as lifetime_value
FROM users u
JOIN orders o ON u.id = o.user_id
GROUP BY u.id, u.username
ORDER BY lifetime_value DESC LIMIT 5;

-- 29. Product popularity
SELECT '=== Example 29: Popular Products ===' as info;
SELECT p.name, p.category, COUNT(DISTINCT r.user_id) as reviewers, AVG(r.rating) as rating
FROM products p
LEFT JOIN reviews r ON p.id = r.product_id
GROUP BY p.id, p.name, p.category
ORDER BY rating DESC, reviewers DESC LIMIT 10;

-- 30. Cross-category analysis
SELECT '=== Example 30: Cross-Category ===' as info;
SELECT u.username,
COUNT(DISTINCT CASE WHEN p.category = 'Electronics' THEN o.id END) as electronics_orders,
COUNT(DISTINCT CASE WHEN p.category = 'Furniture' THEN o.id END) as furniture_orders,
COUNT(DISTINCT CASE WHEN p.category = 'Accessories' THEN o.id END) as accessories_orders
FROM users u
LEFT JOIN orders o ON u.id = o.user_id
LEFT JOIN order_items oi ON o.id = oi.order_id
LEFT JOIN products p ON oi.product_id = p.id
GROUP BY u.id, u.username
HAVING COUNT(DISTINCT o.id) > 0
LIMIT 5;

-- ============================================
-- Example 31-35: Data Modification
-- ============================================

-- 31. Update user status
SELECT '=== Example 31: Update Status ===' as info;
UPDATE users SET status = 'vip' WHERE id = 1
RETURNING username, status;

-- 32. Increase prices
SELECT '=== Example 32: Price Adjustment ===' as info;
UPDATE products SET price = price * 1.1 WHERE category = 'Electronics'
RETURNING name, price;

-- 33. Create promotion
SELECT '=== Example 33: Create Promotion ===' as info;
INSERT INTO products (name, category, price, stock_quantity)
VALUES ('Special Bundle', 'Accessories', 49.99, 100)
RETURNING *;

-- 34. Mark old orders as archived
SELECT '=== Example 34: Archive Orders ===' as info;
UPDATE orders SET status = 'archived' WHERE order_date < NOW() - INTERVAL '1 year'
RETURNING COUNT(*);

-- 35. Remove inactive users
SELECT '=== Example 35: Remove Inactive ===' as info;
DELETE FROM users WHERE status = 'inactive' AND id NOT IN (
  SELECT DISTINCT user_id FROM orders
)
RETURNING username;

-- ============================================
-- Example 36-40: Constraints & Validation
-- ============================================

-- 36. Check price constraints
SELECT '=== Example 36: Validate Prices ===' as info;
SELECT name, price,
CASE WHEN price < 0 THEN 'INVALID' ELSE 'OK' END as price_status
FROM products;

-- 37. Find missing values
SELECT '=== Example 37: Missing Data ===' as info;
SELECT id, name, category FROM products WHERE category IS NULL;

-- 38. Check order totals
SELECT '=== Example 38: Order Totals ===' as info;
SELECT o.id,
SUM(oi.quantity * oi.price) as calculated_total,
o.total_amount as recorded_total,
CASE
  WHEN SUM(oi.quantity * oi.price) = o.total_amount THEN 'OK'
  ELSE 'MISMATCH'
END as status
FROM orders o
LEFT JOIN order_items oi ON o.id = oi.order_id
GROUP BY o.id
LIMIT 5;

-- 39. Duplicate email check
SELECT '=== Example 39: Duplicate Check ===' as info;
SELECT email, COUNT(*) as count FROM users GROUP BY email HAVING COUNT(*) > 1;

-- 40. Data quality report
SELECT '=== Example 40: Data Quality ===' as info;
SELECT
  'Total Users' as metric, COUNT(*) as value FROM users
UNION ALL
SELECT 'Total Products', COUNT(*) FROM products
UNION ALL
SELECT 'Total Orders', COUNT(*) FROM orders
UNION ALL
SELECT 'Total Reviews', COUNT(*) FROM reviews
UNION ALL
SELECT 'Active Users', COUNT(*) FROM users WHERE status = 'active'
UNION ALL
SELECT 'Completed Orders', COUNT(*) FROM orders WHERE status = 'completed';

-- ============================================
-- Example 41-45: Performance Analysis
-- ============================================

-- 41. Index usage simulation
SELECT '=== Example 41: Slow Query Example ===' as info;
EXPLAIN ANALYZE
SELECT * FROM orders WHERE total_amount > 500;

-- 42. Sequential scan vs index
SELECT '=== Example 42: Query Planning ===' as info;
CREATE INDEX idx_users_email ON users(email);

-- 43. Query optimization
SELECT '=== Example 43: Optimized Query ===' as info;
SELECT u.username, COUNT(o.id) as orders
FROM users u
LEFT JOIN orders o ON u.id = o.user_id
WHERE u.status = 'active'
GROUP BY u.id
ORDER BY orders DESC;

-- 44. Full table scan detection
SELECT '=== Example 44: Table Scan ===' as info;
SELECT COUNT(*) FROM products;

-- 45. Index effectiveness
SELECT '=== Example 45: Index Performance ===' as info;
SELECT * FROM products WHERE id = 5;

-- ============================================
-- Example 46-50: Reporting
-- ============================================

-- 46. Sales report
SELECT '=== Example 46: Sales Report ===' as info;
SELECT DATE_TRUNC('week', order_date)::DATE as week, COUNT(*) as orders, SUM(total_amount) as revenue
FROM orders WHERE status = 'completed'
GROUP BY week ORDER BY week DESC LIMIT 4;

-- 47. Top customers
SELECT '=== Example 47: Top Customers ===' as info;
SELECT u.id, u.username, COUNT(o.id) as orders, SUM(o.total_amount) as spent
FROM users u JOIN orders o ON u.id = o.user_id
GROUP BY u.id ORDER BY spent DESC LIMIT 5;

-- 48. Inventory status
SELECT '=== Example 48: Inventory ===' as info;
SELECT category, SUM(stock_quantity) as total_stock, COUNT(*) as products
FROM products GROUP BY category;

-- 49. Customer acquisition
SELECT '=== Example 49: New Customers ===' as info;
SELECT DATE_TRUNC('month', created_at)::DATE as month, COUNT(*) as new_users
FROM users GROUP BY month ORDER BY month DESC;

-- 50. Revenue forecast
SELECT '=== Example 50: Revenue Trend ===' as info;
SELECT DATE_TRUNC('month', order_date)::DATE as month,
AVG(total_amount) as avg_order_value, COUNT(*) as orders
FROM orders WHERE status = 'completed'
GROUP BY month ORDER BY month DESC LIMIT 6;

-- ============================================
-- Cleanup (optional)
-- ============================================
-- DROP TABLE IF EXISTS order_items CASCADE;
-- DROP TABLE IF EXISTS orders CASCADE;
-- DROP TABLE IF EXISTS reviews CASCADE;
-- DROP TABLE IF EXISTS products CASCADE;
-- DROP TABLE IF EXISTS users CASCADE;
