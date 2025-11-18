#!/bin/bash
# PostgreSQL Backup Script
# Demonstrates different backup strategies

set -e

DB_NAME="education_db"
DB_USER="postgres"
DB_HOST="localhost"
DB_PORT="5432"
BACKUP_DIR="./backups"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# Create backup directory
mkdir -p "$BACKUP_DIR"

echo "=== PostgreSQL Backup Script ==="
echo "Timestamp: $TIMESTAMP"
echo

# 1. Full database dump (SQL format)
echo "1. Creating full SQL dump..."
docker exec postgres-advanced pg_dump \
    -U $DB_USER \
    -d $DB_NAME \
    -F p \
    -f /tmp/backup_${TIMESTAMP}.sql

docker cp postgres-advanced:/tmp/backup_${TIMESTAMP}.sql \
    "$BACKUP_DIR/full_backup_${TIMESTAMP}.sql"

echo "   ✓ SQL dump saved: $BACKUP_DIR/full_backup_${TIMESTAMP}.sql"
echo

# 2. Compressed dump (custom format)
echo "2. Creating compressed custom format dump..."
docker exec postgres-advanced pg_dump \
    -U $DB_USER \
    -d $DB_NAME \
    -F c \
    -f /tmp/backup_${TIMESTAMP}.dump

docker cp postgres-advanced:/tmp/backup_${TIMESTAMP}.dump \
    "$BACKUP_DIR/compressed_backup_${TIMESTAMP}.dump"

echo "   ✓ Compressed dump saved: $BACKUP_DIR/compressed_backup_${TIMESTAMP}.dump"
echo

# 3. Directory format (parallel dump)
echo "3. Creating directory format dump (for parallel restore)..."
docker exec postgres-advanced pg_dump \
    -U $DB_USER \
    -d $DB_NAME \
    -F d \
    -j 4 \
    -f /tmp/backup_${TIMESTAMP}_dir

docker cp postgres-advanced:/tmp/backup_${TIMESTAMP}_dir \
    "$BACKUP_DIR/dir_backup_${TIMESTAMP}"

echo "   ✓ Directory dump saved: $BACKUP_DIR/dir_backup_${TIMESTAMP}"
echo

# 4. Schema-only backup
echo "4. Creating schema-only backup..."
docker exec postgres-advanced pg_dump \
    -U $DB_USER \
    -d $DB_NAME \
    -s \
    -F p \
    -f /tmp/schema_${TIMESTAMP}.sql

docker cp postgres-advanced:/tmp/schema_${TIMESTAMP}.sql \
    "$BACKUP_DIR/schema_only_${TIMESTAMP}.sql"

echo "   ✓ Schema-only dump saved: $BACKUP_DIR/schema_only_${TIMESTAMP}.sql"
echo

# 5. Data-only backup
echo "5. Creating data-only backup..."
docker exec postgres-advanced pg_dump \
    -U $DB_USER \
    -d $DB_NAME \
    -a \
    -F p \
    -f /tmp/data_${TIMESTAMP}.sql

docker cp postgres-advanced:/tmp/data_${TIMESTAMP}.sql \
    "$BACKUP_DIR/data_only_${TIMESTAMP}.sql"

echo "   ✓ Data-only dump saved: $BACKUP_DIR/data_only_${TIMESTAMP}.sql"
echo

# 6. Specific table backup
echo "6. Creating backup of specific tables..."
docker exec postgres-advanced pg_dump \
    -U $DB_USER \
    -d $DB_NAME \
    -t users \
    -t products \
    -F p \
    -f /tmp/tables_${TIMESTAMP}.sql

docker cp postgres-advanced:/tmp/tables_${TIMESTAMP}.sql \
    "$BACKUP_DIR/specific_tables_${TIMESTAMP}.sql"

echo "   ✓ Specific tables dump saved: $BACKUP_DIR/specific_tables_${TIMESTAMP}.sql"
echo

# 7. Backup database roles and globals
echo "7. Backing up roles and global objects..."
docker exec postgres-advanced pg_dumpall \
    -U $DB_USER \
    -g \
    -f /tmp/globals_${TIMESTAMP}.sql

docker cp postgres-advanced:/tmp/globals_${TIMESTAMP}.sql \
    "$BACKUP_DIR/globals_${TIMESTAMP}.sql"

echo "   ✓ Globals dump saved: $BACKUP_DIR/globals_${TIMESTAMP}.sql"
echo

# Display backup sizes
echo "=== Backup Summary ==="
du -sh "$BACKUP_DIR"/*${TIMESTAMP}* | sort -h

echo
echo "All backups completed successfully!"
echo "Backup location: $BACKUP_DIR"
