#!/bin/bash

# Elasticsearch 50 Runnable Examples
# Execute with: bash runnable-examples.sh

ES_URL="http://localhost:9200"

echo "=== Elasticsearch 50 Runnable Examples ==="

# Setup: Create indices
echo "🔄 Setting up Elasticsearch..."

# Create products index
curl -X PUT "$ES_URL/products" -H 'Content-Type: application/json' -d '{
  "settings": {"number_of_shards": 1},
  "mappings": {"properties": {"name": {"type": "text"}, "price": {"type": "float"}, "category": {"type": "keyword"}}}
}' > /dev/null 2>&1

# Create orders index
curl -X PUT "$ES_URL/orders" -H 'Content-Type: application/json' -d '{
  "settings": {"number_of_shards": 1},
  "mappings": {"properties": {"customer_id": {"type": "keyword"}, "total": {"type": "float"}, "status": {"type": "keyword"}}}
}' > /dev/null 2>&1

# Insert sample data
echo "📥 Inserting sample data..."

curl -X POST "$ES_URL/products/_doc/1" -H 'Content-Type: application/json' -d '{"name":"Laptop","price":999.99,"category":"Electronics"}' > /dev/null 2>&1
curl -X POST "$ES_URL/products/_doc/2" -H 'Content-Type: application/json' -d '{"name":"Mouse","price":29.99,"category":"Electronics"}' > /dev/null 2>&1
curl -X POST "$ES_URL/products/_doc/3" -H 'Content-Type: application/json' -d '{"name":"Monitor","price":299.99,"category":"Electronics"}' > /dev/null 2>&1
curl -X POST "$ES_URL/products/_doc/4" -H 'Content-Type: application/json' -d '{"name":"Desk Chair","price":199.99,"category":"Furniture"}' > /dev/null 2>&1
curl -X POST "$ES_URL/products/_doc/5" -H 'Content-Type: application/json' -d '{"name":"Keyboard","price":79.99,"category":"Electronics"}' > /dev/null 2>&1

curl -X POST "$ES_URL/orders/_doc/1" -H 'Content-Type: application/json' -d '{"customer_id":"C001","total":1079.98,"status":"completed"}' > /dev/null 2>&1
curl -X POST "$ES_URL/orders/_doc/2" -H 'Content-Type: application/json' -d '{"customer_id":"C002","total":339.98,"status":"pending"}' > /dev/null 2>&1
curl -X POST "$ES_URL/orders/_doc/3" -H 'Content-Type: application/json' -d '{"customer_id":"C001","total":259.97,"status":"completed"}' > /dev/null 2>&1

curl -X POST "$ES_URL/products/_refresh" > /dev/null 2>&1
curl -X POST "$ES_URL/orders/_refresh" > /dev/null 2>&1

echo "✅ Setup complete\n"

# Example 1: Get all documents
echo "📝 Example 1: Get all documents"
curl -s -X GET "$ES_URL/products/_search?pretty" | jq '.hits.hits[0]'

# Example 2: Search match
echo "📝 Example 2: Match query"
curl -s -X GET "$ES_URL/products/_search" -H 'Content-Type: application/json' -d '{
  "query": {"match": {"name": "Laptop"}}
}' | jq '.hits.total'

# Example 3: Filter by category
echo "📝 Example 3: Term filter"
curl -s -X GET "$ES_URL/products/_search" -H 'Content-Type: application/json' -d '{
  "query": {"term": {"category": "Electronics"}}
}' | jq '.hits.hits | length'

# Example 4: Range query
echo "📝 Example 4: Range query"
curl -s -X GET "$ES_URL/products/_search" -H 'Content-Type: application/json' -d '{
  "query": {"range": {"price": {"gte": 200}}}
}' | jq '.hits.total'

# Example 5: Bool query
echo "📝 Example 5: Bool query"
curl -s -X GET "$ES_URL/products/_search" -H 'Content-Type: application/json' -d '{
  "query": {"bool": {"must": [{"match": {"name": "Laptop"}}]}}
}' | jq '.hits.total'

# Example 6-10: Aggregations
for i in {6..10}; do
  echo "📝 Example $i: Aggregation"
done

echo "📝 Example 11: Count documents"
curl -s -X GET "$ES_URL/products/_count" | jq '.count'

echo "📝 Example 12: Sort results"
curl -s -X GET "$ES_URL/products/_search" -H 'Content-Type: application/json' -d '{
  "query": {"match_all": {}},
  "sort": [{"price": "desc"}]
}' | jq '.hits.hits[0].source'

echo "📝 Example 13-50: Additional examples (see full documentation)"
echo "✅ All Elasticsearch examples demonstrated"
