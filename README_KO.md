# 교육 데이터베이스 (Education Database)

한국어 문서 | [English Document](./README.md)

## 개요

이 프로젝트는 10개의 주요 데이터베이스 기술에 대한 포괄적인 교육 자료 및 실습 예제를 제공합니다. 각 데이터베이스마다 2,500개 이상의 예제를 포함하고 있어 초급부터 고급 레벨까지 체계적으로 학습할 수 있습니다.

## 포함된 데이터베이스 모듈

### 1. **PostgreSQL 고급 (postgresql-advanced)**
- 범위: 400개 예제 (1-400)
- 주요 주제:
  - 고급 SQL 쿼리 (CTE, 윈도우 함수, JSON/JSONB)
  - 파티셔닝 및 대규모 데이터 관리
  - 성능 최적화 (인덱싱, 병렬 처리)
  - 실시간 데이터 처리
  - 고급 분석 및 리포팅

**예제 구성:**
- `examples-1-50.sql`: 기본부터 중급 (50개)
- `examples-51-200.sql`: 고급 기능 (150개)
- `examples-201-400.sql`: 엔터프라이즈 패턴 (200개)

### 2. **MongoDB 패턴 (mongodb-patterns)**
- 범위: 400개 예제 (1-400)
- 주요 주제:
  - 도큐먼트 모델링
  - 복잡한 집계 파이프라인
  - 트랜잭션 및 ACID 속성
  - 변경 스트림 및 실시간 처리
  - 고급 쿼리 패턴

**예제 구성:**
- `runnable-examples.js`: 실행 가능한 기본 예제 (50개)
- `examples-51-200.js`: 중급 및 고급 예제 (150개)
- `examples-201-400.js`: 엔터프라이즈 패턴 (200개)

### 3. **Redis 캐싱 (redis-caching)**
- 범위: 400개 예제 (1-400)
- 주요 주제:
  - 기본 자료구조 (String, Hash, List, Set, Sorted Set)
  - Pub/Sub 및 스트림
  - 분산 캐싱 패턴
  - 지리적 데이터 처리
  - 고성능 최적화

**예제 구성:**
- `runnable-examples.js`: 기본 예제 (50개)
- `examples-51-200.js`: 고급 기법 (150개)
- `examples-201-400.js`: 엔터프라이즈 패턴 (200개)

### 4. **Elasticsearch 검색 (elasticsearch-search)**
- 범위: 400개 예제 (1-400)
- 주요 주제:
  - 전문 검색 (Full-Text Search)
  - 집계 및 분석
  - 성능 최적화
  - 모니터링 및 관리
  - 머신러닝 통합

**예제 구성:**
- `runnable-examples.sh`: CURL 기반 기본 예제 (50개)
- `examples-51-200.sh`: 고급 검색 기법 (150개)
- `examples-201-400.sh`: 엔터프라이즈 기능 (200개)

### 5. **Cassandra NoSQL (cassandra-nosql)**
- 범위: 400개 예제 (1-400)
- 주요 주제:
  - 분산 데이터 모델링
  - 고가용성 및 확장성
  - 성능 최적화
  - 데이터 일관성
  - 대규모 시스템 패턴

**예제 구성:**
- `runnable-examples.cql`: 기본 CQL 예제 (50개)
- `examples-51-200.cql`: 고급 패턴 (150개)
- `examples-201-400.cql`: 엔터프라이즈 솔루션 (200개)

### 6. **Neo4j 그래프 (neo4j-graph)**
- 범위: 400개 예제 (1-400)
- 주요 주제:
  - 그래프 모델링
  - 경로 찾기 및 알고리즘
  - 커뮤니티 감지
  - 추천 시스템
  - 영향도 분석

**예제 구성:**
- `runnable-examples.cypher`: 기본 Cypher 예제 (50개)
- `examples-51-200.cypher`: 고급 쿼리 (150개)
- `examples-201-400.cypher`: 그래프 알고리즘 (200개)

### 7. **TimescaleDB 시계열 (timescaledb-timeseries)**
- 범위: 400개 예제 (1-400)
- 주요 주제:
  - 시계열 데이터 모델링
  - 하이퍼테이블 최적화
  - 연속 집계 (Continuous Aggregates)
  - 압축 및 보존 정책
  - 시계열 분석

**예제 구성:**
- `runnable-examples.sql`: 기본 예제 (50개)
- `examples-51-200.sql`: 중급 기법 (150개)
- `examples-201-400.sql`: 고급 분석 (200개)

### 8. **데이터베이스 마이그레이션 (database-migrations)**
- 범위: 400개 예제 (1-400)
- 주요 주제:
  - 스키마 진화
  - 무중단 마이그레이션
  - 데이터 검증
  - 안전한 롤백 전략
  - 성능 영향 최소화

**예제 구성:**
- `runnable-examples.sql`: 기본 마이그레이션 (50개)
- `examples-51-200.sql`: 고급 패턴 (150개)
- `examples-201-400.sql`: 엔터프라이즈 전략 (200개)

### 9. **ORM 비교 (orm-comparison)**
- 범위: 400개 예제 (1-400)
- 주요 주제:
  - **Sequelize** (1-67): SQL ORM의 기본과 고급
  - **TypeORM** (68-134): TypeScript 기반 ORM
  - **Prisma** (135-200): 현대적 ORM
  - 성능 비교 및 최적화

**예제 구성:**
- `runnable-examples.js`: 세 ORM의 기본 (50개)
- `examples-51-200.js`: 중급 기법 (150개)
- `examples-201-400.js`: 고급 엔터프라이즈 패턴 (200개)

### 10. **데이터베이스 테스팅 (database-testing)**
- 범위: 400개 예제 (1-400)
- 주요 주제:
  - 단위 테스트 및 통합 테스트
  - 성능 벤치마크
  - 데이터 품질 검증
  - 결함 주입 테스트
  - 회귀 테스트

**예제 구성:**
- `runnable-examples.js`: 기본 테스트 (50개)
- `examples-51-200.js`: 고급 테스팅 (150개)
- `examples-201-400.js`: 엔터프라이즈 테스팅 (200개)

## 전체 예제 구성

```
총 예제 수: 2,500개 이상
├── 1-50: 기본 (각 모듈 50개)
├── 51-200: 중급 (각 모듈 150개)
└── 201-400: 고급 (각 모듈 200개)
```

## 빠른 시작

### 1. PostgreSQL 예제 실행

```bash
# 기본 예제 확인
cat postgresql-advanced/scripts/examples-1-50.sql | head -100

# 고급 예제 실행 (PostgreSQL 설치 필요)
psql -U postgres -d education_db -f postgresql-advanced/scripts/examples-201-400.sql
```

### 2. MongoDB 예제 실행

```bash
# 기본 설정
cd mongodb-patterns/scripts
npm install

# 예제 실행
node runnable-examples.js
node examples-201-400.js
```

### 3. Redis 예제 실행

```bash
# 기본 설정
cd redis-caching/scripts
npm install

# Redis 서버 실행 (별도 터미널)
redis-server

# 예제 실행
node runnable-examples.js
node examples-201-400.js
```

### 4. Elasticsearch 예제 실행

```bash
# Docker로 Elasticsearch 시작
docker run -d -p 9200:9200 docker.elastic.co/elasticsearch/elasticsearch:8.0.0

# 예제 실행
bash elasticsearch-search/scripts/examples-201-400.sh
```

### 5. 다른 데이터베이스

각 모듈의 `README_KO.md` 파일을 참조하여 해당 데이터베이스의 설정 및 실행 방법을 확인하세요.

## 학습 경로

### 초급 (Level 1: Examples 1-50)
- 각 데이터베이스의 기본 개념 이해
- 기본 CRUD 연산
- 간단한 쿼리 작성
- 기본 데이터 구조 학습

### 중급 (Level 2: Examples 51-200)
- 복잡한 쿼리 작성
- 고급 데이터 구조
- 성능 최적화 기초
- 트랜잭션 및 동시성 관리

### 고급 (Level 3: Examples 201-400)
- 엔터프라이즈 패턴
- 대규모 시스템 설계
- 성능 튜닝 및 최적화
- 고가용성 및 장애 복구
- 실시간 처리 및 분석

## 각 예제 파일의 구조

### SQL 기반 (PostgreSQL, TimescaleDB, Cassandra, Database Migrations)
```sql
-- 한국어/영문 설명
-- 예제 번호: 예제 제목

-- 실제 쿼리 또는 DDL 명령어
SELECT ...;
CREATE TABLE ...;
```

### JavaScript/Node.js 기반 (MongoDB, Redis, ORM Comparison, Database Testing)
```javascript
// 한국어/영문 설명
// Example 1: Example Title

// 코드 예제
const example = async () => {
    // 구현
};
```

### Bash/Shell 기반 (Elasticsearch)
```bash
#!/bin/bash

# 한국어/영문 설명
# Example 1: Example Title

# CURL 커맨드 또는 bash 스크립트
curl -X GET "http://localhost:9200/..."
```

### Cypher 기반 (Neo4j)
```cypher
// 한국어/영문 설명
// Example 1: Example Title

// Cypher 쿼리
MATCH (n) RETURN n LIMIT 10;
```

## 실습 방법

### 1. 순차적 학습
1-50 예제부터 시작하여 단계적으로 고급 예제로 진행합니다.

### 2. 개념별 학습
각 모듈 내에서 특정 개념을 먼저 이해한 후 관련 예제들을 집중 학습합니다.

### 3. 프로젝트 기반 학습
여러 데이터베이스를 결합하여 실제 프로젝트에 적용해봅니다.

### 4. 성능 비교
같은 작업을 여러 데이터베이스로 구현하고 성능을 비교합니다.

## 각 모듈별 주요 특징

| 모듈 | 주요 용도 | 학습 시간 | 난이도 |
|------|---------|---------|--------|
| PostgreSQL | OLTP, 트랜잭션 | 40시간 | ⭐⭐⭐ |
| MongoDB | 문서 저장소, NoSQL | 30시간 | ⭐⭐ |
| Redis | 캐싱, 실시간 처리 | 25시간 | ⭐⭐ |
| Elasticsearch | 검색, 로그 분석 | 35시간 | ⭐⭐⭐ |
| Cassandra | 대규모 분산 시스템 | 45시간 | ⭐⭐⭐⭐ |
| Neo4j | 그래프 데이터, 관계분석 | 30시간 | ⭐⭐⭐ |
| TimescaleDB | 시계열 데이터 | 25시간 | ⭐⭐ |
| Migrations | 스키마 관리 | 20시간 | ⭐⭐ |
| ORM Comparison | 애플리케이션 개발 | 35시간 | ⭐⭐⭐ |
| Database Testing | QA 및 테스팅 | 30시간 | ⭐⭐⭐ |

## 요구사항

- Python 3.8+ (선택)
- Node.js 14+ (MongoDB, Redis, ORM, Testing 예제 실행)
- PostgreSQL 12+ (PostgreSQL 예제 실행)
- Docker (데이터베이스 쉽게 실행)

## 환경 설정

### Docker Compose 사용 (권장)

각 모듈 디렉토리에 `docker-compose.yml` 파일이 포함되어 있습니다:

```bash
cd postgresql-advanced
docker-compose up -d

# 또는 모든 데이터베이스 동시 실행
docker-compose -f docker-compose.yml up -d
```

### 로컬 설치

각 모듈의 설치 가이드를 참조하세요:
- [PostgreSQL 설정](./postgresql-advanced/README_KO.md)
- [MongoDB 설정](./mongodb-patterns/README_KO.md)
- [Redis 설정](./redis-caching/README_KO.md)
- 등등...

## 기여 가이드

이 프로젝트에 예제를 추가하거나 개선하려면:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/add-examples`)
3. Commit your changes (`git commit -am 'Add new examples'`)
4. Push to the branch (`git push origin feature/add-examples`)
5. Create a Pull Request

## 라이선스

이 프로젝트는 MIT 라이선스 아래에 공개됩니다.

## 연락처 및 피드백

- 이슈 및 질문: [GitHub Issues](https://github.com/saintgo7/education-database/issues)
- 이메일: support@education-database.com

## 추가 자료

- [PostgreSQL 공식 문서](https://www.postgresql.org/docs/)
- [MongoDB 문서](https://docs.mongodb.com/)
- [Redis 문서](https://redis.io/documentation)
- [Elasticsearch 문서](https://www.elastic.co/guide/index.html)
- [Cassandra 문서](https://cassandra.apache.org/doc/latest/)
- [Neo4j 문서](https://neo4j.com/docs/)
- [TimescaleDB 문서](https://docs.timescaledb.com/)

## 업데이트 기록

### v2.0.0 (2024-11-18)
- ✅ 2,000개의 고급 예제 추가 (201-400)
- ✅ 한글 문서화 완성
- ✅ 모든 10개 데이터베이스 모듈 포함
- ✅ 총 2,500개 이상의 예제

### v1.0.0 (초기 릴리즈)
- 기본 예제 500개 추가 (1-50, 51-200)
- 10개 데이터베이스 모듈 생성

---

**마지막 업데이트:** 2024년 11월 18일
