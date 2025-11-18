# Elasticsearch Search Module

## Overview
Complete educational guide for Elasticsearch, covering full-text search, aggregations, and Kibana visualization.

## What You'll Learn
- Full-text search and relevance scoring
- Mapping and index configuration
- Aggregations: metrics, terms, filters
- Text analysis: tokenizers, filters
- Kibana visualization and dashboards
- Performance optimization
- Advanced querying techniques

## Key Concepts

### 1. **Indexes & Mappings**
- Explicit mapping definition
- Field types: text, keyword, number, date, geo
- Dynamic mapping configuration
- Nested and object data types

### 2. **Search Operations**
- Match query (text analysis applied)
- Term query (exact matching)
- Range queries
- Boolean queries (AND, OR, NOT)
- Wildcard and regex searches

### 3. **Aggregations**
- Metric aggregations: sum, avg, min, max
- Bucket aggregations: terms, date_histogram
- Pipeline aggregations
- Sub-aggregations (nested)

### 4. **Text Analysis**
- Standard analyzer
- Custom analyzers
- Tokenizers: standard, whitespace, keyword
- Filters: lowercase, synonyms, stop words

### 5. **Performance**
- Index refresh interval tuning
- Shard allocation strategy
- Query optimization
- Bulk indexing

## Quick Start

```bash
# Start Elasticsearch and Kibana
docker-compose up -d

# Wait for services to be ready
sleep 30

# Initialize sample data
bash scripts/init/01-init.sh

# Access Kibana
# http://localhost:5601

# Check cluster health
curl http://localhost:9200/_cluster/health?pretty
```

## Directory Structure

```
elasticsearch-search/
├── docker-compose.yml          # Service configuration
├── config/
│   └── elasticsearch.yml        # ES configuration
├── scripts/
│   └── init/
│       └── 01-init.sh          # Initialization script
└── queries/
    ├── 01-basic-queries.es     # Search queries
    ├── 02-aggregations.es      # Aggregation examples
    └── 03-text-analysis.es     # Text analysis
```

## Sample Data

- **Products Index**: 500 products with full-text descriptions
- **Orders Index**: 2000 orders with nested items
- **Events Index**: 5000+ time-series events
- **Reviews Index**: 1000+ product reviews

## Queries Included

### Basic Queries
- Match query (tokenized text search)
- Term query (exact field matching)
- Prefix and wildcard searches
- Range queries (dates, numbers)
- Boolean queries (must, should, filter)

### Aggregations
- Top 10 products by revenue
- Sales by product category
- Order count by date (histogram)
- Customer spending statistics
- Product rating distribution

### Text Analysis
- Custom tokenizers
- Synonym filters
- Stop word filters
- Lowercasing and stemming

## Running Queries

```bash
# In Kibana Dev Tools, run:
GET /products/_search
{
  "query": {
    "multi_match": {
      "query": "wireless headphones",
      "fields": ["name^2", "description"]
    }
  },
  "size": 20
}

# Or with curl:
curl -X GET "localhost:9200/products/_search" -H 'Content-Type: application/json' -d'
{
  "query": {
    "match": {
      "description": "wireless"
    }
  }
}'
```

## Advanced Topics

### 1. **Relevance Scoring**
- TF-IDF algorithm
- BM25 ranking
- Boosting and scoring

### 2. **Performance Optimization**
- Filter context (faster, cacheable)
- Pagination with from/size
- Cursor scrolling for large results
- Search-after for real-time cursors

### 3. **Indexing Strategy**
- Bulk indexing for performance
- Index aliases for zero-downtime reindexing
- Index templates
- Index lifecycle management (ILM)

### 4. **Monitoring**
- Cluster monitoring
- Node statistics
- Shard allocation
- Index performance metrics

## Accessing Services

- **Elasticsearch API**: http://localhost:9200
- **Kibana Dashboard**: http://localhost:5601

## Cleanup

```bash
docker-compose down -v
```

## Learning Resources

- [Elasticsearch Official Docs](https://www.elastic.co/guide/en/elasticsearch/reference/current/index.html)
- [Kibana Visualization Guide](https://www.elastic.co/guide/en/kibana/current/index.html)
- Query and aggregation patterns for real-world use cases

## Use Cases

- **Log Analysis**: Parse and search application logs
- **E-commerce Search**: Product discovery with faceting
- **Analytics**: Time-series data aggregation
- **Security**: Threat detection and investigation
- **Site Search**: Website content discovery

---

**Status**: ✅ Complete
**Last Updated**: 2025-11-18
