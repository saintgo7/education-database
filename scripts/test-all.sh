#!/bin/bash

# Test script for all modules
# 모든 모듈의 예제 실행 및 테스트

set -e

echo "🧪 Testing all modules..."
echo "=================================================="

# Color codes
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

PASSED=0
FAILED=0

# Test function
run_test() {
    local module=$1
    local command=$2
    local description=$3

    echo ""
    echo -e "${BLUE}📝 Testing: $description${NC}"

    if eval "$command" > /tmp/test_output.log 2>&1; then
        echo -e "${GREEN}✓ PASSED${NC}"
        ((PASSED++))
    else
        echo -e "${RED}✗ FAILED${NC}"
        echo "Error output:"
        tail -20 /tmp/test_output.log
        ((FAILED++))
    fi
}

# PostgreSQL tests
echo -e "${BLUE}=== PostgreSQL Tests ===${NC}"

run_test "PostgreSQL" \
    "PGPASSWORD=postgres psql -U postgres -h localhost -d education_db -c 'SELECT COUNT(*) FROM users;'" \
    "PostgreSQL connection test"

run_test "PostgreSQL" \
    "PGPASSWORD=postgres psql -U postgres -h localhost -d education_db -c 'SELECT * FROM users LIMIT 1;'" \
    "PostgreSQL basic query test"

# MongoDB tests
echo -e "${BLUE}=== MongoDB Tests ===${NC}"

run_test "MongoDB" \
    "mongosh --host localhost:27017 --eval 'db.adminCommand(\"ping\")'" \
    "MongoDB connection test"

run_test "MongoDB" \
    "mongosh --host localhost:27017 education_db --eval 'db.users.findOne()'" \
    "MongoDB basic query test"

# Redis tests
echo -e "${BLUE}=== Redis Tests ===${NC}"

run_test "Redis" \
    "redis-cli ping | grep -q PONG" \
    "Redis connection test"

run_test "Redis" \
    "redis-cli GET sample_key | grep -q sample_value" \
    "Redis basic query test"

# Elasticsearch tests
echo -e "${BLUE}=== Elasticsearch Tests ===${NC}"

run_test "Elasticsearch" \
    "curl -s http://localhost:9200/_cluster/health | grep -q green" \
    "Elasticsearch cluster health check"

run_test "Elasticsearch" \
    "curl -s http://localhost:9200/products/_search | grep -q products" \
    "Elasticsearch basic query test"

# Node.js modules tests
echo -e "${BLUE}=== Node.js Modules Tests ===${NC}"

if [ -d "mongodb-patterns/scripts" ]; then
    run_test "MongoDB" \
        "cd mongodb-patterns/scripts && npm list mongodb > /dev/null 2>&1" \
        "MongoDB patterns dependencies"
fi

if [ -d "redis-caching/scripts" ]; then
    run_test "Redis" \
        "cd redis-caching/scripts && npm list redis > /dev/null 2>&1" \
        "Redis caching dependencies"
fi

if [ -d "orm-comparison/scripts" ]; then
    run_test "ORM" \
        "cd orm-comparison/scripts && npm list sequelize > /dev/null 2>&1" \
        "ORM comparison dependencies"
fi

# Docker containers check
echo -e "${BLUE}=== Docker Containers Status ===${NC}"

CONTAINERS=("postgres" "mongodb" "redis" "elasticsearch")

for container in "${CONTAINERS[@]}"; do
    run_test "Docker" \
        "docker-compose ps | grep -q $container" \
        "Docker container $container is running"
done

# Summary
echo ""
echo "=================================================="
echo -e "${GREEN}Test Summary:${NC}"
echo "  ✓ Passed: $PASSED"
echo "  ✗ Failed: $FAILED"

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}=================================================="
    echo "🎉 All tests passed!${NC}"
    echo "=================================================="
    exit 0
else
    echo -e "${RED}=================================================="
    echo "⚠️  Some tests failed. Please check the logs above.${NC}"
    echo "==================================================${NC}"
    exit 1
fi
