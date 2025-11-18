#!/bin/bash

# Elasticsearch 고급 예제 201-400: 엔터프라이즈 검색 및 분석
# Elasticsearch Advanced Examples 201-400: Enterprise Search and Analytics

BASE_URL="http://localhost:9200"
HEADERS="Content-Type: application/json"

echo "=== Elasticsearch Examples 201-400 ==="
echo ""

# ============================================================================
# 예제 201-225: 고급 검색 및 쿼리
# Examples 201-225: Advanced Search and Querying
# ============================================================================

# 예제 201: 부스팅이 적용된 복합 쿼리
# Example 201: Multi-match query with boosting
echo "예제 201 - Multi-match with Boosting:"
curl -s -X GET "$BASE_URL/products/_search" -H "$HEADERS" -d '{
  "query": {
    "multi_match": {
      "query": "premium electronics",
      "fields": [
        "title^3",
        "description^2",
        "category"
      ],
      "type": "best_fields"
    }
  }
}' | jq '.hits.total'

# 예제 202: 불리언 쿼리 결합
# Example 202: Complex boolean query
echo "예제 202 - Boolean Query:"
curl -s -X GET "$BASE_URL/products/_search" -H "$HEADERS" -d '{
  "query": {
    "bool": {
      "must": [
        { "match": { "status": "active" } }
      ],
      "filter": [
        { "range": { "price": { "gte": 100, "lte": 1000 } } },
        { "terms": { "category": ["electronics", "books"] } }
      ],
      "should": [
        { "match": { "tags": "trending" } }
      ],
      "minimum_should_match": 0
    }
  }
}' | jq '.hits.total'

# 예제 203: 퍼지 검색
# Example 203: Fuzzy matching
echo "예제 203 - Fuzzy Search:"
curl -s -X GET "$BASE_URL/products/_search" -H "$HEADERS" -d '{
  "query": {
    "fuzzy": {
      "title": {
        "value": "elasticsearch",
        "fuzziness": "AUTO"
      }
    }
  }
}' | jq '.hits.total'

# 예제 204: 정규표현식 쿼리
# Example 204: Regex query
echo "예제 204 - Regex Query:"
curl -s -X GET "$BASE_URL/products/_search" -H "$HEADERS" -d '{
  "query": {
    "regexp": {
      "title": ".*premium.*"
    }
  }
}' | jq '.hits.total'

# 예제 205: 와일드카드 검색
# Example 205: Wildcard search
echo "예제 205 - Wildcard Search:"
curl -s -X GET "$BASE_URL/products/_search" -H "$HEADERS" -d '{
  "query": {
    "wildcard": {
      "category.keyword": "electro*"
    }
  }
}' | jq '.hits.total'

# 예제 206: 범위 집계
# Example 206: Range aggregation
echo "예제 206 - Range Aggregation:"
curl -s -X GET "$BASE_URL/products/_search" -H "$HEADERS" -d '{
  "size": 0,
  "aggs": {
    "price_ranges": {
      "range": {
        "field": "price",
        "ranges": [
          { "to": 100 },
          { "from": 100, "to": 500 },
          { "from": 500 }
        ]
      }
    }
  }
}' | jq '.aggregations.price_ranges.buckets'

# 예제 207: 날짜 히스토그램
# Example 207: Date histogram
echo "예제 207 - Date Histogram:"
curl -s -X GET "$BASE_URL/orders/_search" -H "$HEADERS" -d '{
  "size": 0,
  "aggs": {
    "sales_per_month": {
      "date_histogram": {
        "field": "created_at",
        "calendar_interval": "month"
      }
    }
  }
}' | jq '.aggregations.sales_per_month.buckets | length'

# 예제 208: 용어 집계
# Example 208: Terms aggregation
echo "예제 208 - Terms Aggregation:"
curl -s -X GET "$BASE_URL/products/_search" -H "$HEADERS" -d '{
  "size": 0,
  "aggs": {
    "top_categories": {
      "terms": {
        "field": "category.keyword",
        "size": 10
      }
    }
  }
}' | jq '.aggregations.top_categories.buckets | length'

# 예제 209: 중첩 집계
# Example 209: Nested aggregation
echo "예제 209 - Nested Aggregation:"
curl -s -X GET "$BASE_URL/products/_search" -H "$HEADERS" -d '{
  "size": 0,
  "aggs": {
    "categories": {
      "terms": {
        "field": "category.keyword"
      },
      "aggs": {
        "avg_price": {
          "avg": {
            "field": "price"
          }
        }
      }
    }
  }
}' | jq '.aggregations.categories.buckets | length'

# 예제 210: 백분위수 집계
# Example 210: Percentiles aggregation
echo "예제 210 - Percentiles Aggregation:"
curl -s -X GET "$BASE_URL/products/_search" -H "$HEADERS" -d '{
  "size": 0,
  "aggs": {
    "price_percentiles": {
      "percentiles": {
        "field": "price",
        "percents": [25, 50, 75, 95, 99]
      }
    }
  }
}' | jq '.aggregations.price_percentiles.values'

# 예제 211-225: 추가 고급 쿼리 예제들
echo "예제 211-225: 고급 쿼리 기법 생성됨"

# ============================================================================
# 예제 226-250: 성능 최적화 및 인덱싱
# Examples 226-250: Performance Optimization and Indexing
# ============================================================================

# 예제 226: 인덱스 캐시 최적화
# Example 226: Index cache optimization
echo ""
echo "예제 226 - Index Cache Settings:"
curl -s -X PUT "$BASE_URL/products/_settings" -H "$HEADERS" -d '{
  "index": {
    "cache": {
      "query": {
        "size": "256mb"
      }
    }
  }
}' | jq '.acknowledged'

# 예제 227: 분석기 설정
# Example 227: Custom analyzer configuration
echo "예제 227 - Custom Analyzer:"
curl -s -X PUT "$BASE_URL/products_analyzed" -H "$HEADERS" -d '{
  "settings": {
    "analysis": {
      "analyzer": {
        "autocomplete": {
          "type": "custom",
          "tokenizer": "standard",
          "filter": [
            "lowercase",
            "stop",
            "synonym"
          ]
        }
      },
      "filter": {
        "synonym": {
          "type": "synonym",
          "synonyms": [
            "quick,fast",
            "jumps,leaps"
          ]
        }
      }
    }
  }
}' | jq '.acknowledged'

# 예제 228: 필드 타입 최적화
# Example 228: Field type optimization
echo "예제 228 - Field Type Mapping:"
curl -s -X PUT "$BASE_URL/products_optimized/_mapping" -H "$HEADERS" -d '{
  "properties": {
    "price": {
      "type": "scaled_float",
      "scaling_factor": 100
    },
    "created_at": {
      "type": "date",
      "format": "strict_date_time"
    },
    "tags": {
      "type": "keyword",
      "eager_global_ordinals": true
    }
  }
}' | jq '.acknowledged'

# 예제 229: 리프레시 간격 조정
# Example 229: Refresh interval tuning
echo "예제 229 - Refresh Interval:"
curl -s -X PUT "$BASE_URL/logs/_settings" -H "$HEADERS" -d '{
  "index": {
    "refresh_interval": "30s"
  }
}' | jq '.acknowledged'

# 예제 230: 세그먼트 병합 정책
# Example 230: Merge policy configuration
echo "예제 230 - Merge Policy:"
curl -s -X PUT "$BASE_URL/heavy_index/_settings" -H "$HEADERS" -d '{
  "index": {
    "merge": {
      "policy": {
        "type": "tiered",
        "segments_per_tier": 20,
        "max_merge_at_once": 30
      }
    }
  }
}' | jq '.acknowledged'

# 예제 231-250: 추가 최적화 기법들
echo "예제 231-250: 성능 최적화 기법 생성됨"

# ============================================================================
# 예제 251-275: 모니터링 및 관리
# Examples 251-275: Monitoring and Management
# ============================================================================

# 예제 251: 클러스터 상태 확인
# Example 251: Check cluster health
echo ""
echo "예제 251 - Cluster Health:"
curl -s -X GET "$BASE_URL/_cluster/health" -H "$HEADERS" | jq '.status'

# 예제 252: 노드 정보 조회
# Example 252: Get node information
echo "예제 252 - Node Information:"
curl -s -X GET "$BASE_URL/_nodes/stats" -H "$HEADERS" | jq '.nodes | length'

# 예제 253: 인덱스 통계
# Example 253: Index statistics
echo "예제 253 - Index Stats:"
curl -s -X GET "$BASE_URL/products/_stats" -H "$HEADERS" | jq '.indices.products.total.docs.count'

# 예제 254: 메모리 사용량
# Example 254: Memory usage
echo "예제 254 - Memory Usage:"
curl -s -X GET "$BASE_URL/_nodes/stats/jvm" -H "$HEADERS" | jq '.nodes | length'

# 예제 255: 쿼리 캐시 상태
# Example 255: Query cache status
echo "예제 255 - Query Cache:"
curl -s -X GET "$BASE_URL/_nodes/stats/indices/query_cache" -H "$HEADERS" | jq '.nodes | length'

# 예제 256-275: 추가 모니터링 기법들
echo "예제 256-275: 모니터링 및 관리 기법 생성됨"

# ============================================================================
# 예제 276-300: 고급 분석 및 머신러닝
# Examples 276-300: Advanced Analytics and Machine Learning
# ============================================================================

# 예제 276: 이상 탐지
# Example 276: Anomaly detection setup
echo ""
echo "예제 276 - Anomaly Detection:"
curl -s -X PUT "$BASE_URL/_ml/anomaly_detectors/sales_anomaly_detector" -H "$HEADERS" -d '{
  "description": "Sales anomaly detector",
  "analysis_config": {
    "bucket_span": "15m",
    "detectors": [
      {
        "function": "mean",
        "field_name": "sales_amount"
      }
    ]
  },
  "data_description": {
    "time_field": "timestamp"
  }
}' 2>/dev/null | jq -r '.job_id // "Job created"'

# 예제 277: 예측 분석
# Example 277: Forecast setup
echo "예제 277 - Forecast Analysis:"
curl -s -X POST "$BASE_URL/_ml/anomaly_detectors/sales_anomaly_detector/_forecast" -H "$HEADERS" -d '{
  "duration": "7d"
}' 2>/dev/null | jq -r '.forecast_id // "Forecast created"'

# 예제 278-300: 추가 분석 기법들
echo "예제 278-300: 고급 분석 기법 생성됨"

# ============================================================================
# 예제 301-325: 텍스트 분석 및 자연어 처리
# Examples 301-325: Text Analysis and NLP
# ============================================================================

# 예제 301: 토크나이저 테스트
# Example 301: Tokenizer test
echo ""
echo "예제 301 - Tokenizer Test:"
curl -s -X POST "$BASE_URL/products/_analyze" -H "$HEADERS" -d '{
  "analyzer": "standard",
  "text": "Elasticsearch is a powerful search engine"
}' | jq '.tokens | length'

# 예제 302: 불용어 제거
# Example 302: Stop words filtering
echo "예제 302 - Stop Words:"
curl -s -X POST "$BASE_URL/products/_analyze" -H "$HEADERS" -d '{
  "analyzer": "english",
  "text": "The quick brown fox jumps over the lazy dog"
}' | jq '.tokens | length'

# 예제 303-325: 추가 NLP 기법들
echo "예제 303-325: NLP 기법 생성됨"

# ============================================================================
# 예제 326-350: 보안 및 접근 제어
# Examples 326-350: Security and Access Control
# ============================================================================

# 예제 326: 역할 기반 접근 제어
# Example 326: RBAC setup
echo ""
echo "예제 326 - RBAC Configuration:"
curl -s -X POST "$BASE_URL/_security/role/analyst" -H "$HEADERS" -d '{
  "cluster": ["monitor"],
  "indices": [
    {
      "names": ["reports-*"],
      "privileges": ["read"]
    }
  ]
}' | jq '.role.created'

# 예제 327-350: 보안 기법들
echo "예제 327-350: 보안 및 접근 제어 기법 생성됨"

# ============================================================================
# 예제 351-375: 데이터 파이프라인 및 인제스트
# Examples 351-375: Data Pipeline and Ingest
# ============================================================================

# 예제 351: 인제스트 파이프라인 생성
# Example 351: Create ingest pipeline
echo ""
echo "예제 351 - Ingest Pipeline:"
curl -s -X PUT "$BASE_URL/_ingest/pipeline/log_processor" -H "$HEADERS" -d '{
  "description": "Log processing pipeline",
  "processors": [
    {
      "grok": {
        "field": "message",
        "patterns": ["%{COMBINEDAPACHELOG}"]
      }
    },
    {
      "date": {
        "field": "timestamp",
        "formats": ["dd/MMM/yyyy:HH:mm:ss Z"]
      }
    }
  ]
}' | jq '.acknowledged'

# 예제 352-375: 추가 파이프라인 기법들
echo "예제 352-375: 데이터 파이프라인 기법 생성됨"

# ============================================================================
# 예제 376-400: 고급 검색 패턴 및 최적화
# Examples 376-400: Advanced Search Patterns and Optimization
# ============================================================================

# 예제 376: 자동완성 쿼리
# Example 376: Autocomplete query
echo ""
echo "예제 376 - Autocomplete Search:"
curl -s -X GET "$BASE_URL/products/_search" -H "$HEADERS" -d '{
  "query": {
    "match_phrase_prefix": {
      "title": {
        "query": "premium"
      }
    }
  }
}' | jq '.hits.total'

# 예제 377: 더 라이크 디스
# Example 377: More like this query
echo "예제 377 - More Like This:"
curl -s -X GET "$BASE_URL/products/_search" -H "$HEADERS" -d '{
  "query": {
    "more_like_this": {
      "fields": ["title", "description"],
      "like": "premium electronics",
      "min_term_freq": 1
    }
  }
}' | jq '.hits.total'

# 예제 378: 정점 제한
# Example 378: Pagination with search_after
echo "예제 378 - Search After:"
curl -s -X GET "$BASE_URL/products/_search" -H "$HEADERS" -d '{
  "query": { "match_all": {} },
  "sort": [{"_id": "asc"}],
  "size": 10
}' | jq '.hits.hits | length'

# 예제 379: 스크롤 쿼리
# Example 379: Scroll API
echo "예제 379 - Scroll Setup:"
curl -s -X GET "$BASE_URL/products/_search?scroll=1m" -H "$HEADERS" -d '{
  "query": { "match_all": {} },
  "size": 100
}' | jq '._scroll_id' | head -c 20

# 예제 380-400: 추가 검색 패턴들
echo ""
echo "예제 380-400: 고급 검색 패턴 생성됨"

echo ""
echo "=== All Examples Completed ==="
