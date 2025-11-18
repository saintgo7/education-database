# MongoDB 패턴

MongoDB 스키마 설계 패턴, 집계 파이프라인, 데이터 모델링 모범 사례

## 주요 기능

- **스키마 설계 패턴**: 임베디드, 참조, 하이브리드, 다형성
- **집계 파이프라인**: 15개 이상의 고급 집계 예제
- **데이터 모델링**: 5개 컬렉션에 1000개 이상의 샘플 문서
- **텍스트 검색**: 전문 검색 인덱스 및 쿼리
- **시계열**: 시계열 컬렉션을 이용한 이벤트 추적
- **성능**: 인덱스, 쿼리 최적화, 벤치마크

## 빠른 시작

```bash
# MongoDB 시작
docker-compose up -d

# 샘플 데이터 로드
docker exec -i mongodb-patterns mongosh -u admin -p admin123 education_db < scripts/load-data.js

# Mongo Express 접속 (GUI)
# http://localhost:8081 (admin/admin)

# MongoDB 셸 접속
docker exec -it mongodb-patterns mongosh -u admin -p admin123 education_db
```

## 스키마 패턴

### 1. 임베디드 문서 (Embedded Documents)
**사용 시기**: 일대소 관계 (1:Few), 관련 데이터를 함께 조회하는 경우

```javascript
// 제품에 리뷰 임베딩
{
  "name": "노트북 Pro",
  "price": 1299.99,
  "reviews": [
    { "userId": ObjectId("..."), "rating": 5, "comment": "훌륭해요!" }
  ]
}
```

**장점**: 단일 쿼리로 조회, 성능 향상
**단점**: 문서 크기 제한 (16MB), 배열 크기 관리 필요

### 2. 참조 패턴 (Reference Pattern)
**사용 시기**: 일대다 관계 (1:Many), 독립적으로 관리되는 데이터

```javascript
// 주문이 사용자와 제품 참조
{
  "userId": ObjectId("..."),  // users 컬렉션 참조
  "items": [
    { "productId": ObjectId("...") }  // products 컬렉션 참조
  ]
}
```

**장점**: 데이터 중복 없음, 독립적 업데이트
**단점**: 조인($lookup) 필요, 여러 쿼리 필요할 수 있음

### 3. 확장 참조 (Extended Reference)
**사용 시기**: 자주 조회되는 필드를 비정규화

```javascript
{
  "items": [
    {
      "productId": ObjectId("..."),
      "productName": "노트북 Pro",  // 성능을 위해 비정규화
      "quantity": 1
    }
  ]
}
```

## 집계 파이프라인 예제

### 카테고리별 매출
```javascript
db.orders.aggregate([
  { $unwind: "$items" },
  { $lookup: {
      from: "products",
      localField: "items.productId",
      foreignField: "_id",
      as: "product"
  }},
  { $group: {
      _id: "$product.category",
      totalRevenue: { $sum: "$items.subtotal" }
  }}
])
```

### 고객 생애 가치 (LTV)
```javascript
db.orders.aggregate([
  { $match: { status: "delivered" } },
  { $group: {
      _id: "$userId",
      totalSpent: { $sum: "$total" },
      orderCount: { $sum: 1 }
  }},
  { $sort: { totalSpent: -1 } }
])
```

### 카테고리별 상위 제품
```javascript
db.products.aggregate([
  { $sort: { category: 1, "stats.totalSold": -1 } },
  { $group: {
      _id: "$category",
      products: { $push: "$name" }
  }},
  { $project: {
      top3: { $slice: ["$products", 3] }
  }}
])
```

## 인덱스 전략

```javascript
// 고유 인덱스
db.users.createIndex({ "username": 1 }, { unique: true })

// 복합 인덱스
db.products.createIndex({ "category": 1, "price": -1 })

// 텍스트 인덱스
db.products.createIndex({ "name": "text", "description": "text" })

// 부분 인덱스
db.orders.createIndex(
  { "createdAt": -1 },
  { partialFilterExpression: { "status": "pending" } }
)
```

## 모범 사례

1. **임베딩 사용**: 일대소 관계 (하위 문서 < 100개)
2. **참조 사용**: 일대다 관계, 독립적 데이터
3. **비정규화**: 자주 조회되는 데이터는 복사
4. **인덱스 생성**: 쿼리 필드에 인덱스
5. **배열 크기 제한**: 16MB 문서 크기 제한 주의
6. **프로젝션 사용**: 필요한 필드만 조회
7. **효율적 집계**: $match를 파이프라인 초반에 배치

## 성능 최적화

### 쿼리 분석
```javascript
db.products.find({ category: "Electronics" }).explain("executionStats")
```

### 커버드 쿼리 (Covered Query)
```javascript
// 인덱스만으로 쿼리 수행
db.products.find(
  { category: "Electronics" },
  { name: 1, price: 1, _id: 0 }
)
```

### 집계 파이프라인 최적화
```javascript
db.orders.aggregate([
  { $match: { status: "delivered" } },  // 먼저 필터링
  { $lookup: { ... } },  // 그 다음 조인
  { $sort: { ... } }     // 마지막에 정렬
])
```

## 자주 발생하는 문제

### 문서 크기 제한 초과
**원인**: 임베디드 배열이 너무 큼
**해결**: 참조 패턴으로 변경 또는 서브셋 패턴 사용

### 느린 쿼리
**원인**: 인덱스 부족
**해결**:
```javascript
db.products.createIndex({ category: 1, price: -1 })
```

### $lookup 성능 문제
**원인**: 큰 컬렉션 조인
**해결**: 필요한 필드만 비정규화하여 저장

## 참고 자료

- [MongoDB 공식 문서](https://docs.mongodb.com/)
- [영문 문서](./README.md)
