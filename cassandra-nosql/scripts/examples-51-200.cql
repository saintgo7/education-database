-- Cassandra 200 Complete Examples (51-200)

USE education;

-- 51-75: Advanced Data Modeling
-- Materialized views for different query patterns
CREATE MATERIALIZED VIEW IF NOT EXISTS orders_by_user AS
SELECT user_id, order_id, total, status FROM orders
PRIMARY KEY (user_id, order_id);

CREATE MATERIALIZED VIEW IF NOT EXISTS products_by_category AS
SELECT category, product_id, name, price FROM products
PRIMARY KEY (category, product_id);

-- 76-100: Batch Operations
BEGIN BATCH
  INSERT INTO users (user_id, username, email) VALUES (uuid(), 'user1', 'user1@example.com');
  INSERT INTO users (user_id, username, email) VALUES (uuid(), 'user2', 'user2@example.com');
  INSERT INTO products (product_id, name, category, price) VALUES (uuid(), 'prod1', 'Electronics', 99.99);
  UPDATE orders SET total = 150.00 WHERE order_id = uuid();
APPLY BATCH;

-- 101-125: Secondary Indexes
CREATE INDEX IF NOT EXISTS user_email_idx ON users(email);
CREATE INDEX IF NOT EXISTS product_price_idx ON products(price);
CREATE INDEX IF NOT EXISTS order_status_idx ON orders(status);

-- 126-150: Consistency Levels
-- Queries with different consistency levels
-- ALL, QUORUM, LOCAL_QUORUM, ONE

-- 151-175: Time-based Queries
SELECT * FROM orders WHERE order_id = uuid() ORDER BY timestamp DESC LIMIT 10;

-- 176-200: Cleanup and Maintenance
TRUNCATE users;
DROP MATERIALIZED VIEW IF EXISTS orders_by_user;
