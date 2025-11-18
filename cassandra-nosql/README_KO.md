# Cassandra NoSQL (Cassandra NoSQL)

한국어 문서 | [English Document](./README.md)

## 개요

Cassandra NoSQL 모듈은 분산 NoSQL 데이터베이스의 설계, 최적화, 및 운영 패턴에 대한 400개의 예제를 제공합니다.

## 예제 범위

### 기본 (Level 1: Examples 1-50)
- 키스페이스 및 테이블 생성
- 기본 CQL 쿼리
- 데이터 모델링
- 인덱싱 기초

### 중급 (Level 2: Examples 51-200)
- 고급 데이터 모델링
- 복합 파티션 키
- 물리화 뷰
- 배치 연산

### 고급 (Level 3: Examples 201-400)
- **고급 모델링 (201-225)**
  - 타임시리즈 데이터 모델
  - 역색인 테이블
  - 중첩 집계

- **성능 최적화 (226-300)**
  - 압축 옵션
  - 캐시 설정
  - 쿼리 최적화

- **고가용성 (301-400)**
  - 복제 전략
  - 장애 조치
  - 데이터 일관성

## 빠른 시작

```bash
cd cassandra-nosql
docker-compose up -d

# CQL 셸 연결
cqlsh localhost 9042
```

## 주요 개념

### 데이터 모델링
```cql
-- 타임시리즈 모델
CREATE TABLE metrics (
    sensor_id UUID,
    timestamp BIGINT,
    metric_type TEXT,
    value DOUBLE,
    PRIMARY KEY ((sensor_id, metric_type), timestamp)
) WITH CLUSTERING ORDER BY (timestamp DESC);
```

### 확장성
- 수평 확장 (Horizontal Scaling)
- 선형 성능 향상
- 자동 리밸런싱

## 자주 묻는 질문

### Q: 일관성과 성능의 트레이드오프는?
**A:** Cassandra는 최종 일관성을 선택합니다. 정족수(Quorum) 설정으로 조정할 수 있습니다.

---

**마지막 업데이트:** 2024년 11월 18일
