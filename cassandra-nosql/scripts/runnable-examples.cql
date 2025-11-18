-- Cassandra 50 Runnable Examples
-- Run with: cqlsh < runnable-examples.cql

CREATE KEYSPACE IF NOT EXISTS education WITH replication = {'class': 'SimpleStrategy', 'replication_factor': 1};
USE education;

-- Create tables
CREATE TABLE IF NOT EXISTS users (user_id UUID PRIMARY KEY, username TEXT, email TEXT, created_at TIMESTAMP);
CREATE TABLE IF NOT EXISTS products (product_id UUID PRIMARY KEY, name TEXT, category TEXT, price DECIMAL);
CREATE TABLE IF NOT EXISTS orders (order_id UUID PRIMARY KEY, user_id UUID, total DECIMAL, status TEXT);

-- Example 1-5: Basic inserts
INSERT INTO users (user_id, username, email) VALUES (uuid(), 'john_doe', 'john@example.com');
INSERT INTO users (user_id, username, email) VALUES (uuid(), 'jane_smith', 'jane@example.com');
INSERT INTO products (product_id, name, category, price) VALUES (uuid(), 'Laptop', 'Electronics', 999.99);
INSERT INTO products (product_id, name, category, price) VALUES (uuid(), 'Mouse', 'Electronics', 29.99);
INSERT INTO orders (order_id, user_id, total, status) VALUES (uuid(), uuid(), 1079.98, 'completed');

-- Example 6-10: Queries
SELECT COUNT(*) FROM users;
SELECT * FROM products WHERE category = 'Electronics' ALLOW FILTERING;
SELECT * FROM orders WHERE status = 'completed' ALLOW FILTERING;

-- Example 11-15: Batch operations
BEGIN BATCH
  INSERT INTO users (user_id, username) VALUES (uuid(), 'alice');
  INSERT INTO users (user_id, username) VALUES (uuid(), 'bob');
  INSERT INTO products (product_id, name, price) VALUES (uuid(), 'Keyboard', 79.99);
APPLY BATCH;

-- Example 16-20: Updates
UPDATE users SET username = 'john' WHERE user_id = uuid();
UPDATE products SET price = 899.99 WHERE product_id = uuid();
UPDATE orders SET status = 'shipped' WHERE order_id = uuid();

-- Example 21-25: Conditions
SELECT * FROM users LIMIT 10;
SELECT username, email FROM users;
SELECT name, price FROM products ORDER BY price DESC LIMIT 5;

-- Example 26-30: Collection operations
ALTER TABLE users ADD tags SET<TEXT>;
UPDATE users SET tags = tags + {'vip'} WHERE username = 'john' ALLOW FILTERING;

-- Example 31-35: Aggregation
SELECT COUNT(*) as total FROM products;
SELECT category, COUNT(*) FROM products GROUP BY category;

-- Example 36-40: Data types
SELECT * FROM users WHERE user_id = uuid() ALLOW FILTERING;
SELECT * FROM orders WHERE total > 100 ALLOW FILTERING;

-- Example 41-45: TTL
INSERT INTO users (user_id, username, email) VALUES (uuid(), 'temp', 'temp@example.com') USING TTL 3600;

-- Example 46-50: Clean operations
DELETE FROM users WHERE username = 'temp' ALLOW FILTERING;
TRUNCATE users;
DROP TABLE IF EXISTS orders;
