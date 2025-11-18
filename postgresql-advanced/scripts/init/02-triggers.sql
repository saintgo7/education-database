-- Triggers and Stored Procedures
-- Demonstrates advanced PostgreSQL automation

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply updated_at trigger to all relevant tables
CREATE TRIGGER update_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_products_updated_at
    BEFORE UPDATE ON products
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_orders_updated_at
    BEFORE UPDATE ON orders
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_reviews_updated_at
    BEFORE UPDATE ON reviews
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Audit log trigger function
CREATE OR REPLACE FUNCTION audit_trigger_function()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'DELETE' THEN
        INSERT INTO audit_log (table_name, operation, old_data)
        VALUES (TG_TABLE_NAME, TG_OP, row_to_json(OLD));
        RETURN OLD;
    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO audit_log (table_name, operation, old_data, new_data)
        VALUES (TG_TABLE_NAME, TG_OP, row_to_json(OLD), row_to_json(NEW));
        RETURN NEW;
    ELSIF TG_OP = 'INSERT' THEN
        INSERT INTO audit_log (table_name, operation, new_data)
        VALUES (TG_TABLE_NAME, TG_OP, row_to_json(NEW));
        RETURN NEW;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Apply audit triggers
CREATE TRIGGER audit_users
    AFTER INSERT OR UPDATE OR DELETE ON users
    FOR EACH ROW EXECUTE FUNCTION audit_trigger_function();

CREATE TRIGGER audit_products
    AFTER INSERT OR UPDATE OR DELETE ON products
    FOR EACH ROW EXECUTE FUNCTION audit_trigger_function();

CREATE TRIGGER audit_orders
    AFTER INSERT OR UPDATE OR DELETE ON orders
    FOR EACH ROW EXECUTE FUNCTION audit_trigger_function();

-- Stock validation trigger
CREATE OR REPLACE FUNCTION check_product_stock()
RETURNS TRIGGER AS $$
DECLARE
    available_stock INTEGER;
BEGIN
    SELECT stock_quantity INTO available_stock
    FROM products
    WHERE product_id = NEW.product_id;

    IF available_stock < NEW.quantity THEN
        RAISE EXCEPTION 'Insufficient stock for product %. Available: %, Requested: %',
            NEW.product_id, available_stock, NEW.quantity;
    END IF;

    -- Decrease stock
    UPDATE products
    SET stock_quantity = stock_quantity - NEW.quantity
    WHERE product_id = NEW.product_id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_stock_before_order
    BEFORE INSERT ON order_items
    FOR EACH ROW
    EXECUTE FUNCTION check_product_stock();

-- Order status update trigger
CREATE OR REPLACE FUNCTION update_order_timestamps()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.status = 'shipped' AND OLD.status != 'shipped' THEN
        NEW.shipped_at = CURRENT_TIMESTAMP;
    ELSIF NEW.status = 'delivered' AND OLD.status != 'delivered' THEN
        NEW.delivered_at = CURRENT_TIMESTAMP;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER order_status_timestamp
    BEFORE UPDATE ON orders
    FOR EACH ROW
    EXECUTE FUNCTION update_order_timestamps();

-- Stored Procedures

-- Create order with items
CREATE OR REPLACE PROCEDURE create_order(
    p_user_id UUID,
    p_items JSONB,
    p_shipping_address JSONB,
    OUT p_order_id UUID
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_order_number VARCHAR(50);
    v_total_amount NUMERIC(10, 2) := 0;
    v_item JSONB;
    v_product_price NUMERIC(10, 2);
BEGIN
    -- Generate order number
    v_order_number := 'ORD-' || TO_CHAR(CURRENT_TIMESTAMP, 'YYYYMMDD-') ||
                      LPAD(NEXTVAL('orders_seq')::TEXT, 6, '0');

    -- Create order
    INSERT INTO orders (user_id, order_number, total_amount, shipping_address)
    VALUES (p_user_id, v_order_number, 0, p_shipping_address)
    RETURNING order_id INTO p_order_id;

    -- Add order items
    FOR v_item IN SELECT * FROM jsonb_array_elements(p_items)
    LOOP
        SELECT price INTO v_product_price
        FROM products
        WHERE product_id = (v_item->>'product_id')::UUID;

        INSERT INTO order_items (order_id, product_id, quantity, unit_price)
        VALUES (
            p_order_id,
            (v_item->>'product_id')::UUID,
            (v_item->>'quantity')::INTEGER,
            v_product_price
        );

        v_total_amount := v_total_amount + (v_product_price * (v_item->>'quantity')::INTEGER);
    END LOOP;

    -- Update order total
    UPDATE orders SET total_amount = v_total_amount WHERE order_id = p_order_id;

    COMMIT;
END;
$$;

-- Create sequence for order numbers
CREATE SEQUENCE IF NOT EXISTS orders_seq START 1;

-- Update product statistics
CREATE OR REPLACE PROCEDURE update_product_statistics()
LANGUAGE plpgsql
AS $$
BEGIN
    -- Create materialized view for product stats if not exists
    CREATE MATERIALIZED VIEW IF NOT EXISTS product_statistics AS
    SELECT
        p.product_id,
        p.name,
        COUNT(DISTINCT oi.order_id) as total_orders,
        SUM(oi.quantity) as total_quantity_sold,
        SUM(oi.subtotal) as total_revenue,
        AVG(r.rating) as average_rating,
        COUNT(DISTINCT r.review_id) as review_count
    FROM products p
    LEFT JOIN order_items oi ON p.product_id = oi.product_id
    LEFT JOIN reviews r ON p.product_id = r.product_id
    GROUP BY p.product_id, p.name;

    -- Refresh the view
    REFRESH MATERIALIZED VIEW product_statistics;
END;
$$;

-- Function to get user order history
CREATE OR REPLACE FUNCTION get_user_order_history(p_user_id UUID)
RETURNS TABLE (
    order_id UUID,
    order_number VARCHAR,
    status order_status,
    total_amount NUMERIC,
    created_at TIMESTAMP,
    items JSONB
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        o.order_id,
        o.order_number,
        o.status,
        o.total_amount,
        o.created_at,
        jsonb_agg(
            jsonb_build_object(
                'product_id', oi.product_id,
                'product_name', p.name,
                'quantity', oi.quantity,
                'unit_price', oi.unit_price,
                'subtotal', oi.subtotal
            )
        ) as items
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    JOIN products p ON oi.product_id = p.product_id
    WHERE o.user_id = p_user_id
    GROUP BY o.order_id, o.order_number, o.status, o.total_amount, o.created_at
    ORDER BY o.created_at DESC;
END;
$$ LANGUAGE plpgsql;

-- Function to search products
CREATE OR REPLACE FUNCTION search_products(
    p_search_term TEXT,
    p_category VARCHAR DEFAULT NULL,
    p_min_price NUMERIC DEFAULT NULL,
    p_max_price NUMERIC DEFAULT NULL
)
RETURNS TABLE (
    product_id UUID,
    name VARCHAR,
    category VARCHAR,
    price NUMERIC,
    stock_quantity INTEGER,
    similarity REAL
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        p.product_id,
        p.name,
        p.category,
        p.price,
        p.stock_quantity,
        similarity(p.name, p_search_term) as similarity
    FROM products p
    WHERE
        (p.name ILIKE '%' || p_search_term || '%' OR
         p.description ILIKE '%' || p_search_term || '%')
        AND (p_category IS NULL OR p.category = p_category)
        AND (p_min_price IS NULL OR p.price >= p_min_price)
        AND (p_max_price IS NULL OR p.price <= p_max_price)
    ORDER BY similarity DESC, p.name
    LIMIT 100;
END;
$$ LANGUAGE plpgsql;

-- Comments
COMMENT ON FUNCTION update_updated_at_column IS 'Automatically updates updated_at timestamp';
COMMENT ON FUNCTION audit_trigger_function IS 'Logs all changes to audit_log table';
COMMENT ON PROCEDURE create_order IS 'Creates an order with multiple items atomically';
COMMENT ON FUNCTION get_user_order_history IS 'Returns complete order history for a user';
COMMENT ON FUNCTION search_products IS 'Full-text search with filters and ranking';
