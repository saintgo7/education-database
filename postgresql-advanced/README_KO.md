# PostgreSQL 고급 (PostgreSQL Advanced)

한국어 문서 | [English Document](./README.md)

## 개요

PostgreSQL 고급 모듈은 관계형 데이터베이스의 고급 기능과 성능 최적화에 대한 400개의 포괄적인 예제를 제공합니다.

## 예제 범위

### 기본 (Level 1: Examples 1-50)
- 기본 SQL 쿼리 (SELECT, INSERT, UPDATE, DELETE)
- 테이블 생성 및 관리
- 인덱싱 기초
- 간단한 조인과 그룹화

### 중급 (Level 2: Examples 51-200)
- 고급 SQL 기능 (CTE, 윈도우 함수)
- JSON/JSONB 데이터 타입
- 배열 및 범위 타입
- 전문 검색 (Full-Text Search)
- 트리거 및 저장 프로시저
- 물리화 뷰

### 고급 (Level 3: Examples 201-400)
- **파티셔닝 (201-225)**
  - 범위 기반 파티셔닝
  - 리스트 기반 파티셔닝
  - 해시 기반 파티셔닝
  - 파티션 자동 관리

- **성능 최적화 (226-250)**
  - 인덱스 전략 (B-tree, BRIN, GiST)
  - 쿼리 플랜 분석
  - 병렬 처리 설정
  - 메모리 및 캐시 관리

- **병렬 처리 (251-275)**
  - 병렬 테이블 스캔
  - 병렬 조인 및 집계
  - 병렬 정렬
  - 병렬 작업 분배

- **실시간 처리 (276-300)**
  - 변경 데이터 캡처 (CDC)
  - 이벤트 로깅
  - 실시간 카운터
  - 스트림 처리

## 파일 구조

```
postgresql-advanced/
├── scripts/
│   ├── examples-1-50.sql           # 기본 예제 (50개)
│   ├── examples-51-200.sql         # 중급 예제 (150개)
│   ├── examples-201-400.sql        # 고급 예제 (200개)
│   ├── runnable-examples.sql       # 실행 가능한 예제
│   └── docker-compose.yml          # Docker 설정
├── README_KO.md                    # 한글 문서
├── README.md                       # 영문 문서
└── docker-compose.yml              # Docker Compose 설정
```

## 빠른 시작

### 1. Docker를 사용한 PostgreSQL 실행

```bash
cd postgresql-advanced
docker-compose up -d

# PostgreSQL 접속
docker-compose exec postgres psql -U postgres
```

### 2. 예제 실행

```bash
# 기본 예제 실행
psql -U postgres -d education_db -f scripts/examples-1-50.sql

# 고급 예제 실행
psql -U postgres -d education_db -f scripts/examples-201-400.sql
```

### 3. 실행 가능한 예제 확인

```bash
psql -U postgres -d education_db -f scripts/runnable-examples.sql
```

## 주요 학습 주제

### 파티셔닝 (Partitioning)
대규모 테이블을 작은 물리 파티션으로 나누어 성능을 향상시킵니다.

```sql
-- 범위 파티셔닝 예제
CREATE TABLE sales (
    id BIGSERIAL,
    order_date DATE NOT NULL,
    amount DECIMAL(10,2)
) PARTITION BY RANGE (EXTRACT(YEAR FROM order_date));

CREATE TABLE sales_2024 PARTITION OF sales
    FOR VALUES FROM (2024) TO (2025);
```

### 성능 최적화 (Performance Optimization)
인덱싱, 쿼리 최적화, 병렬 처리를 통한 성능 개선

```sql
-- BRIN 인덱스 생성 (시계열 데이터에 최적)
CREATE INDEX idx_timeseries_brin
ON metrics USING BRIN (measurement_time)
WITH (pages_per_range=128);

-- 병렬 쿼리 활성화
SET max_parallel_workers_per_gather = 4;
EXPLAIN (ANALYZE) SELECT COUNT(*) FROM large_table;
```

### 고급 SQL (Advanced SQL)
CTE, 윈도우 함수, JSON 처리 등

```sql
-- Common Table Expression (CTE)
WITH ranked_sales AS (
    SELECT
        customer_id,
        amount,
        ROW_NUMBER() OVER (ORDER BY amount DESC) AS rank
    FROM orders
)
SELECT * FROM ranked_sales WHERE rank <= 10;

-- JSON 처리
SELECT
    id,
    data->>'name' AS name,
    data->'address'->>'city' AS city
FROM users
WHERE data->>'status' = 'active';
```

## 성능 최적화 팁

### 1. 인덱스 전략
- **B-tree**: 기본값, 대부분의 쿼리에 적합
- **BRIN**: 시계열 데이터에 최적, 저장공간 효율적
- **GiST**: 공간 데이터, 범위 데이터에 최적
- **Hash**: 등가 검색 최적화

### 2. 쿼리 최적화
- EXPLAIN ANALYZE를 통한 실행 계획 분석
- 불필요한 서브쿼리 제거
- 적절한 조인 순서 설정

### 3. 병렬 처리
- max_parallel_workers 설정
- 병렬 처리 비용 조정
- 워커 풀 설정

## 테스트 및 검증

예제들을 실행하기 전에 테스트 데이터베이스에서 테스트하세요:

```bash
# 테스트 데이터베이스 생성
createdb -U postgres education_db_test

# 예제 실행
psql -U postgres -d education_db_test -f scripts/examples-201-400.sql
```

## 자주 묻는 질문 (FAQ)

### Q: 파티셔닝은 언제 사용해야 하나요?
**A:** 테이블이 수백만 개 이상의 행을 가지고 있을 때, 쿼리 성능을 향상시키거나 유지 관리를 용이하게 하기 위해 사용합니다.

### Q: BRIN 인덱스와 B-tree 인덱스의 차이는?
**A:** BRIN은 저장공간을 덜 사용하지만 검색 성능이 약간 낮습니다. 시계열 데이터나 이미 정렬된 데이터에 최적입니다.

### Q: 병렬 처리가 항상 빠른가요?
**A:** 아닙니다. 작은 테이블이나 간단한 쿼리에서는 병렬 처리의 오버헤드가 성능을 저해할 수 있습니다.

## 추천 학습 순서

1. **기본 개념** (1-50): 기본 SQL 및 테이블 설계
2. **고급 기능** (51-200): CTE, 윈도우 함수, JSON
3. **성능 최적화** (201-250): 파티셔닝, 인덱싱
4. **고급 패턴** (251-400): 병렬 처리, 실시간 처리

## 관련 리소스

- [PostgreSQL 공식 문서](https://www.postgresql.org/docs/)
- [PostgreSQL 성능 최적화](https://www.postgresql.org/docs/current/sql-syntax.html)
- [EXPLAIN 이해하기](https://www.postgresql.org/docs/current/sql-explain.html)

## 라이선스

이 모듈은 MIT 라이선스 아래에 공개됩니다.

---

**마지막 업데이트:** 2024년 11월 18일
