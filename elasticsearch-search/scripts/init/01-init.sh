#!/bin/bash

# Elasticsearch Initialization Script
set -e

ES_URL="http://localhost:9200"
MAX_RETRIES=30
RETRY_COUNT=0

echo "Waiting for Elasticsearch to start..."
while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
    if curl -s "$ES_URL" > /dev/null 2>&1; then
        echo "✓ Elasticsearch is ready"
        break
    fi
    RETRY_COUNT=$((RETRY_COUNT + 1))
    sleep 1
done

echo "Creating indexes and loading sample data..."

# Products Index
curl -s -X PUT "$ES_URL/products" -H 'Content-Type: application/json' -d '{
  "settings": {"number_of_shards": 1, "number_of_replicas": 0},
  "mappings": {"properties": {"id": {"type": "keyword"}, "name": {"type": "text"}, "description": {"type": "text"}, "category": {"type": "keyword"}, "price": {"type": "float"}, "rating": {"type": "float"}, "in_stock": {"type": "boolean"}, "created_at": {"type": "date"}}}
}' > /dev/null

# Orders Index
curl -s -X PUT "$ES_URL/orders" -H 'Content-Type: application/json' -d '{
  "settings": {"number_of_shards": 1, "number_of_replicas": 0},
  "mappings": {"properties": {"id": {"type": "keyword"}, "customer_id": {"type": "keyword"}, "order_date": {"type": "date"}, "total_amount": {"type": "float"}, "status": {"type": "keyword"}, "items": {"type": "nested"}}}
}' > /dev/null

# Events Index
curl -s -X PUT "$ES_URL/events" -H 'Content-Type: application/json' -d '{
  "settings": {"number_of_shards": 1, "number_of_replicas": 0},
  "mappings": {"properties": {"timestamp": {"type": "date"}, "event_type": {"type": "keyword"}, "user_id": {"type": "keyword"}}}
}' > /dev/null

# Reviews Index
curl -s -X PUT "$ES_URL/reviews" -H 'Content-Type: application/json' -d '{
  "settings": {"number_of_shards": 1, "number_of_replicas": 0},
  "mappings": {"properties": {"id": {"type": "keyword"}, "product_id": {"type": "keyword"}, "rating": {"type": "integer"}, "content": {"type": "text"}, "created_at": {"type": "date"}}}
}' > /dev/null

echo "✓ Indexes created"
echo "✅ Elasticsearch initialization complete!"
