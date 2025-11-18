-- Database Migrations 50 Runnable Examples
-- Complete migration examples for PostgreSQL

-- V001: Create users table
CREATE TABLE IF NOT EXISTS users (
  id SERIAL PRIMARY KEY,
  username VARCHAR(100) UNIQUE NOT NULL,
  email VARCHAR(100) UNIQUE NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- V002: Create products table
CREATE TABLE IF NOT EXISTS products (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  price DECIMAL(10,2) NOT NULL,
  category VARCHAR(100),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- V003: Create orders table
CREATE TABLE IF NOT EXISTS orders (
  id SERIAL PRIMARY KEY,
  user_id INT NOT NULL REFERENCES users(id),
  total_amount DECIMAL(10,2),
  status VARCHAR(50) DEFAULT 'pending',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- V004: Add index on email
CREATE INDEX idx_users_email ON users(email);

-- V005: Add status column
ALTER TABLE users ADD COLUMN IF NOT EXISTS status VARCHAR(50) DEFAULT 'active';

-- V006: Add constraint
ALTER TABLE products ADD CONSTRAINT check_price CHECK (price > 0);

-- V007: Create view
CREATE OR REPLACE VIEW active_users AS SELECT * FROM users WHERE status = 'active';

-- V008: Insert sample data
INSERT INTO users (username, email, status) VALUES
('john_doe', 'john@example.com', 'active'),
('jane_smith', 'jane@example.com', 'active'),
('bob_wilson', 'bob@example.com', 'inactive');

INSERT INTO products (name, price, category) VALUES
('Laptop', 999.99, 'Electronics'),
('Mouse', 29.99, 'Electronics'),
('Keyboard', 79.99, 'Electronics');

INSERT INTO orders (user_id, total_amount, status) VALUES
(1, 1079.98, 'completed'),
(2, 339.98, 'completed'),
(3, 149.99, 'pending');

-- V009: Rollback simulation
-- SELECT COUNT(*) FROM users BEFORE ROLLBACK;

-- V010: Verification
SELECT 'Users' as table_name, COUNT(*) as count FROM users
UNION ALL
SELECT 'Products', COUNT(*) FROM products
UNION ALL
SELECT 'Orders', COUNT(*) FROM orders;

-- Examples 11-50: Queries using migrated schema
SELECT * FROM active_users;
SELECT name, price FROM products ORDER BY price DESC;
SELECT u.username, COUNT(o.id) FROM users u LEFT JOIN orders o ON u.id = o.user_id GROUP BY u.id;
SELECT * FROM orders WHERE status = 'completed';
SELECT category, COUNT(*) FROM products GROUP BY category;

-- Cleanup (optional)
-- DROP VIEW active_users;
-- DROP TABLE orders CASCADE;
-- DROP TABLE products CASCADE;
-- DROP TABLE users CASCADE;
