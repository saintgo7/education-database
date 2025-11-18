# 데이터베이스 마이그레이션 (Database Migrations)

한국어 문서 | [English Document](./README.md)

## 개요

Database Migrations 모듈은 스키마 진화, 무중단 배포, 및 데이터 마이그레이션 패턴에 대한 400개의 예제를 제공합니다.

## 예제 범위

### 기본 (Level 1: Examples 1-50)
- 테이블 생성 및 수정
- 컬럼 추가/제거
- 제약조건 관리
- 인덱스 생성

### 중급 (Level 2: Examples 51-200)
- 데이터 마이그레이션
- 제약조건 추가
- 데이터 타입 변경
- 트리거 설정

### 고급 (Level 3: Examples 201-400)
- **복잡한 스키마 변경 (201-225)**
  - 컬럼 분리/병합
  - 테이블 정규화
  - 파티셔닝 전환

- **인덱스 전략 (226-250)**
  - 온라인 인덱스 생성
  - 인덱스 교체
  - 부분 인덱스

- **데이터 검증 (251-275)**
  - 사전/사후 검증
  - 해시 기반 검증
  - 행 개수 검증

- **안전 메커니즘 (276-400)**
  - 세이브포인트
  - 더블 라이트
  - 섀도우 테이블
  - 감사 로그

## 빠른 시작

```bash
cd database-migrations
psql -U postgres

# 기본 마이그레이션
\i scripts/runnable-examples.sql

# 고급 마이그레이션
\i scripts/examples-201-400.sql
```

## 주요 패턴

### 무중단 배포
```sql
BEGIN;
-- 1. 새 컬럼 추가
ALTER TABLE users ADD COLUMN new_field VARCHAR(100);

-- 2. 데이터 마이그레이션
UPDATE users SET new_field = old_field;

-- 3. 기존 컬럼 제거 (선택사항)
-- ALTER TABLE users DROP COLUMN old_field;

COMMIT;
```

### 더블 라이트 패턴
```sql
-- 1. 새 테이블 생성
CREATE TABLE users_new LIKE users;

-- 2. 이중 쓰기 (애플리케이션에서)
-- INSERT INTO users VALUES (...);
-- INSERT INTO users_new VALUES (...);

-- 3. 기존 데이터 복사
INSERT INTO users_new SELECT * FROM users;

-- 4. 테이블 교체
-- ALTER TABLE users RENAME TO users_old;
-- ALTER TABLE users_new RENAME TO users;
```

## 자주 묻는 질문

### Q: 대용량 테이블 마이그레이션은?
**A:** 배치 처리, CONCURRENTLY 옵션, 다운타임 최소화 전략을 사용하세요.

### Q: 롤백은 어떻게?
**A:** 백업 테이블 보유, 세이브포인트 활용, 트랜잭션 사용으로 안전성을 확보하세요.

---

**마지막 업데이트:** 2024년 11월 18일
