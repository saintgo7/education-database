# PostgreSQL 고급 기능

인덱스, 트리거, 저장 프로시저, 쿼리 최적화를 포함한 고급 PostgreSQL 기능 학습 자료입니다.

## 주요 기능

- **다양한 인덱스 타입**: B-tree, GIN, GiST, Hash, Partial, Expression 인덱스
- **트리거**: 자동 타임스탬프 업데이트, 감사 로깅, 재고 검증
- **저장 프로시저**: 주문 생성, 통계 업데이트, 검색 함수
- **쿼리 최적화**: 50개 이상의 최적화된 쿼리 예제
- **성능 벤치마크**: 인덱스 비교, JOIN 테스트, 집계 테스트
- **1000개 이상의 샘플 데이터**: 사용자, 제품, 주문, 리뷰

## 빠른 시작

1. **데이터베이스 시작**:
   ```bash
   docker-compose up -d
   ```

2. **실행 확인**:
   ```bash
   docker ps
   ```

3. **PostgreSQL 접속**:
   ```bash
   docker exec -it postgres-advanced psql -U postgres -d education_db
   ```

4. **pgAdmin 접속**: http://localhost:5050
   - 이메일: admin@admin.com
   - 비밀번호: admin

## 데이터베이스 스키마

```
users (500개 레코드)
├── user_id (UUID, 기본키)
├── username (고유)
├── email (인덱스)
├── status (열거형: active/inactive/suspended)
└── preferences (JSONB)

products (300개 레코드)
├── product_id (UUID, 기본키)
├── sku (고유)
├── name (전문 검색 인덱스)
├── category (인덱스)
├── price (인덱스)
└── attributes (JSONB GIN 인덱스)

orders (1000개 레코드)
├── order_id (UUID, 기본키)
├── user_id (users 외래키)
├── status (열거형)
├── total_amount
└── shipping_address (JSONB)

order_items
├── order_item_id (UUID, 기본키)
├── order_id (orders 외래키)
├── product_id (products 외래키)
└── subtotal (계산 컬럼)

reviews (2000개 레코드)
├── review_id (UUID, 기본키)
├── product_id (products 외래키)
├── user_id (users 외래키)
└── rating (1-5)
```

## 인덱스 타입 설명

### 1. B-tree 인덱스 (기본)
```sql
CREATE INDEX idx_users_email ON users(email);
```
- **용도**: 등호(=) 및 범위 검색(<, >, BETWEEN)
- **예제**: 이메일 검색, 가격 범위 검색

### 2. GIN 인덱스 (JSONB)
```sql
CREATE INDEX idx_users_preferences ON users USING GIN (preferences);
```
- **용도**: JSONB, 배열, 전문 검색
- **예제**: JSON 필드 검색

### 3. GIN 트라이그램 인덱스
```sql
CREATE INDEX idx_products_name_trgm ON products USING GIN (name gin_trgm_ops);
```
- **용도**: LIKE, ILIKE 패턴 검색
- **예제**: 제품명 부분 검색

### 4. 복합 인덱스
```sql
CREATE INDEX idx_orders_user_status ON orders(user_id, status);
```
- **용도**: 여러 컬럼 동시 검색
- **주의**: 컬럼 순서가 중요함

### 5. 부분 인덱스
```sql
CREATE INDEX idx_orders_pending ON orders(created_at) WHERE status = 'pending';
```
- **용도**: 특정 조건의 데이터만 인덱싱
- **장점**: 인덱스 크기 감소, 성능 향상

### 6. 표현식 인덱스
```sql
CREATE INDEX idx_users_lower_username ON users(LOWER(username));
```
- **용도**: 함수 또는 표현식 결과 인덱싱
- **예제**: 대소문자 구분 없는 검색

## 트리거 설명

### 1. 자동 업데이트 타임스탬프
```sql
CREATE TRIGGER update_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();
```
**기능**: 레코드가 수정될 때마다 `updated_at` 필드를 현재 시간으로 자동 업데이트

### 2. 감사 로그
```sql
CREATE TRIGGER audit_users
    AFTER INSERT OR UPDATE OR DELETE ON users
    FOR EACH ROW
    EXECUTE FUNCTION audit_trigger_function();
```
**기능**: 모든 데이터 변경사항을 `audit_log` 테이블에 자동 기록

### 3. 재고 검증
```sql
CREATE TRIGGER check_stock_before_order
    BEFORE INSERT ON order_items
    FOR EACH ROW
    EXECUTE FUNCTION check_product_stock();
```
**기능**: 주문 시 재고가 충분한지 확인하고, 부족하면 예외 발생

### 4. 주문 상태 타임스탬프
```sql
CREATE TRIGGER order_status_timestamp
    BEFORE UPDATE ON orders
    FOR EACH ROW
    EXECUTE FUNCTION update_order_timestamps();
```
**기능**: 주문 상태가 변경될 때 `shipped_at`, `delivered_at` 자동 설정

## 저장 프로시저 사용법

### 1. 주문 생성
```sql
DO $$
DECLARE
    new_order_id UUID;
BEGIN
    CALL create_order(
        '사용자UUID'::UUID,
        '[{"product_id":"제품UUID","quantity":2}]'::JSONB,
        '{"street":"서울시 강남구","city":"Seoul"}'::JSONB,
        new_order_id
    );
    RAISE NOTICE '생성된 주문 ID: %', new_order_id;
END $$;
```

### 2. 제품 통계 업데이트
```sql
CALL update_product_statistics();

-- 결과 확인
SELECT * FROM product_statistics ORDER BY total_revenue DESC LIMIT 10;
```

### 3. 사용자 주문 내역 조회
```sql
SELECT * FROM get_user_order_history('사용자UUID'::UUID);
```

### 4. 제품 검색
```sql
-- 노트북 검색, 가격 범위 500-2000
SELECT * FROM search_products('노트북', NULL, 500, 2000);
```

## 쿼리 최적화 예제

### 1. 윈도우 함수
```sql
-- 카테고리별 가격 순위
SELECT
    name,
    category,
    price,
    RANK() OVER (PARTITION BY category ORDER BY price DESC) as rank
FROM products
WHERE category IS NOT NULL;
```

### 2. CTE (공통 테이블 표현식)
```sql
-- 상위 고객 조회
WITH top_customers AS (
    SELECT
        user_id,
        SUM(total_amount) as total_spent
    FROM orders
    WHERE status = 'delivered'
    GROUP BY user_id
    ORDER BY total_spent DESC
    LIMIT 10
)
SELECT
    u.username,
    u.email,
    tc.total_spent
FROM users u
JOIN top_customers tc ON u.user_id = tc.user_id;
```

### 3. JSONB 쿼리
```sql
-- 다크 테마 사용자 찾기
SELECT username, email
FROM users
WHERE preferences @> '{"theme": "dark"}';

-- JSON 필드 추출
SELECT
    username,
    preferences->>'language' as language,
    preferences->>'theme' as theme
FROM users
WHERE preferences IS NOT NULL;
```

### 4. 전문 검색
```sql
-- 제품명 검색 (랭킹 포함)
SELECT
    name,
    price,
    ts_rank(
        to_tsvector('english', name),
        to_tsquery('english', 'laptop | notebook')
    ) as relevance
FROM products
WHERE to_tsvector('english', name) @@
      to_tsquery('english', 'laptop | notebook')
ORDER BY relevance DESC;
```

### 5. 집계 쿼리
```sql
-- 카테고리별 매출 통계
SELECT
    p.category,
    COUNT(DISTINCT o.order_id) as 주문수,
    SUM(oi.quantity) as 판매수량,
    SUM(oi.subtotal) as 총매출,
    AVG(oi.unit_price) as 평균가격
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.status = 'delivered'
GROUP BY p.category
ORDER BY 총매출 DESC;
```

## 성능 모니터링

### 1. 인덱스 사용 확인
```sql
SELECT
    schemaname,
    tablename,
    indexname,
    idx_scan as 인덱스스캔횟수,
    idx_tup_read as 읽은튜플수
FROM pg_stat_user_indexes
WHERE schemaname = 'public'
ORDER BY idx_scan DESC;
```

### 2. 느린 쿼리 찾기
```sql
SELECT
    query as 쿼리,
    calls as 실행횟수,
    mean_exec_time as 평균실행시간,
    max_exec_time as 최대실행시간
FROM pg_stat_statements
ORDER BY mean_exec_time DESC
LIMIT 10;
```

### 3. 캐시 적중률
```sql
SELECT
    schemaname,
    tablename,
    heap_blks_hit as 캐시히트,
    heap_blks_read as 디스크읽기,
    ROUND(
        100.0 * heap_blks_hit / NULLIF(heap_blks_hit + heap_blks_read, 0),
        2
    ) as 캐시적중률
FROM pg_statio_user_tables
WHERE schemaname = 'public';
```

### 4. 테이블 크기 확인
```sql
SELECT
    tablename as 테이블명,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) as 전체크기,
    pg_size_pretty(pg_relation_size(schemaname||'.'||tablename)) as 테이블크기,
    pg_size_pretty(
        pg_total_relation_size(schemaname||'.'||tablename) -
        pg_relation_size(schemaname||'.'||tablename)
    ) as 인덱스크기
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;
```

## 백업 및 복원

### 백업
```bash
# 전체 백업
./scripts/backup.sh

# 스키마만 백업
docker exec postgres-advanced pg_dump -U postgres -d education_db -s > schema.sql

# 특정 테이블 백업
docker exec postgres-advanced pg_dump -U postgres -d education_db -t users > users.sql
```

### 복원
```bash
# 백업에서 복원
./scripts/restore.sh backups/full_backup_20250119_120000.sql

# 특정 테이블 복원
docker exec -i postgres-advanced psql -U postgres -d education_db < users.sql
```

## 성능 벤치마크

```bash
docker exec -it postgres-advanced psql -U postgres -d education_db \
    -f /benchmarks/performance-test.sql
```

**테스트 항목**:
- 인덱스 스캔 vs 순차 스캔 비교
- JOIN 성능 분석
- 집계 쿼리 속도
- JSONB 연산 성능
- 전문 검색 성능

## 연결 풀링 설정

PostgreSQL 설정 (`config/postgresql.conf`):
```
max_connections = 200           # 최대 연결 수
shared_buffers = 256MB         # 공유 버퍼 크기
effective_cache_size = 1GB     # 캐시 크기
work_mem = 16MB                # 작업 메모리
```

**프로덕션 환경**: PgBouncer 또는 pgpool-II 사용 권장

## 모범 사례

1. **외래키와 자주 검색되는 컬럼에는 항상 인덱스 생성**
2. **EXPLAIN ANALYZE로 쿼리 플랜 확인**
3. **정기적인 VACUUM과 ANALYZE 실행**
4. **pg_stat_statements로 느린 쿼리 모니터링**
5. **트래픽이 많은 애플리케이션에서는 연결 풀링 사용**
6. **대용량 테이블(1000만 행 이상)은 파티셔닝**
7. **적절한 데이터 타입 사용** (UUID vs BIGINT)

## 자주 발생하는 문제

### 느린 쿼리
**원인**: 인덱스 부족, 통계 정보 오래됨
**해결**:
```sql
-- 인덱스 확인
SELECT * FROM pg_stat_user_indexes WHERE idx_scan = 0;

-- 통계 업데이트
ANALYZE 테이블명;
```

### 디스크 공간 증가
**원인**: 테이블 bloat, 오래된 데이터
**해결**:
```sql
-- Vacuum 실행
VACUUM FULL 테이블명;

-- Bloat 확인
SELECT * FROM pg_stat_user_tables;
```

### 연결 제한 도달
**원인**: 연결이 닫히지 않음
**해결**: 연결 풀링 사용 또는 `max_connections` 증가

## 참고 자료

- [PostgreSQL 공식 문서](https://www.postgresql.org/docs/)
- [영문 문서](./README.md)
- [쿼리 최적화 가이드](./docs/query-optimization.md)
