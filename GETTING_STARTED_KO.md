# 시작하기 (Getting Started)

한국어 문서 | [English Document](./GETTING_STARTED.md)

## 시스템 요구사항

### 필수 사항
- Docker & Docker Compose 20.10+
- Node.js 14.0+
- npm 또는 yarn
- Git

### 선택 사항 (로컬 설치)
- PostgreSQL 12+
- MongoDB 5.0+
- Redis 6.0+
- Elasticsearch 8.0+

## 빠른 시작 (3분)

### 1. 저장소 클론

```bash
git clone https://github.com/saintgo7/education-database.git
cd education-database
```

### 2. Docker로 모든 데이터베이스 실행

```bash
# 모든 데이터베이스 시작
docker-compose up -d

# 상태 확인
docker-compose ps
```

### 3. Node.js 의존성 설치

```bash
# 각 모듈별 설치
cd postgresql-advanced && npm install && cd ..
cd mongodb-patterns && npm install && cd ..
cd redis-caching && npm install && cd ..
# ... 나머지 모듈들

# 또는 전체 설치 스크립트
bash scripts/install-all.sh
```

### 4. 첫 번째 예제 실행

```bash
# PostgreSQL 예제
psql -U postgres -h localhost -d education_db -f postgresql-advanced/scripts/examples-1-50.sql

# MongoDB 예제
cd mongodb-patterns/scripts
node runnable-examples.js

# Redis 예제
cd redis-caching/scripts
node runnable-examples.js
```

## 학습 경로

### 초급 (Week 1-2)

#### PostgreSQL 기초
```bash
# 문서 읽기
cat postgresql-advanced/README_KO.md

# 기본 예제 실행
psql -U postgres -h localhost -d education_db \
  -f postgresql-advanced/scripts/examples-1-50.sql
```

**주요 학습 항목:**
- 기본 SQL (SELECT, INSERT, UPDATE, DELETE)
- 테이블 설계
- 기본 인덱싱
- 간단한 조인

#### MongoDB 기초
```bash
cd mongodb-patterns/scripts
node runnable-examples.js
```

**주요 학습 항목:**
- 문서 모델
- CRUD 연산
- 기본 쿼리
- 배열 및 내재 문서

#### Redis 기초
```bash
cd redis-caching/scripts
node runnable-examples.js
```

**주요 학습 항목:**
- 기본 데이터 구조 (String, Hash, List)
- 만료 정책
- 기본 캐싱
- 카운터

### 중급 (Week 3-4)

#### PostgreSQL 중급
```bash
psql -U postgres -h localhost -d education_db \
  -f postgresql-advanced/scripts/examples-51-200.sql
```

**주요 학습 항목:**
- CTE 및 윈도우 함수
- JSON/JSONB 처리
- 고급 인덱싱
- 성능 최적화

#### MongoDB 중급
```bash
node examples-51-200.js
```

**주요 학습 항목:**
- 집계 파이프라인
- 트랜잭션
- 변경 스트림
- 고급 모델링

#### 다른 데이터베이스 소개
```bash
# Elasticsearch
bash elasticsearch-search/scripts/runnable-examples.sh

# Redis Streams & Pub/Sub
node redis-caching/scripts/examples-51-200.js | grep -A 20 "예제 251"

# Neo4j 기초
cat neo4j-graph/scripts/runnable-examples.cypher
```

### 고급 (Week 5-6)

#### 종합 고급 학습
```bash
# PostgreSQL 고급
psql -U postgres -h localhost -d education_db \
  -f postgresql-advanced/scripts/examples-201-400.sql

# MongoDB 고급
node examples-201-400.js

# Redis 고급
node examples-201-400.js

# 그래프 알고리즘
bash neo4j-graph/scripts/examples-201-400.cypher

# 시계열 분석
psql -U postgres -h localhost -d timescale_db \
  -f timescaledb-timeseries/scripts/examples-201-400.sql
```

**주요 학습 항목:**
- 엔터프라이즈 패턴
- 대규모 시스템 설계
- 성능 튜닝
- 고가용성

## 모듈별 실행 가이드

### PostgreSQL

```bash
# 데이터베이스 생성
createdb -U postgres education_db

# 예제 실행
psql -U postgres -d education_db -f postgresql-advanced/scripts/examples-1-50.sql
psql -U postgres -d education_db -f postgresql-advanced/scripts/examples-51-200.sql
psql -U postgres -d education_db -f postgresql-advanced/scripts/examples-201-400.sql

# 대화형 쿼리
psql -U postgres -d education_db
```

### MongoDB

```bash
cd mongodb-patterns/scripts

# 의존성 설치
npm install

# 예제 실행
node runnable-examples.js
node examples-51-200.js
node examples-201-400.js

# 직접 쿼리
mongosh
```

### Redis

```bash
cd redis-caching/scripts

# 의존성 설치
npm install

# 예제 실행
node runnable-examples.js
node examples-51-200.js
node examples-201-400.js

# Redis CLI
redis-cli
```

### Elasticsearch

```bash
cd elasticsearch-search/scripts

# Bash 예제 실행
bash runnable-examples.sh
bash examples-51-200.sh
bash examples-201-400.sh

# Kibana 접속
open http://localhost:5601
```

### Neo4j

```bash
cd neo4j-graph

# Neo4j 브라우저
open http://localhost:7687

# Cypher 쿼리 실행
# 브라우저에서 직접 입력하거나:
cat scripts/runnable-examples.cypher
```

### TimescaleDB

```bash
# PostgreSQL과 동일하지만 timescale_db 사용
psql -U postgres -d timescale_db -f timescaledb-timeseries/scripts/examples-1-50.sql
```

## 문제 해결

### Docker 관련

```bash
# Docker 상태 확인
docker-compose ps

# 로그 확인
docker-compose logs postgres
docker-compose logs mongodb
docker-compose logs redis

# 컨테이너 재시작
docker-compose restart postgres
```

### 연결 문제

```bash
# PostgreSQL 연결 테스트
psql -U postgres -h localhost -d postgres -c "SELECT version();"

# MongoDB 연결 테스트
mongosh --eval "db.adminCommand('ping')"

# Redis 연결 테스트
redis-cli ping
```

### 데이터 초기화

```bash
# 모든 데이터 초기화
docker-compose down
docker-compose up -d
bash scripts/init-databases.sh
```

## 성능 최적화

### 로컬 개발 환경 설정

```bash
# PostgreSQL 성능 최적화
export PGPASSWORD="postgres"
psql -U postgres -c "ALTER SYSTEM SET shared_buffers = '256MB';"
psql -U postgres -c "ALTER SYSTEM SET effective_cache_size = '1GB';"

# Docker 리소스 할당
# Docker Desktop: Preferences → Resources
# 메모리: 4GB, CPU: 2 cores 이상 권장
```

### 쿼리 성능 분석

```bash
# PostgreSQL 쿼리 분석
EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM users WHERE email = 'test@example.com';

# MongoDB 쿼리 분석
db.users.find({email: 'test@example.com'}).explain('executionStats')

# Elasticsearch 성능 분석
GET /products/_search?profile=true
```

## 다음 단계

### 1. 기본 개념 마스터
- [ ] 각 데이터베이스의 기본 개념 이해
- [ ] 기본 CRUD 연산 수행
- [ ] 간단한 쿼리 작성

### 2. 고급 기능 학습
- [ ] 복잡한 쿼리 작성
- [ ] 성능 최적화 기법
- [ ] 트랜잭션 및 동시성

### 3. 실제 프로젝트 적용
- [ ] 실제 데이터로 테스트
- [ ] 성능 벤치마킹
- [ ] 프로덕션 배포 준비

### 4. 심화 학습
- [ ] 분산 시스템 패턴
- [ ] 고가용성 아키텍처
- [ ] 모니터링 및 운영

## 추가 자료

- [README 한글 버전](./README_KO.md)
- [각 모듈의 한글 가이드](./README_KO.md#포함된-데이터베이스-모듈)
- [공식 문서](./README_KO.md#관련-리소스)

## 커뮤니티 및 지원

- GitHub Issues: [문제 보고](https://github.com/saintgo7/education-database/issues)
- 토론: [GitHub Discussions](https://github.com/saintgo7/education-database/discussions)
- 이메일: support@education-database.com

---

**마지막 업데이트:** 2024년 11월 18일

**Happy Learning! 🚀**
