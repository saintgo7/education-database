# 데이터베이스 테스팅 (Database Testing)

한국어 문서 | [English Document](./README.md)

## 개요

Database Testing 모듈은 포괄적인 데이터베이스 테스팅 전략과 400개의 실용적인 테스트 예제를 제공합니다.

## 예제 범위

### 기본 (Level 1: Examples 1-50)
- 단위 테스트 기초
- 트랜잭션 테스트
- 제약조건 검증
- 기본 어설션

### 중급 (Level 2: Examples 51-200)
- 통합 테스트
- 데이터 일관성 검증
- 성능 테스트
- 복잡한 JOIN 테스트

### 고급 (Level 3: Examples 201-400)
- **단위 테스트 고급 (201-225)**
  - 트랜잭션 롤백 테스트
  - 제약조건 위반 테스트
  - 외래키 검증
  - 트리거 테스트

- **통합 테스트 (226-250)**
  - 멀티테이블 트랜잭션
  - 데이터 마이그레이션 검증
  - 복제 테스트

- **성능 테스트 (251-275)**
  - 쿼리 벤치마크
  - 배치 연산 성능
  - 인덱스 효율성

- **데이터 품질 (276-300)**
  - NULL 값 검증
  - 데이터 범위 검증
  - 비즈니스 로직 검증

- **결함 주입 (301-325)**
  - 연결 끊김 시뮬레이션
  - 데드락 테스트
  - 타임아웃 처리

- **회귀 테스트 (326-400)**
  - 이전 버그 회귀 방지
  - 테스트 유틸리티
  - 커스텀 어설션

## 빠른 시작

```bash
cd database-testing/scripts
npm install

# 기본 테스트
npm test

# 성능 테스트
npm run benchmark

# 커버리지 확인
npm run coverage
```

## 테스팅 전략

### 1. 단위 테스트
```javascript
// 트랜잭션 롤백 테스트
test('Transaction should rollback on error', async () => {
    try {
        await db.transaction(async (trx) => {
            await trx('users').insert({ email: 'test@example.com' });
            throw new Error('Test rollback');
        });
    } catch (error) {
        // Transaction rolled back
    }

    const count = await db('users').where({ email: 'test@example.com' }).count();
    expect(count[0]['count(*)']).toBe(0);
});
```

### 2. 통합 테스트
```javascript
// 멀티테이블 트랜잭션 테스트
test('Multi-table transaction should maintain consistency', async () => {
    const trx = await db.transaction();

    try {
        const [userId] = await trx('users').insert({ email: 'user@example.com' });
        const [orderId] = await trx('orders').insert({ userId, amount: 99.99 });

        expect(userId).toBeGreaterThan(0);
        expect(orderId).toBeGreaterThan(0);

        await trx.commit();
    } catch (error) {
        await trx.rollback();
        throw error;
    }
});
```

### 3. 성능 테스트
```javascript
// 쿼리 벤치마크
async function benchmarkQuery(db, query, iterations = 1000) {
    const startTime = Date.now();

    for (let i = 0; i < iterations; i++) {
        await query();
    }

    const avgTime = (Date.now() - startTime) / iterations;
    expect(avgTime).toBeLessThan(50); // 50ms 미만
}
```

### 4. 데이터 품질 검증
```javascript
// NULL 값 검증
test('Required fields should not be NULL', async () => {
    const invalidRecords = await db('users')
        .whereNull('email')
        .orWhereNull('name');

    expect(invalidRecords.length).toBe(0);
});
```

## 테스트 팩토리 패턴

```javascript
// 테스트 데이터 생성
const factory = {
    user: async (overrides = {}) => {
        const defaults = { email: 'user@test.com', name: 'Test User' };
        return db('users').insert({ ...defaults, ...overrides });
    },

    order: async (userId, overrides = {}) => {
        const defaults = { user_id: userId, amount: 99.99 };
        return db('orders').insert({ ...defaults, ...overrides });
    }
};

// 테스트 정리
async function cleanup() {
    await db('orders').del();
    await db('users').del();
}
```

## CI/CD 통합

```yaml
# GitHub Actions 예제
name: Database Tests
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    services:
      postgres:
        image: postgres:14
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
    steps:
      - uses: actions/checkout@v2
      - run: npm install
      - run: npm test
      - run: npm run coverage
```

## 자주 묻는 질문

### Q: 테스트 데이터베이스는 분리해야 하나요?
**A:** 예. 프로덕션 데이터 보호를 위해 항상 분리된 테스트 DB를 사용하세요.

### Q: 테스트 속도를 높이려면?
**A:** 트랜잭션 롤백, 병렬 테스트 실행, 필요한 데이터만 삽입하세요.

### Q: 성능 테스트 기준은?
**A:** 프로젝트 요구사항에 따라 설정하되, 최소한 평균 응답 시간을 추적하세요.

## 테스트 체크리스트

- [ ] 모든 제약조건 검증
- [ ] 트랜잭션 롤백 시나리오
- [ ] 데이터 일관성 검증
- [ ] 성능 기준선 설정
- [ ] 회귀 테스트 추가
- [ ] CI/CD 자동화
- [ ] 커버리지 측정

## 추천 학습 순서

1. **기본 (1-50)**: 단위 테스트 작성
2. **중급 (51-200)**: 통합 테스트 및 성능
3. **고급 (201-400)**: 엔터프라이즈 테스팅 패턴

---

**마지막 업데이트:** 2024년 11월 18일
