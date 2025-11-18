# Elasticsearch 50 Practice Examples
# Comprehensive examples for various search operations

# ============================================
# 1-10: Index and Document Operations
# ============================================

# 1. Create index with settings
PUT /my_index
{
  "settings": {
    "number_of_shards": 1,
    "number_of_replicas": 0
  }
}

# 2. Add mapping to index
PUT /my_index/_mapping
{
  "properties": {
    "title": { "type": "text" },
    "status": { "type": "keyword" }
  }
}

# 3. Index document
POST /products/_doc
{
  "name": "Laptop",
  "price": 999.99,
  "category": "Electronics"
}

# 4. Update document
POST /products/_update/1
{
  "doc": {
    "price": 899.99
  }
}

# 5. Delete document
DELETE /products/_doc/1

# 6. Bulk index documents
POST /_bulk
{ "index": { "_index": "products" } }
{ "name": "Product 1", "price": 100 }
{ "index": { "_index": "products" } }
{ "name": "Product 2", "price": 200 }

# 7. Get document by ID
GET /products/_doc/1

# 8. Search all documents
GET /products/_search
{
  "query": { "match_all": {} }
}

# 9. Get index info
GET /products

# 10. Delete index
DELETE /products

# ============================================
# 11-20: Full-Text Search
# ============================================

# 11. Match query single field
GET /products/_search
{
  "query": {
    "match": { "name": "laptop" }
  }
}

# 12. Match phrase query
GET /products/_search
{
  "query": {
    "match_phrase": { "name": "gaming laptop" }
  }
}

# 13. Match with operator
GET /products/_search
{
  "query": {
    "match": {
      "name": {
        "query": "gaming laptop",
        "operator": "and"
      }
    }
  }
}

# 14. Multi-match multiple fields
GET /products/_search
{
  "query": {
    "multi_match": {
      "query": "laptop",
      "fields": ["name", "description"]
    }
  }
}

# 15. Multi-match with boosting
GET /products/_search
{
  "query": {
    "multi_match": {
      "query": "laptop",
      "fields": ["name^2", "description"]
    }
  }
}

# 16. Common terms query
GET /products/_search
{
  "query": {
    "common": {
      "name": {
        "query": "gaming laptop",
        "cutoff_frequency": 0.001
      }
    }
  }
}

# 17. Match with fuzziness
GET /products/_search
{
  "query": {
    "match": {
      "name": {
        "query": "lapto",
        "fuzziness": "AUTO"
      }
    }
  }
}

# 18. Best fields multi-match
GET /products/_search
{
  "query": {
    "multi_match": {
      "query": "gaming laptop",
      "fields": ["name", "description"],
      "type": "best_fields"
    }
  }
}

# 19. Most fields multi-match
GET /products/_search
{
  "query": {
    "multi_match": {
      "query": "gaming laptop",
      "fields": ["name", "description"],
      "type": "most_fields"
    }
  }
}

# 20. Query string
GET /products/_search
{
  "query": {
    "query_string": {
      "query": "name:laptop AND price:>500"
    }
  }
}

# ============================================
# 21-30: Filtering and Range Queries
# ============================================

# 21. Range query
GET /products/_search
{
  "query": {
    "range": {
      "price": { "gte": 100, "lte": 500 }
    }
  }
}

# 22. Term filter (exact match)
GET /products/_search
{
  "query": {
    "term": { "status": "available" }
  }
}

# 23. Terms filter (multiple values)
GET /products/_search
{
  "query": {
    "terms": { "status": ["available", "pre-order"] }
  }
}

# 24. Bool query must
GET /products/_search
{
  "query": {
    "bool": {
      "must": [
        { "match": { "name": "laptop" } },
        { "range": { "price": { "gte": 500 } } }
      ]
    }
  }
}

# 25. Bool query should
GET /products/_search
{
  "query": {
    "bool": {
      "should": [
        { "match": { "name": "laptop" } },
        { "match": { "name": "desktop" } }
      ]
    }
  }
}

# 26. Bool query must_not
GET /products/_search
{
  "query": {
    "bool": {
      "must": [
        { "match": { "name": "computer" } }
      ],
      "must_not": [
        { "term": { "brand": "unknown" } }
      ]
    }
  }
}

# 27. Bool query filter
GET /products/_search
{
  "query": {
    "bool": {
      "must": [
        { "match": { "name": "laptop" } }
      ],
      "filter": [
        { "term": { "status": "available" } }
      ]
    }
  }
}

# 28. Exists query
GET /products/_search
{
  "query": {
    "exists": { "field": "description" }
  }
}

# 29. Missing query (inverse exists)
GET /products/_search
{
  "query": {
    "bool": {
      "must_not": [
        { "exists": { "field": "discount" } }
      ]
    }
  }
}

# 30. Prefix query
GET /products/_search
{
  "query": {
    "prefix": { "name": "game" }
  }
}

# ============================================
# 31-40: Aggregations
# ============================================

# 31. Terms aggregation
GET /products/_search
{
  "size": 0,
  "aggs": {
    "categories": {
      "terms": { "field": "category" }
    }
  }
}

# 32. Date histogram aggregation
GET /products/_search
{
  "size": 0,
  "aggs": {
    "sales_per_month": {
      "date_histogram": {
        "field": "date",
        "interval": "month"
      }
    }
  }
}

# 33. Sum aggregation
GET /products/_search
{
  "size": 0,
  "aggs": {
    "total_sales": {
      "sum": { "field": "price" }
    }
  }
}

# 34. Average aggregation
GET /products/_search
{
  "size": 0,
  "aggs": {
    "average_price": {
      "avg": { "field": "price" }
    }
  }
}

# 35. Min aggregation
GET /products/_search
{
  "size": 0,
  "aggs": {
    "min_price": {
      "min": { "field": "price" }
    }
  }
}

# 36. Max aggregation
GET /products/_search
{
  "size": 0,
  "aggs": {
    "max_price": {
      "max": { "field": "price" }
    }
  }
}

# 37. Stats aggregation
GET /products/_search
{
  "size": 0,
  "aggs": {
    "price_stats": {
      "stats": { "field": "price" }
    }
  }
}

# 38. Value count aggregation
GET /products/_search
{
  "size": 0,
  "aggs": {
    "unique_categories": {
      "value_count": { "field": "category" }
    }
  }
}

# 39. Cardinality aggregation (unique count)
GET /products/_search
{
  "size": 0,
  "aggs": {
    "unique_brands": {
      "cardinality": { "field": "brand" }
    }
  }
}

# 40. Percentiles aggregation
GET /products/_search
{
  "size": 0,
  "aggs": {
    "price_percentiles": {
      "percentiles": { "field": "price" }
    }
  }
}

# ============================================
# 41-50: Advanced Features
# ============================================

# 41. Nested aggregation
GET /products/_search
{
  "size": 0,
  "aggs": {
    "by_category": {
      "terms": { "field": "category" },
      "aggs": {
        "avg_price": {
          "avg": { "field": "price" }
        }
      }
    }
  }
}

# 42. Highlight results
GET /products/_search
{
  "query": { "match": { "name": "laptop" } },
  "highlight": { "fields": { "name": {} } }
}

# 43. Sorting by score
GET /products/_search
{
  "query": { "match": { "name": "laptop" } },
  "sort": [{ "_score": "desc" }]
}

# 44. Sorting by field
GET /products/_search
{
  "query": { "match_all": {} },
  "sort": [{ "price": "asc" }]
}

# 45. From/Size pagination
GET /products/_search
{
  "query": { "match_all": {} },
  "from": 10,
  "size": 20
}

# 46. Source filtering
GET /products/_search
{
  "query": { "match_all": {} },
  "_source": ["name", "price"]
}

# 47. Search after (efficient pagination)
GET /products/_search
{
  "query": { "match_all": {} },
  "search_after": [1000, "product_id"],
  "size": 10
}

# 48. Explain API
GET /products/_explain/1
{
  "query": { "match": { "name": "laptop" } }
}

# 49. Count API
GET /products/_count
{
  "query": { "match": { "name": "laptop" } }
}

# 50. Validate query
GET /products/_validate/query?explain
{
  "query": { "match": { "name": "laptop" } }
}
