# Redis 캐싱 (Redis Caching)

한국어 문서 | [English Document](./README.md)

## 개요

Redis 캐싱 모듈은 인메모리 데이터 구조 저장소의 다양한 활용법과 패턴에 대한 400개의 예제를 제공합니다.

## 예제 범위

### 기본 (Level 1: Examples 1-50)
- 기본 데이터 구조 (String, Hash, List, Set)
- 만료 정책 (Expiration)
- 기본 캐싱 패턴
- 카운터 및 레이트 리미팅

### 중급 (Level 2: Examples 51-200)
- 정렬된 세트 (Sorted Sets)
- Pub/Sub 패턴
- 스트림 (Streams)
- 고급 캐싱 전략
- 분산 잠금

### 고급 (Level 3: Examples 201-400)
- **지역 기반 처리 (201-225)**
  - 지역 좌표 저장 및 검색
  - 반경 검색
  - 거리 계산
  - 배달 경로 최적화

- **클러스터링 (226-250)**
  - 클러스터 노드 모니터링
  - 캐시 일관성
  - 분산 잠금 (Redlock)
  - 락 해제 및 관리

- **스트림 처리 (251-275)**
  - 이벤트 스트림
  - 스트림 읽기
  - 컨슈머 그룹
  - 펜딩 항목 관리

- **확률 데이터 구조 (276-300)**
  - HyperLogLog (고유 값 카운팅)
  - 블룸 필터
  - 근사 분위수

- **캐시 패턴 (301-350)**
  - Write-Through
  - Write-Behind
  - Cache-Aside
  - TTL 전략

## 파일 구조

```
redis-caching/
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
cd redis-caching/scripts
npm install
```

### 2. Redis 실행 (Docker)

```bash
docker-compose up -d

# 또는 로컬 Redis 실행
redis-server
```

### 3. 예제 실행

```bash
# 기본 예제
node runnable-examples.js

# 고급 예제
node examples-201-400.js

# Redis CLI로 대화형 테스트
redis-cli
```

## 주요 학습 주제

### 기본 데이터 구조

#### 1. String (문자열)
```javascript
// 기본 저장 및 조회
await client.set('key', 'value');
const value = await client.get('key');

// 카운터
await client.incr('counter');
await client.incrBy('counter', 5);

// 만료 설정
await client.set('session:123', 'data', { EX: 3600 });
```

#### 2. Hash (해시)
```javascript
// 사용자 정보 저장
await client.hSet('user:1', {
    email: 'user@example.com',
    name: 'John',
    age: 30
});

// 특정 필드 조회
const email = await client.hGet('user:1', 'email');
const allData = await client.hGetAll('user:1');
```

#### 3. List (리스트)
```javascript
// 큐 구현
await client.rPush('job:queue', 'job1', 'job2');
const job = await client.lPop('job:queue');

// 최근 항목 추적
await client.lPush('recent:views', 'product123');
const recent = await client.lRange('recent:views', 0, 9);
```

#### 4. Set (세트)
```javascript
// 고유 값 저장
await client.sAdd('tags:article1', 'python', 'database', 'redis');

// 공통 태그 찾기
const commonTags = await client.sInter('tags:article1', 'tags:article2');
```

#### 5. Sorted Set (정렬된 세트)
```javascript
// 리더보드 구현
await client.zAdd('leaderboard', { score: 100, member: 'user1' });
await client.zAdd('leaderboard', { score: 85, member: 'user2' });

// 상위 10명 조회
const topUsers = await client.zRange('leaderboard', -10, -1, { REV: true });
```

### 캐싱 패턴

#### 1. Cache-Aside (Look-Aside)
```javascript
async function getUser(userId) {
    // 캐시 확인
    let user = await client.get(`user:${userId}`);

    if (!user) {
        // 캐시 미스: DB에서 조회
        user = await db.getUser(userId);

        // 캐시에 저장
        await client.set(`user:${userId}`, JSON.stringify(user), { EX: 3600 });
    }

    return JSON.parse(user);
}
```

#### 2. Write-Through
```javascript
async function updateUser(userId, data) {
    // 캐시와 DB에 동시에 쓰기
    await Promise.all([
        client.set(`user:${userId}`, JSON.stringify(data), { EX: 3600 }),
        db.updateUser(userId, data)
    ]);
}
```

#### 3. Write-Behind
```javascript
async function updateUserWithDelay(userId, data) {
    // 캐시에 즉시 쓰기
    await client.set(`user:${userId}`, JSON.stringify(data), { EX: 3600 });

    // DB 쓰기는 비동기로 처리
    await client.rPush('dirty:queue', JSON.stringify({ userId, data }));
}
```

### 분산 잠금 (Distributed Lock)

```javascript
async function acquireLock(key, timeout = 5000) {
    const lockValue = Math.random().toString();
    const acquired = await client.set(
        `lock:${key}`,
        lockValue,
        { EX: timeout / 1000, NX: true }
    );

    return { acquired: !!acquired, value: lockValue };
}

async function releaseLock(key, value) {
    const script = `
        if redis.call("get", KEYS[1]) == ARGV[1] then
            return redis.call("del", KEYS[1])
        else
            return 0
        end
    `;

    await client.eval(script, { keys: [key], arguments: [value] });
}
```

### 지역 기반 기능 (Geospatial)

```javascript
// 도시 좌표 저장
await client.geoAdd('cities', {
    longitude: 126.9784,
    latitude: 37.5665,
    member: 'Seoul'
});

// 반경 검색
const nearby = await client.geoRadius('cities', {
    longitude: 126.9784,
    latitude: 37.5665,
    radius: 1000,
    unit: 'km'
});

// 거리 계산
const distance = await client.geoDist('cities', 'Seoul', 'Tokyo', 'km');
```

### Pub/Sub (발행-구독)

```javascript
// 구독자
const subscriber = redis.createClient();
subscriber.on('message', (channel, message) => {
    console.log(`채널 ${channel}: ${message}`);
});
await subscriber.subscribe('notifications');

// 발행자
const publisher = redis.createClient();
await publisher.publish('notifications', 'New message');
```

## 성능 최적화 팁

### 1. 메모리 관리
```bash
# Redis 메모리 정책 설정
maxmemory 256mb
maxmemory-policy allkeys-lru  # LRU 정책
```

### 2. 연결 풀링
```javascript
const redis = require('redis');
const pool = redis.createPool({
    host: 'localhost',
    port: 6379,
    max: 10  // 최대 연결 수
});
```

### 3. 파이프라인 (배치 연산)
```javascript
const pipeline = client.multi();
for (let i = 0; i < 1000; i++) {
    pipeline.set(`key:${i}`, `value:${i}`);
}
const results = await pipeline.exec();
```

## 사용 사례

### 1. 세션 저장소
```javascript
// 사용자 세션 저장
await client.set(
    `session:${sessionId}`,
    JSON.stringify(sessionData),
    { EX: 1800 }  // 30분 만료
);
```

### 2. 실시간 분석
```javascript
// 일일 방문자 수
await client.incr('analytics:visits:today');

// 시간대별 집계
const hour = new Date().getHours();
await client.incr(`analytics:visits:hour:${hour}`);
```

### 3. 레이트 리미팅
```javascript
async function isRateLimited(userId, limit = 100, window = 3600) {
    const key = `ratelimit:${userId}`;
    const count = await client.incr(key);

    if (count === 1) {
        await client.expire(key, window);
    }

    return count > limit;
}
```

## 자주 묻는 질문 (FAQ)

### Q: Redis는 데이터베이스를 대체할 수 있나요?
**A:** 아닙니다. Redis는 메모리 기반이므로 영구 저장소로 부적합합니다. 캐시나 세션 저장소로 사용하세요.

### Q: 데이터 손실이 발생하나요?
**A:** 예. Redis는 메모리 기반이므로 서버 재시작 시 데이터가 손실됩니다. RDB나 AOF를 활성화하면 지속성을 확보할 수 있습니다.

### Q: 어떤 데이터 구조를 사용해야 하나요?
**A:** 사용 사례에 따라: 캐싱→String, 사용자 정보→Hash, 큐→List, 고유값→Set, 순위→Sorted Set

## 추천 학습 순서

1. **기본 개념** (1-50): 데이터 구조 및 기본 연산
2. **고급 자료구조** (51-150): Sorted Sets, Streams, Pub/Sub
3. **캐싱 패턴** (151-200): 실제 캐싱 전략
4. **엔터프라이즈 패턴** (201-400): 분산 시스템, 지역 기반 기능

## 관련 리소스

- [Redis 공식 문서](https://redis.io/documentation)
- [Redis 명령어 참조](https://redis.io/commands)
- [Redis 클러스터](https://redis.io/docs/management/clustering/)

## 라이선스

이 모듈은 MIT 라이선스 아래에 공개됩니다.

---

**마지막 업데이트:** 2024년 11월 18일
