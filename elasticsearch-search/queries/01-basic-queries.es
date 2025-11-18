# Elasticsearch Basic Queries Examples

## 1. Match Query (Full-text search with text analysis)
GET /products/_search
{
  "query": {
    "match": {
      "description": "wireless headphones"
    }
  }
}

## 2. Multi-Match Query (Search across multiple fields)
GET /products/_search
{
  "query": {
    "multi_match": {
      "query": "headphones",
      "fields": ["name^2", "description"]
    }
  }
}

## 3. Term Query (Exact matching - no text analysis)
GET /products/_search
{
  "query": {
    "term": {
      "category": "Electronics"
    }
  }
}

## 4. Range Query
GET /products/_search
{
  "query": {
    "range": {
      "price": {
        "gte": 50,
        "lte": 200
      }
    }
  }
}

## 5. Boolean Query - Must (AND)
GET /products/_search
{
  "query": {
    "bool": {
      "must": [
        { "match": { "description": "wireless" } },
        { "term": { "in_stock": true } }
      ]
    }
  }
}

## 6. Boolean Query - Should (OR)
GET /products/_search
{
  "query": {
    "bool": {
      "should": [
        { "match": { "name": "headphones" } },
        { "match": { "name": "keyboard" } }
      ],
      "minimum_should_match": 1
    }
  }
}

## 7. Boolean Query - Must Not (NOT)
GET /products/_search
{
  "query": {
    "bool": {
      "must": [
        { "match": { "description": "headphones" } }
      ],
      "must_not": [
        { "term": { "in_stock": false } }
      ]
    }
  }
}

## 8. Wildcard Query
GET /products/_search
{
  "query": {
    "wildcard": {
      "name": "Wireles*"
    }
  }
}

## 9. Prefix Query
GET /products/_search
{
  "query": {
    "prefix": {
      "name": "Wireless"
    }
  }
}

## 10. Regex Query
GET /products/_search
{
  "query": {
    "regexp": {
      "name": "[a-z]*phone[a-z]*"
    }
  }
}

## 11. Nested Query (Search in nested objects)
GET /orders/_search
{
  "query": {
    "nested": {
      "path": "items",
      "query": {
        "match": {
          "items.product_name": "Headphones"
        }
      }
    }
  }
}

## 12. Filter Context (Faster, cached)
GET /products/_search
{
  "query": {
    "bool": {
      "filter": [
        { "term": { "category": "Electronics" } },
        { "range": { "price": { "lte": 200 } } }
      ]
    }
  }
}

## 13. Search with Highlighting
GET /products/_search
{
  "query": {
    "match": {
      "description": "wireless"
    }
  },
  "highlight": {
    "fields": {
      "description": {}
    }
  }
}

## 14. Search with Sorting
GET /products/_search
{
  "query": {
    "match_all": {}
  },
  "sort": [
    { "price": "desc" }
  ]
}

## 15. Pagination with From/Size
GET /products/_search
{
  "query": { "match_all": {} },
  "from": 0,
  "size": 10
}
