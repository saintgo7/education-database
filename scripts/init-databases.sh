#!/bin/bash

# Database initialization script
# 모든 데이터베이스 초기화 및 기본 데이터 로드

set -e

echo "🔧 Initializing all databases..."
echo "=================================================="

# Color codes
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# PostgreSQL initialization
echo -e "${BLUE}📊 Initializing PostgreSQL...${NC}"

# Wait for PostgreSQL to be ready
echo "Waiting for PostgreSQL..."
sleep 5

# Create education_db
PGPASSWORD=postgres psql -U postgres -h localhost -tc "SELECT 1 FROM pg_database WHERE datname = 'education_db'" | grep -q 1 || PGPASSWORD=postgres psql -U postgres -h localhost -c "CREATE DATABASE education_db;"

# Create timescale_db
PGPASSWORD=postgres psql -U postgres -h localhost -tc "SELECT 1 FROM pg_database WHERE datname = 'timescale_db'" | grep -q 1 || PGPASSWORD=postgres psql -U postgres -h localhost -c "CREATE DATABASE timescale_db;"

# Initialize PostgreSQL basic schema
PGPASSWORD=postgres psql -U postgres -h localhost -d education_db << EOF
-- Basic tables
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    name VARCHAR(100),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    category VARCHAR(100),
    price DECIMAL(10,2),
    status VARCHAR(50) DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS orders (
    id BIGSERIAL PRIMARY KEY,
    user_id INT REFERENCES users(id),
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    amount DECIMAL(10,2),
    status VARCHAR(50) DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_products_category ON products(category);
CREATE INDEX IF NOT EXISTS idx_orders_user_id ON orders(user_id);

-- Sample data
INSERT INTO users (email, name) VALUES
    ('user1@example.com', 'User One'),
    ('user2@example.com', 'User Two'),
    ('user3@example.com', 'User Three')
ON CONFLICT DO NOTHING;

INSERT INTO products (name, category, price) VALUES
    ('Laptop', 'Electronics', 999.99),
    ('Mouse', 'Electronics', 29.99),
    ('Keyboard', 'Electronics', 79.99),
    ('Monitor', 'Electronics', 299.99)
ON CONFLICT DO NOTHING;

INSERT INTO orders (user_id, amount, status) VALUES
    (1, 999.99, 'completed'),
    (1, 29.99, 'completed'),
    (2, 79.99, 'pending'),
    (3, 299.99, 'shipped')
ON CONFLICT DO NOTHING;
EOF

echo -e "${GREEN}✓ PostgreSQL initialized${NC}"

# MongoDB initialization
echo -e "${BLUE}🍃 Initializing MongoDB...${NC}"

sleep 5

# Initialize MongoDB collections and sample data
mongosh --host localhost:27017 << EOF
use education_db

// Create collections
db.createCollection('users')
db.createCollection('orders')
db.createCollection('products')

// Create indexes
db.users.createIndex({email: 1})
db.orders.createIndex({userId: 1})
db.products.createIndex({category: 1})

// Sample data
db.users.insertMany([
    {_id: 1, email: 'user1@example.com', name: 'User One', isActive: true},
    {_id: 2, email: 'user2@example.com', name: 'User Two', isActive: true},
    {_id: 3, email: 'user3@example.com', name: 'User Three', isActive: false}
], {ordered: false})

db.products.insertMany([
    {_id: 1, name: 'Laptop', category: 'Electronics', price: 999.99},
    {_id: 2, name: 'Mouse', category: 'Electronics', price: 29.99},
    {_id: 3, name: 'Keyboard', category: 'Electronics', price: 79.99},
    {_id: 4, name: 'Monitor', category: 'Electronics', price: 299.99}
], {ordered: false})

db.orders.insertMany([
    {_id: 1, userId: 1, amount: 999.99, status: 'completed'},
    {_id: 2, userId: 1, amount: 29.99, status: 'completed'},
    {_id: 3, userId: 2, amount: 79.99, status: 'pending'},
    {_id: 4, userId: 3, amount: 299.99, status: 'shipped'}
], {ordered: false})
EOF

echo -e "${GREEN}✓ MongoDB initialized${NC}"

# Redis initialization
echo -e "${BLUE}🔴 Initializing Redis...${NC}"

sleep 5

redis-cli FLUSHDB
redis-cli SET sample_key sample_value
redis-cli SET user:1:email user1@example.com
redis-cli HSET user:1:profile name "User One" age 30 city "Seoul"
redis-cli SADD tags:1 python database redis
redis-cli ZADD leaderboard 100 user1 85 user2 92 user3

echo -e "${GREEN}✓ Redis initialized${NC}"

# Elasticsearch initialization
echo -e "${BLUE}🔍 Initializing Elasticsearch...${NC}"

sleep 5

# Create indexes
curl -s -X PUT "localhost:9200/products" -H 'Content-Type: application/json' -d'{
  "settings": {"number_of_shards": 1, "number_of_replicas": 0},
  "mappings": {"properties": {
    "id": {"type": "integer"},
    "name": {"type": "text"},
    "category": {"type": "keyword"},
    "price": {"type": "float"}
  }}
}'

curl -s -X PUT "localhost:9200/users" -H 'Content-Type: application/json' -d'{
  "settings": {"number_of_shards": 1, "number_of_replicas": 0},
  "mappings": {"properties": {
    "id": {"type": "integer"},
    "email": {"type": "keyword"},
    "name": {"type": "text"}
  }}
}'

# Sample data
curl -s -X POST "localhost:9200/products/_bulk" -H 'Content-Type: application/json' -d'
{"index":{"_id":"1"}}
{"id":1,"name":"Laptop","category":"Electronics","price":999.99}
{"index":{"_id":"2"}}
{"id":2,"name":"Mouse","category":"Electronics","price":29.99}
{"index":{"_id":"3"}}
{"id":3,"name":"Keyboard","category":"Electronics","price":79.99}
{"index":{"_id":"4"}}
{"id":4,"name":"Monitor","category":"Electronics","price":299.99}
'

echo -e "${GREEN}✓ Elasticsearch initialized${NC}"

# TimescaleDB initialization
echo -e "${BLUE}⏱️  Initializing TimescaleDB...${NC}"

PGPASSWORD=postgres psql -U postgres -h localhost -d timescale_db << EOF
-- Enable TimescaleDB extension
CREATE EXTENSION IF NOT EXISTS timescaledb;

-- Create hypertable
CREATE TABLE IF NOT EXISTS metrics (
    time TIMESTAMP NOT NULL,
    sensor_id INT,
    metric_type TEXT,
    value FLOAT,
    PRIMARY KEY (time, sensor_id)
);

SELECT create_hypertable('metrics', 'time', if_not_exists => TRUE);

-- Sample data
INSERT INTO metrics (time, sensor_id, metric_type, value) VALUES
    (NOW() - INTERVAL '1 hour', 1, 'temperature', 22.5),
    (NOW() - INTERVAL '50 minutes', 1, 'temperature', 22.7),
    (NOW() - INTERVAL '40 minutes', 2, 'temperature', 21.9),
    (NOW() - INTERVAL '30 minutes', 1, 'humidity', 65.0)
ON CONFLICT DO NOTHING;
EOF

echo -e "${GREEN}✓ TimescaleDB initialized${NC}"

echo ""
echo -e "${GREEN}=================================================="
echo "✅ All databases initialized successfully!"
echo "==================================================${NC}"
echo ""
echo "Your system is ready! 🚀"
echo ""
echo "Quick start commands:"
echo "  PostgreSQL:   psql -U postgres -h localhost -d education_db"
echo "  MongoDB:      mongosh --host localhost:27017"
echo "  Redis:        redis-cli"
echo "  Elasticsearch: curl http://localhost:9200"
echo ""
echo "See GETTING_STARTED_KO.md for detailed examples"
echo ""
