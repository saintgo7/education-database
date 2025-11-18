#!/bin/bash

# Installation script for all modules
# 모든 모듈의 의존성 설치

set -e

echo "🚀 Starting installation of all modules..."
echo "=================================================="

# Color codes
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# MongoDB Patterns
echo -e "${BLUE}📦 Installing MongoDB Patterns...${NC}"
cd mongodb-patterns/scripts
npm install
cd ../../

# Redis Caching
echo -e "${BLUE}📦 Installing Redis Caching...${NC}"
cd redis-caching/scripts
npm install
cd ../../

# Elasticsearch Search
echo -e "${BLUE}📦 Elasticsearch setup (no npm required)${NC}"

# ORM Comparison
echo -e "${BLUE}📦 Installing ORM Comparison...${NC}"
cd orm-comparison/scripts
npm install
cd ../../

# Database Testing
echo -e "${BLUE}📦 Installing Database Testing...${NC}"
cd database-testing/scripts
npm install
cd ../../

echo ""
echo -e "${GREEN}✅ Installation complete!${NC}"
echo ""
echo "Next steps:"
echo "1. Start Docker containers: docker-compose up -d"
echo "2. Initialize databases: bash scripts/init-databases.sh"
echo "3. Run examples: See GETTING_STARTED_KO.md"
echo ""
echo "=================================================="
