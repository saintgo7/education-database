# TimescaleDB 시계열 (TimescaleDB Time-Series)

한국어 문서 | [English Document](./README.md)

## 개요

TimescaleDB 시계열 모듈은 시계열 데이터 저장 및 분석에 대한 400개의 예제를 제공합니다.

## 예제 범위

### 기본 (Level 1: Examples 1-50)
- 하이퍼테이블 생성
- 데이터 삽입 및 조회
- 기본 집계
- 시간 기반 쿼리

### 중급 (Level 2: Examples 51-200)
- 연속 집계 (Continuous Aggregates)
- 압축 정책
- 보존 정책
- 갭 채우기

### 고급 (Level 3: Examples 201-400)
- **하이퍼테이블 최적화 (201-225)**
  - 다차원 파티셔닝
  - 청크 설정 튜닝
  - 통계 갱신

- **시계열 분석 (226-275)**
  - 트렌드 분석
  - 계절성 분석
  - 이동 평균
  - 이상 탐지

- **성능 최적화 (276-300)**
  - 압축 효율
  - 인덱싱 전략
  - 메모리 관리

- **실시간 처리 (301-400)**
  - 실시간 알림
  - 스트리밍 데이터
  - 대시보드 쿼리

## 빠른 시작

```bash
cd timescaledb-timeseries
docker-compose up -d

psql -U postgres -d education_db
```

## 주요 기능

### 하이퍼테이블
```sql
-- 하이퍼테이블 생성
SELECT create_hypertable('metrics', 'time');

-- 다차원 파티셔닝
SELECT add_dimension('metrics', 'sensor_id', number_partitions => 32);
```

### 연속 집계
```sql
-- 실시간 집계
CREATE MATERIALIZED VIEW metrics_1h
WITH (timescaledb.continuous)
AS
    SELECT
        TIME_BUCKET('1 hour', time) AS time_bucket,
        sensor_id,
        AVG(value) AS avg_value
    FROM metrics
    GROUP BY 1, 2;
```

### 이상 탐지
```sql
-- Z-score 기반 이상 탐지
WITH stats AS (
    SELECT sensor_id,
           AVG(value) AS mean,
           STDDEV(value) AS std
    FROM metrics
    GROUP BY sensor_id
)
SELECT m.time, m.sensor_id,
       ABS((m.value - s.mean) / s.std) AS z_score
FROM metrics m
JOIN stats s ON m.sensor_id = s.sensor_id
WHERE ABS((m.value - s.mean) / s.std) > 3;
```

## 자주 묻는 질문

### Q: 얼마나 많은 데이터를 저장할 수 있나요?
**A:** 디스크 용량에 제한됩니다. 압축 정책으로 저장공간을 절약할 수 있습니다.

### Q: 쿼리 성능은?
**A:** TimescaleDB는 시계열 쿼리에 최적화되어 있어 매우 빠릅니다.

---

**마지막 업데이트:** 2024년 11월 18일
