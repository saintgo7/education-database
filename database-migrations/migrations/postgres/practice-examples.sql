-- Database Migrations Practice Examples for PostgreSQL
-- Flyway-style migration naming: V###__description.sql

-- ============================================
-- 1-10: Basic Schema Migrations
-- ============================================

-- V001__Create_users_table.sql
CREATE TABLE IF NOT EXISTS users (
  id SERIAL PRIMARY KEY,
  username VARCHAR(100) UNIQUE NOT NULL,
  email VARCHAR(100) UNIQUE NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- V002__Create_products_table.sql
CREATE TABLE IF NOT EXISTS products (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  price DECIMAL(10,2) NOT NULL,
  category VARCHAR(100),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- V003__Create_orders_table.sql
CREATE TABLE IF NOT EXISTS orders (
  id SERIAL PRIMARY KEY,
  user_id INTEGER NOT NULL REFERENCES users(id),
  total_amount DECIMAL(10,2) NOT NULL,
  status VARCHAR(50) DEFAULT 'pending',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- V004__Create_order_items_table.sql
CREATE TABLE IF NOT EXISTS order_items (
  id SERIAL PRIMARY KEY,
  order_id INTEGER NOT NULL REFERENCES orders(id),
  product_id INTEGER NOT NULL REFERENCES products(id),
  quantity INTEGER NOT NULL,
  price DECIMAL(10,2) NOT NULL
);

-- V005__Add_phone_column_to_users.sql
ALTER TABLE users ADD COLUMN IF NOT EXISTS phone VARCHAR(20);

-- V006__Add_description_column_to_products.sql
ALTER TABLE products ADD COLUMN IF NOT EXISTS description TEXT;

-- V007__Add_status_column_to_users.sql
ALTER TABLE users ADD COLUMN IF NOT EXISTS status VARCHAR(50) DEFAULT 'active';

-- V008__Rename_total_amount_to_order_total.sql
ALTER TABLE orders RENAME COLUMN total_amount TO order_total;

-- V009__Create_index_on_user_email.sql
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);

-- V010__Create_index_on_orders_user_id.sql
CREATE INDEX IF NOT EXISTS idx_orders_user_id ON orders(user_id);

-- ============================================
-- 11-20: Constraints and Modifications
-- ============================================

-- V011__Add_price_constraint_to_products.sql
ALTER TABLE products ADD CONSTRAINT check_price_positive CHECK (price > 0);

-- V012__Add_quantity_constraint_to_order_items.sql
ALTER TABLE order_items ADD CONSTRAINT check_quantity_positive CHECK (quantity > 0);

-- V013__Add_unique_constraint_to_products_name.sql
ALTER TABLE products ADD CONSTRAINT unique_product_name UNIQUE(name);

-- V014__Add_not_null_constraint_to_order_status.sql
ALTER TABLE orders ALTER COLUMN status SET NOT NULL;

-- V015__Create_reviews_table.sql
CREATE TABLE IF NOT EXISTS reviews (
  id SERIAL PRIMARY KEY,
  product_id INTEGER NOT NULL REFERENCES products(id),
  user_id INTEGER NOT NULL REFERENCES users(id),
  rating INTEGER CHECK (rating >= 1 AND rating <= 5),
  comment TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- V016__Add_updated_at_column_to_users.sql
ALTER TABLE users ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

-- V017__Create_categories_table.sql
CREATE TABLE IF NOT EXISTS categories (
  id SERIAL PRIMARY KEY,
  name VARCHAR(100) UNIQUE NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- V018__Add_category_id_to_products.sql
ALTER TABLE products ADD COLUMN IF NOT EXISTS category_id INTEGER REFERENCES categories(id);

-- V019__Create_inventory_table.sql
CREATE TABLE IF NOT EXISTS inventory (
  id SERIAL PRIMARY KEY,
  product_id INTEGER NOT NULL UNIQUE REFERENCES products(id),
  quantity_in_stock INTEGER NOT NULL DEFAULT 0,
  last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- V020__Drop_category_column_from_products.sql
ALTER TABLE products DROP COLUMN IF EXISTS category;

-- ============================================
-- 21-30: Complex Schema Changes
-- ============================================

-- V021__Create_user_preferences_table.sql
CREATE TABLE IF NOT EXISTS user_preferences (
  id SERIAL PRIMARY KEY,
  user_id INTEGER UNIQUE NOT NULL REFERENCES users(id),
  newsletter_enabled BOOLEAN DEFAULT true,
  theme VARCHAR(50) DEFAULT 'light',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- V022__Create_payment_methods_table.sql
CREATE TABLE IF NOT EXISTS payment_methods (
  id SERIAL PRIMARY KEY,
  user_id INTEGER NOT NULL REFERENCES users(id),
  payment_type VARCHAR(50) NOT NULL,
  card_last_four VARCHAR(4),
  is_default BOOLEAN DEFAULT false,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- V023__Add_payment_method_id_to_orders.sql
ALTER TABLE orders ADD COLUMN IF NOT EXISTS payment_method_id INTEGER REFERENCES payment_methods(id);

-- V024__Create_shipping_addresses_table.sql
CREATE TABLE IF NOT EXISTS shipping_addresses (
  id SERIAL PRIMARY KEY,
  user_id INTEGER NOT NULL REFERENCES users(id),
  street VARCHAR(255) NOT NULL,
  city VARCHAR(100) NOT NULL,
  state VARCHAR(50),
  postal_code VARCHAR(20),
  country VARCHAR(100),
  is_default BOOLEAN DEFAULT false,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- V025__Add_shipping_address_id_to_orders.sql
ALTER TABLE orders ADD COLUMN IF NOT EXISTS shipping_address_id INTEGER REFERENCES shipping_addresses(id);

-- V026__Create_product_images_table.sql
CREATE TABLE IF NOT EXISTS product_images (
  id SERIAL PRIMARY KEY,
  product_id INTEGER NOT NULL REFERENCES products(id),
  image_url VARCHAR(500) NOT NULL,
  alt_text VARCHAR(255),
  is_primary BOOLEAN DEFAULT false,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- V027__Create_coupon_codes_table.sql
CREATE TABLE IF NOT EXISTS coupon_codes (
  id SERIAL PRIMARY KEY,
  code VARCHAR(50) UNIQUE NOT NULL,
  discount_percent DECIMAL(5,2),
  discount_amount DECIMAL(10,2),
  expiry_date DATE,
  max_uses INTEGER,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- V028__Add_coupon_code_id_to_orders.sql
ALTER TABLE orders ADD COLUMN IF NOT EXISTS coupon_code_id INTEGER REFERENCES coupon_codes(id);

-- V029__Create_order_status_history_table.sql
CREATE TABLE IF NOT EXISTS order_status_history (
  id SERIAL PRIMARY KEY,
  order_id INTEGER NOT NULL REFERENCES orders(id),
  status VARCHAR(50) NOT NULL,
  changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  changed_by VARCHAR(100)
);

-- V030__Create_user_login_history_table.sql
CREATE TABLE IF NOT EXISTS user_login_history (
  id SERIAL PRIMARY KEY,
  user_id INTEGER NOT NULL REFERENCES users(id),
  login_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  ip_address VARCHAR(45),
  user_agent TEXT
);

-- ============================================
-- 31-40: Views and Functions
-- ============================================

-- V031__Create_user_orders_summary_view.sql
CREATE OR REPLACE VIEW user_orders_summary AS
SELECT u.id, u.username, COUNT(o.id) as total_orders, SUM(o.order_total) as total_spent
FROM users u
LEFT JOIN orders o ON u.id = o.user_id
GROUP BY u.id, u.username;

-- V032__Create_product_sales_view.sql
CREATE OR REPLACE VIEW product_sales AS
SELECT p.id, p.name, COUNT(oi.id) as total_sold, SUM(oi.quantity) as quantity_sold
FROM products p
LEFT JOIN order_items oi ON p.id = oi.product_id
GROUP BY p.id, p.name;

-- V033__Create_monthly_revenue_view.sql
CREATE OR REPLACE VIEW monthly_revenue AS
SELECT DATE_TRUNC('month', o.created_at) as month, SUM(o.order_total) as revenue
FROM orders o
WHERE o.status = 'completed'
GROUP BY DATE_TRUNC('month', o.created_at);

-- V034__Create_update_user_timestamp_function.sql
CREATE OR REPLACE FUNCTION update_user_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = CURRENT_TIMESTAMP;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- V035__Create_trigger_for_user_updates.sql
CREATE TRIGGER trigger_update_user_timestamp
BEFORE UPDATE ON users
FOR EACH ROW
EXECUTE FUNCTION update_user_timestamp();

-- V036__Create_calculate_order_total_function.sql
CREATE OR REPLACE FUNCTION calculate_order_total(order_id INTEGER)
RETURNS DECIMAL AS $$
BEGIN
  RETURN (
    SELECT SUM(quantity * price)
    FROM order_items
    WHERE order_id = $1
  );
END;
$$ LANGUAGE plpgsql;

-- V037__Create_inventory_check_trigger.sql
CREATE OR REPLACE FUNCTION check_inventory()
RETURNS TRIGGER AS $$
BEGIN
  IF (SELECT quantity_in_stock FROM inventory WHERE product_id = NEW.product_id) < NEW.quantity THEN
    RAISE EXCEPTION 'Insufficient inventory for product %', NEW.product_id;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- V038__Create_order_items_trigger.sql
CREATE TRIGGER trigger_check_inventory
BEFORE INSERT ON order_items
FOR EACH ROW
EXECUTE FUNCTION check_inventory();

-- V039__Create_get_user_total_spent_function.sql
CREATE OR REPLACE FUNCTION get_user_total_spent(user_id INTEGER)
RETURNS DECIMAL AS $$
BEGIN
  RETURN COALESCE(SUM(order_total), 0)
  FROM orders
  WHERE orders.user_id = $1 AND status = 'completed';
END;
$$ LANGUAGE plpgsql;

-- V040__Create_get_top_products_function.sql
CREATE OR REPLACE FUNCTION get_top_products(limit_count INTEGER)
RETURNS TABLE (product_id INTEGER, product_name VARCHAR, total_sold BIGINT) AS $$
BEGIN
  RETURN QUERY
  SELECT p.id, p.name, SUM(oi.quantity)::BIGINT
  FROM products p
  JOIN order_items oi ON p.id = oi.product_id
  GROUP BY p.id, p.name
  ORDER BY total_sold DESC
  LIMIT limit_count;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- 41-50: Data Modifications and Cleanup
-- ============================================

-- V041__Backfill_product_category_ids.sql
UPDATE products SET category_id = 1 WHERE category_id IS NULL AND category = 'Electronics';

-- V042__Backfill_inventory_from_products.sql
INSERT INTO inventory (product_id, quantity_in_stock)
SELECT id, COALESCE(stock_quantity, 0) FROM products
WHERE id NOT IN (SELECT product_id FROM inventory);

-- V043__Add_default_shipping_address.sql
INSERT INTO shipping_addresses (user_id, street, city, country, is_default)
SELECT id, 'Not specified', 'Not specified', 'Not specified', true
FROM users WHERE id NOT IN (SELECT user_id FROM shipping_addresses WHERE is_default = true);

-- V044__Add_default_payment_method.sql
INSERT INTO payment_methods (user_id, payment_type, is_default)
SELECT id, 'credit_card', true FROM users
WHERE id NOT IN (SELECT user_id FROM payment_methods WHERE is_default = true);

-- V045__Migrate_old_reviews_to_new_format.sql
UPDATE reviews SET rating = 5 WHERE rating IS NULL;

-- V046__Clean_up_deleted_orders.sql
DELETE FROM order_items WHERE order_id IN
(SELECT id FROM orders WHERE created_at < NOW() - INTERVAL '5 years' AND status = 'cancelled');

-- V047__Update_product_names_to_title_case.sql
UPDATE products SET name = INITCAP(name);

-- V048__Add_missing_created_at_timestamps.sql
UPDATE users SET created_at = CURRENT_TIMESTAMP WHERE created_at IS NULL;

-- V049__Deactivate_inactive_users.sql
UPDATE users SET status = 'inactive'
WHERE status != 'inactive' AND updated_at < NOW() - INTERVAL '1 year';

-- V050__Create_archive_table_for_old_orders.sql
CREATE TABLE IF NOT EXISTS archived_orders AS
SELECT * FROM orders WHERE created_at < NOW() - INTERVAL '2 years';
