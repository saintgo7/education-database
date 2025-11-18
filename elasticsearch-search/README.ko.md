# Elasticsearch 검색 모듈

## 개요
Elasticsearch의 전문 검색, 집계, Kibana 시각화를 다루는 완전한 교육 가이드입니다.

## 학습 내용
- 전문(Full-text) 검색 및 관련성 점수
- 매핑 및 인덱스 설정
- 집계: 지표, 용어, 필터
- 텍스트 분석: 토크나이저, 필터
- Kibana 시각화 및 대시보드
- 성능 최적화
- 고급 쿼리 기법

## 핵심 개념

### 1. **인덱스 & 매핑**
- 명시적 매핑 정의
- 필드 타입: text, keyword, number, date, geo
- 동적 매핑 설정
- 중첩(Nested) 및 객체 데이터 타입

### 2. **검색 작업**
- Match 쿼리 (텍스트 분석 적용)
- Term 쿼리 (정확히 일치)
- 범위 쿼리
- Boolean 쿼리 (AND, OR, NOT)
- 와일드카드 및 정규식 검색

### 3. **집계**
- 지표 집계: sum, avg, min, max
- 버킷 집계: terms, date_histogram
- 파이프라인 집계
- 하위 집계 (중첩)

### 4. **텍스트 분석**
- Standard 분석기
- 사용자 정의 분석기
- 토크나이저: standard, whitespace, keyword
- 필터: lowercase, synonyms, stop words

### 5. **성능**
- 인덱스 새로고침 간격 조정
- 샤드 할당 전략
- 쿼리 최적화
- 대량 인덱싱

## 빠른 시작

```bash
# Elasticsearch와 Kibana 시작
docker-compose up -d

# 서비스 준비 대기
sleep 30

# 샘플 데이터 초기화
bash scripts/init/01-init.sh

# Kibana 접속
# http://localhost:5601

# 클러스터 상태 확인
curl http://localhost:9200/_cluster/health?pretty
```

## 디렉토리 구조

```
elasticsearch-search/
├── docker-compose.yml          # 서비스 설정
├── config/
│   └── elasticsearch.yml        # ES 설정
├── scripts/
│   └── init/
│       └── 01-init.sh          # 초기화 스크립트
└── queries/
    ├── 01-basic-queries.es     # 검색 쿼리
    ├── 02-aggregations.es      # 집계 예제
    └── 03-text-analysis.es     # 텍스트 분석
```

## 샘플 데이터

- **Products Index**: 500개 상품 (전문 설명 포함)
- **Orders Index**: 2000개 주문 (중첩 항목)
- **Events Index**: 5000+ 시계열 이벤트
- **Reviews Index**: 1000+ 상품 리뷰

## 포함된 쿼리

### 기본 쿼리
- Match 쿼리 (토크나이즈된 텍스트 검색)
- Term 쿼리 (정확한 필드 일치)
- Prefix 및 와일드카드 검색
- 범위 쿼리 (날짜, 숫자)
- Boolean 쿼리 (must, should, filter)

### 집계
- 수익 상위 10 상품
- 카테고리별 판매량
- 날짜별 주문 수 (히스토그램)
- 고객 지출 통계
- 상품 평점 분포

### 텍스트 분석
- 사용자 정의 토크나이저
- 동의어 필터
- 불용어 필터
- 소문자 변환 및 어간 추출

## 쿼리 실행

```bash
# Kibana Dev Tools에서 실행:
GET /products/_search
{
  "query": {
    "multi_match": {
      "query": "무선 헤드폰",
      "fields": ["name^2", "description"]
    }
  },
  "size": 20
}

# 또는 curl 사용:
curl -X GET "localhost:9200/products/_search" -H 'Content-Type: application/json' -d'
{
  "query": {
    "match": {
      "description": "무선"
    }
  }
}'
```

## 고급 주제

### 1. **관련성 점수**
- TF-IDF 알고리즘
- BM25 랭킹
- 부스팅 및 점수 매기기

### 2. **성능 최적화**
- Filter context (빠르고 캐시 가능)
- from/size로 페이지네이션
- 커서 스크롤 (대용량 결과)
- Search-after (실시간 커서)

### 3. **인덱싱 전략**
- 대량 인덱싱
- 인덱스 별칭 (다운타임 없는 재인덱싱)
- 인덱스 템플릿
- 인덱스 생명주기 관리 (ILM)

### 4. **모니터링**
- 클러스터 모니터링
- 노드 통계
- 샤드 할당
- 인덱스 성능 지표

## 서비스 접근

- **Elasticsearch API**: http://localhost:9200
- **Kibana 대시보드**: http://localhost:5601

## 정리

```bash
docker-compose down -v
```

## 학습 자료

- [Elasticsearch 공식 문서](https://www.elastic.co/guide/en/elasticsearch/reference/current/index.html)
- [Kibana 시각화 가이드](https://www.elastic.co/guide/en/kibana/current/index.html)
- 실제 사용 사례를 위한 쿼리 및 집계 패턴

## 사용 사례

- **로그 분석**: 애플리케이션 로그 파싱 및 검색
- **전자상거래 검색**: 패싯을 포함한 상품 발견
- **분석**: 시계열 데이터 집계
- **보안**: 위협 탐지 및 조사
- **사이트 검색**: 웹사이트 콘텐츠 발견

---

**상태**: ✅ 완료
**마지막 업데이트**: 2025-11-18
