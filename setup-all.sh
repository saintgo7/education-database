#!/bin/bash
# Master setup script for all databases
# Starts all databases and loads sample data

set -e

echo "=== Database Education Repository Setup ==="
echo ""

# Function to check if Docker is running
check_docker() {
    if ! docker info > /dev/null 2>&1; then
        echo "Error: Docker is not running"
        exit 1
    fi
}

# Function to start a database
start_database() {
    local db_dir=$1
    local db_name=$2

    echo "Starting $db_name..."
    cd "$db_dir"
    docker-compose up -d
    cd - > /dev/null
    echo "✓ $db_name started"
}

# Main execution
check_docker

echo "This will start all database containers. Continue? (y/N)"
read -r response
if [[ ! "$response" =~ ^[Yy]$ ]]; then
    echo "Setup cancelled"
    exit 0
fi

echo ""
echo "=== Starting Databases ==="
echo ""

# Start each database
start_database "postgresql-advanced" "PostgreSQL"
start_database "mongodb-patterns" "MongoDB"
start_database "redis-caching" "Redis"
start_database "elasticsearch-search" "Elasticsearch"
start_database "cassandra-nosql" "Cassandra"
start_database "neo4j-graph" "Neo4j"
start_database "timescaledb-timeseries" "TimescaleDB"

echo ""
echo "=== Setup Complete ==="
echo ""
echo "Database Access Information:"
echo ""
echo "PostgreSQL:"
echo "  - Database: postgresql://postgres:postgres@localhost:5432/education_db"
echo "  - pgAdmin: http://localhost:5050 (admin@admin.com / admin)"
echo ""
echo "MongoDB:"
echo "  - Connection: mongodb://admin:admin123@localhost:27017/education_db"
echo "  - Mongo Express: http://localhost:8081 (admin / admin)"
echo ""
echo "Redis:"
echo "  - Connection: redis://localhost:6379"
echo "  - Redis Commander: http://localhost:8082"
echo "  - RedisInsight: http://localhost:8001"
echo ""
echo "Elasticsearch:"
echo "  - HTTP: http://localhost:9200"
echo "  - Kibana: http://localhost:5601"
echo ""
echo "Cassandra:"
echo "  - CQL: localhost:9042"
echo "  - Username: cassandra / Password: cassandra"
echo ""
echo "Neo4j:"
echo "  - Bolt: bolt://localhost:7687"
echo "  - Browser: http://localhost:7474 (neo4j / password)"
echo ""
echo "TimescaleDB:"
echo "  - Database: postgresql://postgres:postgres@localhost:5433/timeseries_db"
echo ""
echo "To stop all databases: ./stop-all.sh"
echo "To load sample data: ./load-all-data.sh"
