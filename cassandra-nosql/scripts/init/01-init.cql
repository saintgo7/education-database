-- Cassandra Initialization Script

-- Create keyspace with replication
CREATE KEYSPACE IF NOT EXISTS education
  WITH replication = {
    'class': 'SimpleStrategy',
    'replication_factor': 3
  }
  AND durable_writes = true;

USE education;

-- Users table
CREATE TABLE IF NOT EXISTS users (
  user_id UUID PRIMARY KEY,
  username TEXT,
  email TEXT,
  created_at TIMESTAMP,
  status TEXT
);

-- Products table
CREATE TABLE IF NOT EXISTS products (
  product_id UUID PRIMARY KEY,
  name TEXT,
  category TEXT,
  price DECIMAL,
  in_stock BOOLEAN,
  created_at TIMESTAMP
);

-- Orders table
CREATE TABLE IF NOT EXISTS orders (
  order_id UUID PRIMARY KEY,
  user_id UUID,
  order_date TIMESTAMP,
  total_amount DECIMAL,
  status TEXT
);

-- Reviews table (wide column example)
CREATE TABLE IF NOT EXISTS reviews (
  product_id UUID,
  review_date TIMESTAMP,
  user_id UUID,
  rating INT,
  content TEXT,
  PRIMARY KEY (product_id, review_date, user_id)
) WITH CLUSTERING ORDER BY (review_date DESC);

-- Create secondary index on user_id
CREATE INDEX IF NOT EXISTS orders_user_idx ON orders (user_id);
CREATE INDEX IF NOT EXISTS products_category_idx ON products (category);

-- Insert sample data
INSERT INTO users (user_id, username, email, created_at, status)
VALUES (uuid(), 'john_doe', 'john@example.com', toTimestamp(now()), 'active');

INSERT INTO products (product_id, name, category, price, in_stock, created_at)
VALUES (uuid(), 'Wireless Headphones', 'Electronics', 199.99, true, toTimestamp(now()));
