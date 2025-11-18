# Elasticsearch 검색 (Elasticsearch Search)

한국어 문서 | [English Document](./README.md)

## 개요

Elasticsearch 검색 모듈은 확장 가능한 검색 및 분석 엔진의 다양한 기능과 활용법에 대한 400개의 예제를 제공합니다.

## 예제 범위

### 기본 (Level 1: Examples 1-50)
- 인덱스 생성 및 관리
- 문서 색인화
- 기본 검색 쿼리
- 필터링 및 정렬
- 기본 집계

### 중급 (Level 2: Examples 51-200)
- 복합 쿼리 (Bool, Must, Should, Filter)
- 고급 검색 (Fuzzy, Wildcard, Regex)
- 집계 및 통계
- 텍스트 분석
- 매핑 및 분석기 설정

### 고급 (Level 3: Examples 201-400)
- **고급 검색 기법 (201-225)**
  - 부스팅과 관련성 튜닝
  - 불리언 쿼리 결합
  - 퍼지 검색 및 정규표현식
  - 범위 검색

- **성능 최적화 (226-250)**
  - 인덱스 캐시 최적화
  - 분석기 커스터마이징
  - 필드 타입 최적화
  - 리프레시 간격 조정

- **모니터링 (251-275)**
  - 클러스터 상태 확인
  - 노드 정보 조회
  - 인덱스 통계
  - 메모리 및 캐시 모니터링

- **고급 분석 (276-300)**
  - 이상 탐지
  - 예측 분석
  - 머신러닝 통합

## 빠른 시작

### 1. Docker로 Elasticsearch 실행

```bash
cd elasticsearch-search
docker-compose up -d

# 상태 확인
curl http://localhost:9200
```

### 2. 예제 실행

```bash
# 기본 예제
bash scripts/runnable-examples.sh

# 고급 예제
bash scripts/examples-201-400.sh
```

### 3. Kibana로 시각화

```bash
# Kibana 접속
open http://localhost:5601
```

## 주요 기능

### 전문 검색 (Full-Text Search)
```bash
curl -X GET "localhost:9200/products/_search" -H 'Content-Type: application/json' -d'{
  "query": {
    "multi_match": {
      "query": "elasticsearch search engine",
      "fields": ["title^3", "description"]
    }
  }
}'
```

### 집계 및 분석
```bash
curl -X GET "localhost:9200/sales/_search" -H 'Content-Type: application/json' -d'{
  "size": 0,
  "aggs": {
    "sales_per_month": {
      "date_histogram": {
        "field": "date",
        "calendar_interval": "month"
      },
      "aggs": {
        "total_sales": {
          "sum": {"field": "amount"}
        }
      }
    }
  }
}'
```

### 머신러닝 기반 이상 탐지
```bash
curl -X PUT "localhost:9200/_ml/anomaly_detectors/sales_anomaly" -H 'Content-Type: application/json' -d'{
  "description": "Sales anomaly detector",
  "analysis_config": {
    "bucket_span": "15m",
    "detectors": [{"function": "mean", "field_name": "sales_amount"}]
  }
}'
```

## 성능 최적화

### 1. 인덱싱 성능
```bash
# 벌크 인덱싱 사용
curl -X POST "localhost:9200/_bulk" -H 'Content-Type: application/json' --data-binary @bulk_data.json
```

### 2. 검색 성능
```bash
# 필터를 먼저 적용하여 검색 범위 축소
{
  "query": {
    "bool": {
      "filter": [
        {"term": {"status": "active"}},
        {"range": {"date": {"gte": "2024-01-01"}}}
      ],
      "must": [
        {"match": {"title": "elasticsearch"}}
      ]
    }
  }
}
```

### 3. 메모리 관리
```bash
# JVM 힙 메모리 설정
export ES_JAVA_OPTS="-Xms512m -Xmx512m"
```

## 자주 묻는 질문

### Q: 검색이 느린 경우?
**A:** 인덱스 구조 확인, 필터 추가, 샤드 수 조정, 캐시 활성화를 시도하세요.

### Q: 용량 관리는?
**A:** 인덱스 수명 관리(Index Lifecycle Management), 큐레이션, 압축을 사용하세요.

---

**마지막 업데이트:** 2024년 11월 18일
