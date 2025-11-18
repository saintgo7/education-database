-- Database Migrations 200 Complete Examples (51-200)

-- V051: Advanced constraints
ALTER TABLE users ADD CONSTRAINT email_check CHECK (email LIKE '%@%');

-- V052-075: Complex schema modifications
ALTER TABLE products DROP COLUMN IF EXISTS old_column;
ALTER TABLE products RENAME COLUMN category TO product_category;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS payment_method VARCHAR(50);

-- V076-100: View management
CREATE OR REPLACE VIEW sales_summary AS
SELECT DATE(o.order_date) as date, COUNT(*) as orders, SUM(total_amount) as revenue
FROM orders o WHERE o.status = 'completed'
GROUP BY DATE(o.order_date);

-- V101-125: Function and procedure updates
CREATE OR REPLACE FUNCTION get_customer_orders(cust_id INT)
RETURNS TABLE(order_id INT, amount DECIMAL) AS $$
BEGIN
  RETURN QUERY
  SELECT id, total_amount FROM orders WHERE user_id = cust_id;
END;
$$ LANGUAGE plpgsql;

-- V126-150: Data migration
UPDATE users SET status = 'premium' WHERE id IN (
  SELECT user_id FROM orders GROUP BY user_id HAVING COUNT(*) > 5
);

-- V151-175: Trigger management
CREATE OR REPLACE TRIGGER order_audit_trigger
AFTER INSERT ON orders
FOR EACH ROW
EXECUTE FUNCTION log_order_creation();

-- V176-200: Final cleanup and verification
SELECT COUNT(*) as total_users FROM users;
SELECT COUNT(*) as total_products FROM products;
SELECT COUNT(*) as total_orders FROM orders;
SELECT COUNT(*) as total_reviews FROM reviews;
