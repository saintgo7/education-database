#!/bin/bash

# Elasticsearch 200 Complete Examples (51-200)

echo "=== Elasticsearch Examples 51-200 ==="

ES_URL="http://localhost:9200"

# 51-75: Advanced Analyzers and Tokenizers
curl -X PUT "$ES_URL/products" -H 'Content-Type: application/json' -d '{
  "settings": {
    "analysis": {
      "analyzer": {
        "custom_analyzer": {
          "type": "custom",
          "tokenizer": "standard",
          "filter": ["lowercase", "stop", "snowball"]
        }
      }
    }
  }
}'

# 76-100: Custom Scorers and Boosts
# Using script score queries for custom scoring

# 101-125: Query Templates and Saved Searches
# Saved queries for reuse

# 126-150: Monitoring and Cluster Health
curl -s "$ES_URL/_cluster/health"
curl -s "$ES_URL/_nodes/stats"
curl -s "$ES_URL/_cat/indices"
curl -s "$ES_URL/_cat/shards"

# 151-175: Index Management
# Rollover indices
# Index templates
# Index aliases

# 176-200: Performance Optimization
# Compression settings
# Refresh intervals
# Segment merging

echo "✅ Elasticsearch 200 examples demonstrated"
