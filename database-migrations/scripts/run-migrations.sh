#!/bin/bash

# Database Migrations Script

set -e

echo "Running database migrations..."

# Create migration directories if they don't exist
mkdir -p migrations/postgres
mkdir -p migrations/mysql

# PostgreSQL migrations
echo "▶ PostgreSQL migrations..."
PGPASSWORD=password123 psql -h localhost -p 5434 -U admin -d migrations_db -f migrations/postgres/V001__initial_schema.sql
echo "  ✓ PostgreSQL migrations complete"

# MySQL migrations
echo "▶ MySQL migrations..."
mysql -h localhost -P 3307 -u admin -ppassword123 migrations_db < migrations/mysql/V001__initial_schema.sql
echo "  ✓ MySQL migrations complete"

echo "✅ All migrations complete!"
