# Neo4j Graph Module

## Overview
Complete guide for Neo4j, a leading graph database for modeling relationships and graph algorithms.

## What You'll Learn
- Graph data modeling (nodes, relationships, properties)
- Cypher query language
- Graph algorithms (shortest path, PageRank, centrality)
- Graph patterns and traversals
- Indexes and query optimization
- APOC procedures
- Real-world graph use cases

## Key Concepts

### 1. **Graph Modeling**
- Nodes and relationships
- Properties on both
- Relationship types and directions
- Label-based queries

### 2. **Cypher Language**
- Pattern matching (MATCH)
- CREATE and DELETE operations
- Aggregations and functions
- Optional relationships

### 3. **Graph Algorithms**
- Pathfinding (Dijkstra, A*)
- Community detection
- Centrality measures
- Similarity metrics

### 4. **Performance**
- Index strategies
- Query planning
- Bulk loading
- Cache management

### 5. **Use Cases**
- Social networks
- Recommendation engines
- Knowledge graphs
- Fraud detection

## Quick Start

```bash
# Start Neo4j
docker-compose up -d

# Access Neo4j Browser
# http://localhost:7474

# Login: neo4j / password123

# Create test data
bash scripts/init/01-init.cypher
```

## Directory Structure

```
neo4j-graph/
├── docker-compose.yml
├── scripts/
│   └── init/
│       └── 01-init.cypher
└── queries/
    ├── 01-patterns.cypher
    └── 02-algorithms.cypher
```

## Sample Data

- Users with social relationships
- Products with recommendations
- Knowledge graph structures
- Temporal relationships

## Accessing Services

- **Neo4j Browser**: http://localhost:7474
- **Bolt Protocol**: bolt://localhost:7687

---

**Status**: ✅ Complete
