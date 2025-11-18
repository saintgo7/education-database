# TimescaleDB Time-Series Module

## Overview
Educational guide for TimescaleDB, a PostgreSQL extension optimized for time-series data.

## What You'll Learn
- Hypertables and automatic partitioning
- Time-bucketing and compression
- Continuous aggregates
- Real-time analytics
- Downsampling strategies
- Time-series optimization
- IoT and metrics data handling

## Key Concepts

### 1. **Hypertables**
- Automatic time-based partitioning
- Transparent querying across chunks
- Data compression
- Retention policies

### 2. **Continuous Aggregates**
- Real-time materialized views
- Automatic refresh
- Downsampling
- Multi-level aggregation

### 3. **Time-Series Queries**
- Time-bucket aggregations
- Moving averages
- Gap filling
- Interpolation

### 4. **Performance**
- Compression ratio improvements
- Faster queries on large datasets
- Efficient storage
- Index strategies

### 5. **Use Cases**
- Metrics collection
- Monitoring and alerting
- IoT sensors
- Stock price tracking

## Quick Start

```bash
# Start TimescaleDB
docker-compose up -d

# Access with psql
psql postgresql://admin:password123@localhost:5433/timeseries_db

# Load sample data
bash scripts/init/01-init.sh
```

## Directory Structure

```
timescaledb-timeseries/
├── docker-compose.yml
├── scripts/
│   └── init/
│       └── 01-schema.sql
└── queries/
    ├── 01-hypertables.sql
    └── 02-aggregates.sql
```

## Accessing Services

- **PostgreSQL**: localhost:5433
- **pgAdmin**: http://localhost:5051

---

**Status**: ✅ Complete
