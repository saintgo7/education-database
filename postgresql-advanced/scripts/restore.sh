#!/bin/bash
# PostgreSQL Restore Script
# Demonstrates different restore strategies

set -e

DB_NAME="education_db"
DB_USER="postgres"
DB_HOST="localhost"
DB_PORT="5432"
BACKUP_DIR="./backups"

echo "=== PostgreSQL Restore Script ==="
echo

# Check if backup file is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <backup_file>"
    echo
    echo "Available backups:"
    ls -lh "$BACKUP_DIR"
    exit 1
fi

BACKUP_FILE="$1"

# Check if backup file exists
if [ ! -e "$BACKUP_FILE" ]; then
    echo "Error: Backup file not found: $BACKUP_FILE"
    exit 1
fi

echo "Backup file: $BACKUP_FILE"
echo

# Detect backup format
if [[ "$BACKUP_FILE" == *.sql ]]; then
    FORMAT="sql"
elif [[ "$BACKUP_FILE" == *.dump ]]; then
    FORMAT="custom"
elif [ -d "$BACKUP_FILE" ]; then
    FORMAT="directory"
else
    echo "Error: Unknown backup format"
    exit 1
fi

echo "Detected format: $FORMAT"
echo

# Confirm restoration
read -p "This will DROP and recreate the database. Continue? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Restore cancelled."
    exit 1
fi

# Drop and recreate database
echo "Dropping existing database..."
docker exec postgres-advanced psql -U $DB_USER -c "DROP DATABASE IF EXISTS $DB_NAME;"
docker exec postgres-advanced psql -U $DB_USER -c "CREATE DATABASE $DB_NAME;"
echo "   ✓ Database recreated"
echo

# Restore based on format
if [ "$FORMAT" == "sql" ]; then
    echo "Restoring from SQL dump..."
    docker cp "$BACKUP_FILE" postgres-advanced:/tmp/restore.sql
    docker exec postgres-advanced psql -U $DB_USER -d $DB_NAME -f /tmp/restore.sql
    echo "   ✓ SQL restore completed"

elif [ "$FORMAT" == "custom" ]; then
    echo "Restoring from custom format dump..."
    docker cp "$BACKUP_FILE" postgres-advanced:/tmp/restore.dump
    docker exec postgres-advanced pg_restore \
        -U $DB_USER \
        -d $DB_NAME \
        -F c \
        -j 4 \
        --verbose \
        /tmp/restore.dump
    echo "   ✓ Custom format restore completed"

elif [ "$FORMAT" == "directory" ]; then
    echo "Restoring from directory format dump..."
    docker cp "$BACKUP_FILE" postgres-advanced:/tmp/restore_dir
    docker exec postgres-advanced pg_restore \
        -U $DB_USER \
        -d $DB_NAME \
        -F d \
        -j 4 \
        --verbose \
        /tmp/restore_dir
    echo "   ✓ Directory format restore completed"
fi

echo
echo "Analyzing tables..."
docker exec postgres-advanced psql -U $DB_USER -d $DB_NAME -c "ANALYZE;"
echo "   ✓ Analysis completed"

echo
echo "=== Restore Summary ==="
docker exec postgres-advanced psql -U $DB_USER -d $DB_NAME -c "
    SELECT schemaname, tablename, pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS size
    FROM pg_tables
    WHERE schemaname = 'public'
    ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;
"

echo
echo "Database restored successfully!"
