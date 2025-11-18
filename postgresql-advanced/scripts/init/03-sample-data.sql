-- Sample Data Generation
-- Generates 1000+ records for testing and learning

-- Generate 500 users
INSERT INTO users (username, email, full_name, status, preferences, last_login)
SELECT
    'user_' || generate_series,
    'user_' || generate_series || '@example.com',
    CASE (random() * 5)::int
        WHEN 0 THEN 'John Doe'
        WHEN 1 THEN 'Jane Smith'
        WHEN 2 THEN 'Mike Johnson'
        WHEN 3 THEN 'Sarah Williams'
        WHEN 4 THEN 'David Brown'
        ELSE 'Emma Davis'
    END || ' #' || generate_series,
    CASE (random() * 2)::int
        WHEN 0 THEN 'active'::user_status
        WHEN 1 THEN 'active'::user_status
        ELSE 'inactive'::user_status
    END,
    jsonb_build_object(
        'theme', CASE (random() * 2)::int WHEN 0 THEN 'light' WHEN 1 THEN 'dark' ELSE 'auto' END,
        'language', CASE (random() * 3)::int WHEN 0 THEN 'en' WHEN 1 THEN 'ko' WHEN 2 THEN 'ja' ELSE 'zh' END,
        'notifications', random() > 0.5,
        'newsletter', random() > 0.3
    ),
    CURRENT_TIMESTAMP - (random() * interval '365 days')
FROM generate_series(1, 500);

-- Generate 300 products
INSERT INTO products (sku, name, description, category, price, stock_quantity, attributes)
SELECT
    'SKU-' || LPAD(generate_series::TEXT, 6, '0'),
    CASE (random() * 10)::int
        WHEN 0 THEN 'Laptop'
        WHEN 1 THEN 'Smartphone'
        WHEN 2 THEN 'Tablet'
        WHEN 3 THEN 'Headphones'
        WHEN 4 THEN 'Keyboard'
        WHEN 5 THEN 'Mouse'
        WHEN 6 THEN 'Monitor'
        WHEN 7 THEN 'Webcam'
        WHEN 8 THEN 'Speaker'
        ELSE 'Charger'
    END || ' ' || CASE (random() * 5)::int
        WHEN 0 THEN 'Pro'
        WHEN 1 THEN 'Plus'
        WHEN 2 THEN 'Max'
        WHEN 3 THEN 'Ultra'
        ELSE 'Standard'
    END || ' ' || generate_series,
    'High-quality product with excellent features and performance. ' ||
    'Perfect for professionals and enthusiasts. ' ||
    'Includes warranty and customer support.',
    CASE (random() * 5)::int
        WHEN 0 THEN 'Electronics'
        WHEN 1 THEN 'Computers'
        WHEN 2 THEN 'Accessories'
        WHEN 3 THEN 'Audio'
        ELSE 'Peripherals'
    END,
    (random() * 2000 + 10)::NUMERIC(10, 2),
    (random() * 500)::INTEGER,
    jsonb_build_object(
        'brand', CASE (random() * 4)::int WHEN 0 THEN 'TechCorp' WHEN 1 THEN 'InnovateTech' WHEN 2 THEN 'SmartDevices' ELSE 'ProGear' END,
        'color', CASE (random() * 4)::int WHEN 0 THEN 'Black' WHEN 1 THEN 'White' WHEN 2 THEN 'Silver' ELSE 'Blue' END,
        'weight', (random() * 5 + 0.1)::NUMERIC(5, 2) || ' kg',
        'warranty', CASE (random() * 3)::int WHEN 0 THEN '1 year' WHEN 1 THEN '2 years' ELSE '3 years' END,
        'featured', random() > 0.7
    )
FROM generate_series(1, 300);

-- Generate 1000 orders
DO $$
DECLARE
    v_user_id UUID;
    v_order_id UUID;
    v_product_id UUID;
    v_product_price NUMERIC(10, 2);
    v_quantity INTEGER;
    v_order_total NUMERIC(10, 2);
    v_num_items INTEGER;
    i INTEGER;
BEGIN
    FOR i IN 1..1000 LOOP
        -- Select random user
        SELECT user_id INTO v_user_id
        FROM users
        ORDER BY random()
        LIMIT 1;

        -- Create order
        INSERT INTO orders (
            user_id,
            order_number,
            status,
            total_amount,
            shipping_address,
            created_at
        ) VALUES (
            v_user_id,
            'ORD-' || TO_CHAR(CURRENT_TIMESTAMP - (random() * interval '180 days'), 'YYYYMMDD-') ||
            LPAD(i::TEXT, 6, '0'),
            CASE (random() * 10)::int
                WHEN 0 THEN 'pending'::order_status
                WHEN 1 THEN 'processing'::order_status
                WHEN 2 THEN 'shipped'::order_status
                WHEN 3 THEN 'delivered'::order_status
                WHEN 4 THEN 'delivered'::order_status
                WHEN 5 THEN 'delivered'::order_status
                WHEN 6 THEN 'delivered'::order_status
                WHEN 7 THEN 'delivered'::order_status
                WHEN 8 THEN 'delivered'::order_status
                ELSE 'cancelled'::order_status
            END,
            0,
            jsonb_build_object(
                'street', (100 + i) || ' Main Street',
                'city', CASE (random() * 5)::int WHEN 0 THEN 'Seoul' WHEN 1 THEN 'Busan' WHEN 2 THEN 'Incheon' WHEN 3 THEN 'Daegu' ELSE 'Gwangju' END,
                'state', 'Seoul',
                'postal_code', LPAD((random() * 99999)::INTEGER::TEXT, 5, '0'),
                'country', 'South Korea'
            ),
            CURRENT_TIMESTAMP - (random() * interval '180 days')
        ) RETURNING order_id INTO v_order_id;

        -- Add 1-5 items to order
        v_num_items := (random() * 4 + 1)::INTEGER;
        v_order_total := 0;

        FOR j IN 1..v_num_items LOOP
            -- Select random product
            SELECT product_id, price INTO v_product_id, v_product_price
            FROM products
            WHERE stock_quantity > 0
            ORDER BY random()
            LIMIT 1;

            v_quantity := (random() * 3 + 1)::INTEGER;

            -- Insert order item (trigger will update stock)
            BEGIN
                INSERT INTO order_items (order_id, product_id, quantity, unit_price)
                VALUES (v_order_id, v_product_id, v_quantity, v_product_price);

                v_order_total := v_order_total + (v_product_price * v_quantity);
            EXCEPTION
                WHEN OTHERS THEN
                    -- Skip if stock insufficient
                    CONTINUE;
            END;
        END LOOP;

        -- Update order total
        UPDATE orders SET total_amount = v_order_total WHERE order_id = v_order_id;
    END LOOP;
END $$;

-- Generate 2000 reviews
DO $$
DECLARE
    v_user_id UUID;
    v_product_id UUID;
    i INTEGER;
BEGIN
    FOR i IN 1..2000 LOOP
        -- Select random user
        SELECT user_id INTO v_user_id
        FROM users
        ORDER BY random()
        LIMIT 1;

        -- Select random product
        SELECT product_id INTO v_product_id
        FROM products
        ORDER BY random()
        LIMIT 1;

        -- Insert review (skip if duplicate)
        BEGIN
            INSERT INTO reviews (product_id, user_id, rating, title, comment, helpful_count, created_at)
            VALUES (
                v_product_id,
                v_user_id,
                (random() * 4 + 1)::INTEGER,
                CASE (random() * 5)::int
                    WHEN 0 THEN 'Great product!'
                    WHEN 1 THEN 'Highly recommend'
                    WHEN 2 THEN 'Good value for money'
                    WHEN 3 THEN 'Excellent quality'
                    ELSE 'Worth buying'
                END,
                CASE (random() * 5)::int
                    WHEN 0 THEN 'This product exceeded my expectations. The quality is outstanding and it works perfectly.'
                    WHEN 1 THEN 'Very satisfied with this purchase. Fast delivery and great customer service.'
                    WHEN 2 THEN 'Good product overall. Some minor issues but nothing major. Would buy again.'
                    WHEN 3 THEN 'Excellent value for the price. Highly recommended for anyone looking for quality.'
                    ELSE 'Amazing product! Love everything about it. Five stars!'
                END,
                (random() * 50)::INTEGER,
                CURRENT_TIMESTAMP - (random() * interval '365 days')
            );
        EXCEPTION
            WHEN unique_violation THEN
                -- Skip duplicate reviews
                CONTINUE;
        END;
    END LOOP;
END $$;

-- Update statistics
ANALYZE users;
ANALYZE products;
ANALYZE orders;
ANALYZE order_items;
ANALYZE reviews;
ANALYZE audit_log;

-- Display summary
DO $$
BEGIN
    RAISE NOTICE 'Sample data loaded successfully!';
    RAISE NOTICE 'Users: %', (SELECT COUNT(*) FROM users);
    RAISE NOTICE 'Products: %', (SELECT COUNT(*) FROM products);
    RAISE NOTICE 'Orders: %', (SELECT COUNT(*) FROM orders);
    RAISE NOTICE 'Order Items: %', (SELECT COUNT(*) FROM order_items);
    RAISE NOTICE 'Reviews: %', (SELECT COUNT(*) FROM reviews);
    RAISE NOTICE 'Audit Logs: %', (SELECT COUNT(*) FROM audit_log);
END $$;
