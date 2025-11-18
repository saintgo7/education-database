# Database Education Repository

A comprehensive collection of database examples, patterns, and best practices for learning various database technologies.

## 📚 Contents

1. **[postgresql-advanced](./postgresql-advanced)** - Advanced PostgreSQL features
   - Indexes (B-tree, Hash, GiST, GIN)
   - Triggers and stored procedures
   - Query optimization
   - Performance tuning

2. **[mongodb-patterns](./mongodb-patterns)** - MongoDB design patterns
   - Schema design strategies
   - Aggregation pipelines
   - Indexing strategies
   - Data modeling

3. **[redis-caching](./redis-caching)** - Redis caching strategies
   - Cache patterns (Cache-aside, Write-through)
   - Pub/Sub messaging
   - Data structures
   - Performance optimization

4. **[elasticsearch-search](./elasticsearch-search)** - Elasticsearch search and analytics
   - Full-text search
   - Aggregations and analytics
   - Index management
   - Query DSL

5. **[cassandra-nosql](./cassandra-nosql)** - Cassandra wide-column store
   - Data modeling
   - Partition strategies
   - Query patterns
   - Consistency levels

6. **[neo4j-graph](./neo4j-graph)** - Neo4j graph database
   - Graph modeling
   - Cypher queries
   - Relationship patterns
   - Graph algorithms

7. **[timescaledb-timeseries](./timescaledb-timeseries)** - TimescaleDB time-series
   - Hypertables
   - Continuous aggregates
   - Time-series queries
   - Data retention

8. **[database-migrations](./database-migrations)** - Database migration tools
   - Flyway examples
   - Liquibase examples
   - Version control strategies
   - Rollback patterns

9. **[orm-comparison](./orm-comparison)** - ORM frameworks comparison
   - Sequelize (Node.js)
   - TypeORM (TypeScript)
   - Prisma (Modern ORM)
   - Performance comparison

10. **[database-testing](./database-testing)** - Database testing strategies
    - Test data generation
    - Fixtures and factories
    - Integration testing
    - Performance testing

## 🚀 Quick Start

Each directory contains:
- `docker-compose.yml` - Ready-to-run Docker setup
- `data/` - Sample data (1000+ records)
- `queries/` - Optimized query examples
- `scripts/` - Backup, restore, and utility scripts
- `benchmarks/` - Performance benchmarks
- `config/` - Connection pooling configurations
- `README.md` - English documentation
- `README.ko.md` - Korean documentation (한국어 설명)
- `schema.md` - Visual schema diagrams

## 🐳 Prerequisites

- Docker & Docker Compose
- Node.js 18+ (for ORM examples)
- Python 3.9+ (for data generation)
- Basic SQL/NoSQL knowledge

## 📖 Usage

1. Navigate to any module directory:
   ```bash
   cd postgresql-advanced
   ```

2. Start the database:
   ```bash
   docker-compose up -d
   ```

3. Load sample data:
   ```bash
   ./scripts/load-data.sh
   ```

4. Run examples:
   ```bash
   ./scripts/run-examples.sh
   ```

## 🎯 Learning Path

### Beginners
1. Start with `postgresql-advanced` for SQL fundamentals
2. Move to `mongodb-patterns` for NoSQL concepts
3. Learn `redis-caching` for caching strategies

### Intermediate
1. Explore `elasticsearch-search` for search engines
2. Study `database-migrations` for version control
3. Compare `orm-comparison` frameworks

### Advanced
1. Master `cassandra-nosql` for distributed systems
2. Learn `neo4j-graph` for graph algorithms
3. Optimize with `timescaledb-timeseries` for IoT/metrics

## 📊 Performance Benchmarks

Each module includes benchmarks comparing:
- Read/Write performance
- Query optimization results
- Connection pooling impact
- Index effectiveness

## 🌐 Korean Documentation

All modules include Korean documentation (`README.ko.md`) with:
- 개념 설명 (Concept explanations)
- 쿼리 예제 해설 (Query examples with explanations)
- 최적화 팁 (Optimization tips)
- 실무 활용 사례 (Real-world use cases)

## 🤝 Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](./CONTRIBUTING.md) for guidelines.

## 📝 License

MIT License - see [LICENSE](./LICENSE) for details.

## 📚 Resources

- [Database Design Best Practices](./docs/best-practices.md)
- [Performance Tuning Guide](./docs/performance-tuning.md)
- [Security Checklist](./docs/security.md)
- [Troubleshooting Guide](./docs/troubleshooting.md)
