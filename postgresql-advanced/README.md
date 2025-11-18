## PostgreSQL Advanced

Advanced PostgreSQL features including indexes, triggers, stored procedures, and query optimization.

### Features

- **Multiple Index Types**: B-tree, GIN, GiST, Hash, Partial, Expression
- **Triggers**: Automated timestamp updates, audit logging, stock validation
- **Stored Procedures**: Order creation, statistics updates, search functions
- **Query Optimization**: 50+ optimized query examples
- **Performance Benchmarks**: Index comparisons, JOIN tests, aggregation tests
- **1000+ Sample Records**: Users, products, orders, reviews

### Quick Start

1. **Start the database**:
   ```bash
   docker-compose up -d
   ```

2. **Verify it's running**:
   ```bash
   docker ps
   ```

3. **Access PostgreSQL**:
   ```bash
   docker exec -it postgres-advanced psql -U postgres -d education_db
   ```

4. **Access pgAdmin**: http://localhost:5050
   - Email: admin@admin.com
   - Password: admin

### Database Schema

```
users (500 records)
├── user_id (UUID, PK)
├── username (unique)
├── email (indexed)
├── status (enum: active/inactive/suspended)
└── preferences (JSONB)

products (300 records)
├── product_id (UUID, PK)
├── sku (unique)
├── name (full-text indexed)
├── category (indexed)
├── price (indexed)
└── attributes (JSONB with GIN index)

orders (1000 records)
├── order_id (UUID, PK)
├── user_id (FK to users)
├── status (enum)
├── total_amount
└── shipping_address (JSONB)

order_items
├── order_item_id (UUID, PK)
├── order_id (FK to orders)
├── product_id (FK to products)
└── subtotal (computed column)

reviews (2000 records)
├── review_id (UUID, PK)
├── product_id (FK to products)
├── user_id (FK to users)
└── rating (1-5)
```

### Index Types Demonstrated

1. **B-tree** (default): `idx_users_email`, `idx_products_price`
2. **GIN** (JSONB): `idx_users_preferences`, `idx_products_attributes`
3. **GIN Trigram** (full-text): `idx_products_name_trgm`
4. **Composite**: `idx_orders_user_status`
5. **Partial**: `idx_orders_pending` (WHERE status = 'pending')
6. **Expression**: `idx_users_lower_username`

### Triggers

- **Updated At**: Auto-updates `updated_at` on all tables
- **Audit Log**: Tracks all INSERT/UPDATE/DELETE operations
- **Stock Validation**: Prevents orders when stock insufficient
- **Order Timestamps**: Auto-sets `shipped_at` and `delivered_at`

### Stored Procedures

```sql
-- Create order with items
CALL create_order(
    user_id UUID,
    items JSONB,
    shipping_address JSONB,
    OUT order_id UUID
);

-- Update product statistics
CALL update_product_statistics();

-- Get user order history
SELECT * FROM get_user_order_history(user_id UUID);

-- Search products
SELECT * FROM search_products(
    search_term TEXT,
    category VARCHAR,
    min_price NUMERIC,
    max_price NUMERIC
);
```

### Query Examples

#### 1. Window Functions
```sql
-- Rank products by price within category
SELECT
    name,
    category,
    price,
    RANK() OVER (PARTITION BY category ORDER BY price DESC) as rank
FROM products;
```

#### 2. CTEs (Common Table Expressions)
```sql
WITH top_customers AS (
    SELECT user_id, SUM(total_amount) as total_spent
    FROM orders
    GROUP BY user_id
    ORDER BY total_spent DESC
    LIMIT 10
)
SELECT u.username, tc.total_spent
FROM users u
JOIN top_customers tc ON u.user_id = tc.user_id;
```

#### 3. JSONB Queries
```sql
-- Find users with dark theme
SELECT username
FROM users
WHERE preferences @> '{"theme": "dark"}';

-- Extract JSON fields
SELECT
    username,
    preferences->>'language' as language
FROM users;
```

#### 4. Full-Text Search
```sql
-- Search products with ranking
SELECT name, price,
    ts_rank(
        to_tsvector('english', name),
        to_tsquery('english', 'laptop')
    ) as rank
FROM products
WHERE to_tsvector('english', name) @@ to_tsquery('english', 'laptop')
ORDER BY rank DESC;
```

### Performance Tuning

#### Check Index Usage
```sql
SELECT schemaname, tablename, indexname, idx_scan
FROM pg_stat_user_indexes
WHERE schemaname = 'public'
ORDER BY idx_scan DESC;
```

#### Find Slow Queries
```sql
SELECT query, mean_exec_time, calls
FROM pg_stat_statements
ORDER BY mean_exec_time DESC
LIMIT 10;
```

#### Cache Hit Ratio
```sql
SELECT
    sum(heap_blks_hit) / (sum(heap_blks_hit) + sum(heap_blks_read))::float as cache_hit_ratio
FROM pg_statio_user_tables;
```

### Backup & Restore

#### Backup
```bash
# Full backup
./scripts/backup.sh

# Schema only
docker exec postgres-advanced pg_dump -U postgres -d education_db -s > schema.sql

# Specific table
docker exec postgres-advanced pg_dump -U postgres -d education_db -t users > users.sql
```

#### Restore
```bash
# Restore from backup
./scripts/restore.sh backups/full_backup_20250119_120000.sql

# Restore specific table
docker exec -i postgres-advanced psql -U postgres -d education_db < users.sql
```

### Benchmarks

Run performance tests:
```bash
docker exec -it postgres-advanced psql -U postgres -d education_db -f /benchmarks/performance-test.sql
```

Results include:
- Index scan vs Sequential scan comparison
- JOIN performance analysis
- Aggregation speed tests
- JSONB operation benchmarks
- Full-text search performance

### Connection Pooling

PostgreSQL configuration includes:
- `max_connections = 200`
- `shared_buffers = 256MB`
- `effective_cache_size = 1GB`
- `work_mem = 16MB`

For production, consider using **PgBouncer** or **pgpool-II**.

### Best Practices

1. **Always use indexes** for foreign keys and frequently queried columns
2. **Use EXPLAIN ANALYZE** to understand query plans
3. **Regular VACUUM** and ANALYZE for statistics
4. **Monitor pg_stat_statements** for slow queries
5. **Use connection pooling** for high-traffic applications
6. **Partition large tables** (>10M rows)
7. **Use appropriate data types** (UUID vs BIGINT)

### Common Issues

**Issue**: Slow queries
- **Solution**: Check missing indexes, run ANALYZE, increase work_mem

**Issue**: Disk space growing
- **Solution**: Run VACUUM FULL, check for table bloat

**Issue**: Connection limit reached
- **Solution**: Increase max_connections or use connection pooling

### Resources

- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [Query Optimization Guide](./docs/query-optimization.md)
- [Korean Documentation](./README.ko.md)

### File Structure

```
postgresql-advanced/
├── docker-compose.yml          # Docker setup
├── config/
│   └── postgresql.conf         # PostgreSQL configuration
├── scripts/
│   ├── init/                   # Initialization scripts
│   │   ├── 01-schema.sql      # Schema creation
│   │   ├── 02-triggers.sql    # Triggers and procedures
│   │   └── 03-sample-data.sql # Sample data (1000+ records)
│   ├── backup.sh              # Backup script
│   └── restore.sh             # Restore script
├── queries/
│   ├── 01-index-optimization.sql    # Index examples
│   └── 02-advanced-queries.sql      # Advanced SQL
├── benchmarks/
│   └── performance-test.sql   # Performance tests
└── README.md                  # This file
```
