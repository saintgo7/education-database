# Cassandra NoSQL Module

## Overview
Complete educational guide for Apache Cassandra, covering distributed NoSQL design, partitioning strategies, and scalability patterns.

## What You'll Learn
- Distributed database architecture (peer-to-peer)
- Partition key and clustering key design
- Consistency levels and replication strategies
- CQL (Cassandra Query Language)
- Secondary indexes and materialized views
- Compaction strategies
- Sharding and scaling across nodes

## Key Concepts

### 1. **Data Modeling**
- Partition key selection
- Clustering keys for ordering
- Wide rows and denormalization
- Query-driven design

### 2. **Distributed Architecture**
- Peer-to-peer topology
- Token ring and token-aware routing
- Replication factors
- Consistency levels (ONE, QUORUM, ALL)

### 3. **Advanced Features**
- Secondary indexes
- Materialized views
- Lightweight transactions
- User-defined types

### 4. **Performance**
- Read/write paths
- Bloom filters and SSTables
- Compaction strategies
- Tuning replication

### 5. **Scaling**
- Adding nodes to cluster
- Data redistribution
- Rack-awareness
- Multi-datacenter setup

## Quick Start

```bash
# Start Cassandra cluster
docker-compose up -d

# Wait for Cassandra to be ready
sleep 30

# Access CQL shell
docker exec -it cassandra-nosql cqlsh

# Run initialization
bash scripts/init/01-init.sh
```

## Directory Structure

```
cassandra-nosql/
├── docker-compose.yml
├── config/
│   └── cassandra.yaml
├── scripts/
│   └── init/
│       └── 01-init.cql
└── queries/
    ├── 01-data-modeling.cql
    └── 02-advanced-queries.cql
```

## Sample Data

- Keyspace: `education`
- Tables: users, products, orders, reviews
- Replication factor: 3
- Consistency: ONE for reads, LOCAL_QUORUM for writes

## Accessing Services

- **Cassandra**: localhost:9042
- **Cassandra Web UI**: http://localhost:3000

---

**Status**: ✅ Complete
