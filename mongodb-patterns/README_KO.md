# MongoDB 패턴 (MongoDB Patterns)

한국어 문서 | [English Document](./README.md)

## 개요

MongoDB 패턴 모듈은 문서 기반 NoSQL 데이터베이스의 다양한 패턴과 최적화 기법에 대한 400개의 예제를 제공합니다.

## 예제 범위

### 기본 (Level 1: Examples 1-50)
- 문서 모델링
- CRUD 연산
- 기본 쿼리 및 필터링
- 인덱싱 기초
- 배열 및 내재 문서

### 중급 (Level 2: Examples 51-200)
- 복잡한 집계 파이프라인
- 대량 작업 (Bulk Operations)
- 트랜잭션
- 변경 스트림 (Change Streams)
- 고급 쿼리 옵션

### 고급 (Level 3: Examples 201-400)
- **고급 집계 (201-225)**
  - 다단계 그룹화 및 집계
  - 윈도우 함수
  - 조건부 집계 (Faceting)
  - 재귀적 조인 (Lookup with Pipeline)

- **분산 처리 (226-250)**
  - 샤드 키 최적화
  - 핫스팟 분석
  - 청크 밸런싱

- **트랜잭션 및 ACID (229-250)**
  - 멀티 도큐먼트 트랜잭션
  - 트랜잭션 격리 수준
  - 롤백 전략

- **변경 스트림 (251-275)**
  - 변경 모니터링
  - 이벤트 필터링
  - 실시간 처리

- **고급 데이터 모델링 (276-300)**
  - 연관 배열 최적화
  - 데이터 정규화 vs 비정규화
  - 스키마 버전 관리
  - 다형성 문서

## 파일 구조

```
mongodb-patterns/
├── scripts/
│   ├── examples-1-50.js            # 기본 예제 (50개)
│   ├── examples-51-200.js          # 중급 예제 (150개)
│   ├── examples-201-400.js         # 고급 예제 (200개)
│   ├── runnable-examples.js        # 실행 가능한 예제
│   └── docker-compose.yml          # Docker 설정
├── README_KO.md                    # 한글 문서
├── README.md                       # 영문 문서
└── package.json                    # Node.js 의존성
```

## 빠른 시작

### 1. 환경 설정

```bash
cd mongodb-patterns/scripts
npm install
```

### 2. MongoDB 실행 (Docker)

```bash
docker-compose up -d

# 또는 로컬 MongoDB 실행
mongod
```

### 3. 예제 실행

```bash
# 기본 예제
node runnable-examples.js

# 고급 예제
node examples-201-400.js
```

## 주요 학습 주제

### 문서 모델링
MongoDB의 유연한 문서 구조를 효과적으로 설계하기

```javascript
// 비정규화 모델 (성능 최적화)
{
    userId: ObjectId(),
    email: 'user@example.com',
    orders: [
        { orderId: ObjectId(), amount: 99.99, date: new Date() }
    ],
    metadata: { totalOrders: 1, totalSpent: 99.99 }
}

// 정규화 모델 (데이터 일관성)
// users 컬렉션
{ _id: ObjectId(), email: 'user@example.com' }

// orders 컬렉션
{ _id: ObjectId(), userId: ObjectId(), amount: 99.99 }
```

### 집계 파이프라인 (Aggregation Pipeline)
복잡한 데이터 변환 및 분석

```javascript
// 월별 매출 집계
db.orders.aggregate([
    { $match: { status: 'completed' } },
    { $group: {
        _id: { $dateToString: { format: '%Y-%m', date: '$date' } },
        totalAmount: { $sum: '$amount' },
        count: { $sum: 1 }
    }},
    { $sort: { _id: -1 } }
])

// 3단계 조인
db.users.aggregate([
    { $lookup: { from: 'orders', localField: '_id', foreignField: 'userId', as: 'orders' } },
    { $unwind: '$orders' },
    { $lookup: { from: 'products', localField: 'orders.productId', foreignField: '_id', as: 'product' } }
])
```

### 트랜잭션 (Transactions)
ACID 속성을 보장하는 멀티 도큐먼트 트랜잭션

```javascript
const session = client.startSession();
try {
    session.startTransaction();

    // 계좌 A에서 출금
    await accountsCollection.updateOne(
        { _id: 'accountA' },
        { $inc: { balance: -100 } },
        { session }
    );

    // 계좌 B에 입금
    await accountsCollection.updateOne(
        { _id: 'accountB' },
        { $inc: { balance: 100 } },
        { session }
    );

    await session.commitTransaction();
} catch (error) {
    await session.abortTransaction();
    throw error;
} finally {
    session.endSession();
}
```

### 변경 스트림 (Change Streams)
실시간 데이터 변경 감지

```javascript
const changeStream = collection.watch([
    { $match: { 'operationType': { $in: ['insert', 'update'] } } }
]);

changeStream.on('change', (change) => {
    console.log('데이터 변경:', change);
    // 외부 시스템에 알림, 캐시 업데이트 등
});
```

## 성능 최적화 팁

### 1. 인덱싱 전략
```javascript
// 복합 인덱스
db.users.createIndex({ email: 1, status: 1 });

// 부분 인덱스 (활성 사용자만)
db.users.createIndex(
    { email: 1 },
    { partialFilterExpression: { status: 'active' } }
);

// 스파스 인덱스
db.users.createIndex(
    { phone: 1 },
    { sparse: true }
);
```

### 2. 쿼리 최적화
```javascript
// 좋은 쿼리: 인덱스 활용
db.orders.find({ userId: ObjectId(), createdAt: { $gte: date } })
    .limit(100)
    .hint({ userId: 1, createdAt: -1 });

// 나쁜 쿼리: ALLOW FILTERING 필요
db.orders.find({ amount: 99.99 }).hint({ $natural: 1 });
```

### 3. 배치 연산
```javascript
const operations = users.map(user => ({
    insertOne: { document: user }
}));

await collection.bulkWrite(operations, { ordered: false });
```

## 데이터 모델링 패턴

### 1. 임베딩 (Embedding)
관련 데이터를 단일 문서에 포함
- **장점**: 쿼리 간단, 원자성 보장
- **단점**: 문서 크기 증가, 중복 가능

### 2. 참조 (Referencing)
다른 문서의 ID를 참조
- **장점**: 정규화, 저장공간 절약
- **단점**: 조인 필요, 여러 쿼리

### 3. 하이브리드
임베딩과 참조의 조합
- **용도**: 대부분의 실제 애플리케이션

## 테스트 및 검증

```bash
# 테스트 데이터 생성
npm run seed

# 테스트 실행
npm test

# 성능 벤치마크
npm run benchmark
```

## 자주 묻는 질문 (FAQ)

### Q: 언제 배열을 사용하고 언제 별도 컬렉션을 사용하나요?
**A:** 배열은 크기가 제한적이고 자주 변경되지 않을 때, 별도 컬렉션은 많은 관련 문서가 있을 때 사용합니다.

### Q: 트랜잭션의 성능 영향은?
**A:** 트랜잭션은 성능 오버헤드가 있으므로, 필요한 경우에만 사용하고 범위를 최소화하세요.

### Q: 모든 문서에 인덱스를 추가해야 하나요?
**A:** 아닙니다. 자주 조회되는 필드에만 선택적으로 추가하세요.

## 추천 학습 순서

1. **기본 개념** (1-50): 문서 모델링 및 CRUD
2. **집계** (51-150): 복잡한 쿼리 작성
3. **트랜잭션** (151-200): 데이터 일관성
4. **고급 패턴** (201-400): 엔터프라이즈 패턴

## 관련 리소스

- [MongoDB 공식 문서](https://docs.mongodb.com/)
- [MongoDB 성능 최적화](https://docs.mongodb.com/manual/administration/analyzing-mongodb-performance/)
- [집계 파이프라인 참조](https://docs.mongodb.com/manual/reference/operator/aggregation/)

## 라이선스

이 모듈은 MIT 라이선스 아래에 공개됩니다.

---

**마지막 업데이트:** 2024년 11월 18일
