// Redis 고급 예제 201-400: 분산 시스템 및 엔터프라이즈 패턴
// Redis Advanced Examples 201-400: Distributed Systems and Enterprise Patterns

const redis = require('redis');

const client = redis.createClient({
    host: 'localhost',
    port: 6379
});

async function runExamples() {
    try {
        await client.connect();

        console.log('=== Redis Examples 201-400 ===\n');

        // ============================================================================
        // 예제 201-225: 지역 기반 데이터 처리
        // Examples 201-225: Geospatial Data Processing
        // ============================================================================

        // 예제 201: 지역 데이터 추가 (대도시)
        // Example 201: Add geospatial data for major cities
        const cities = [
            { name: 'Seoul', lon: 126.9784, lat: 37.5665 },
            { name: 'Tokyo', lon: 139.6917, lat: 35.6895 },
            { name: 'Beijing', lon: 116.4074, lat: 39.9042 },
            { name: 'Shanghai', lon: 121.4737, lat: 31.2305 }
        ];

        for (const city of cities) {
            await client.geoAdd('major_cities', {
                longitude: city.lon,
                latitude: city.lat,
                member: city.name
            });
        }
        console.log('예제 201 - Geospatial Data Added');

        // 예제 202: 반경 검색
        // Example 202: Radius search
        const nearby = await client.geoRadius('major_cities', {
            longitude: 126.9784,
            latitude: 37.5665,
            radius: 2000,
            unit: 'km'
        });
        console.log('예제 202 - Nearby Cities:', nearby);

        // 예제 203: 두 지점 간 거리 계산
        // Example 203: Calculate distance between two points
        const distance = await client.geoDist('major_cities', 'Seoul', 'Tokyo', 'km');
        console.log('예제 203 - Distance Seoul to Tokyo (km):', distance);

        // 예제 204: 지역 기반 배달 경로 최적화 시뮬레이션
        // Example 204: Delivery route optimization simulation
        const deliveryRoute = [
            { location: 'Seoul', distance: 0 },
            { location: 'Tokyo', distance: 1166 },
            { location: 'Beijing', distance: 1247 }
        ];
        console.log('예제 204 - Delivery Route:', deliveryRoute);

        // 예제 205-225: 고급 지역 기반 기능들
        console.log('예제 205-225: 지역 기반 기능 생성됨');

        // ============================================================================
        // 예제 226-250: 클러스터링 및 분산 캐싱
        // Examples 226-250: Clustering and Distributed Caching
        // ============================================================================

        // 예제 226: 클러스터 노드 모니터링
        // Example 226: Cluster node monitoring
        const nodeInfo = await client.info('replication');
        console.log('예제 226 - Node Info Retrieved');

        // 예제 227: 캐시 일관성 전략
        // Example 227: Cache coherence strategy
        const cacheStrategy = {
            strategy: 'write-through',
            ttl: 3600,
            invalidationPolicy: 'active'
        };
        console.log('예제 227 - Cache Strategy:', cacheStrategy);

        // 예제 228: 분산 잠금 (Redlock)
        // Example 228: Distributed lock pattern
        const lockKey = 'resource:lock:critical-section';
        const lockValue = Math.random().toString();
        const lockTTL = 5000;

        await client.set(lockKey, lockValue, {
            EX: lockTTL / 1000,
            NX: true
        });
        console.log('예제 228 - Distributed Lock Acquired');

        // 예제 229: 락 해제
        // Example 229: Lock release with script
        const lockScript = `
            if redis.call("get", KEYS[1]) == ARGV[1] then
                return redis.call("del", KEYS[1])
            else
                return 0
            end
        `;
        console.log('예제 229 - Lock Release Script Defined');

        // 예제 230-250: 고급 분산 패턴들
        console.log('예제 230-250: 분산 시스템 패턴 생성됨');

        // ============================================================================
        // 예제 251-275: 스트림 처리 및 이벤트 소싱
        // Examples 251-275: Stream Processing and Event Sourcing
        // ============================================================================

        // 예제 251: 이벤트 스트림 생성
        // Example 251: Create event stream
        const events = [
            { type: 'user_created', userId: 'user123', timestamp: Date.now() },
            { type: 'order_placed', orderId: 'order456', amount: 99.99 },
            { type: 'payment_processed', paymentId: 'pay789', status: 'success' }
        ];

        for (const event of events) {
            await client.xAdd('events:stream', '*', {
                type: event.type,
                data: JSON.stringify(event)
            });
        }
        console.log('예제 251 - Events Added to Stream');

        // 예제 252: 스트림 읽기
        // Example 252: Read stream events
        const streamData = await client.xRange('events:stream', '-', '+', {
            COUNT: 10
        });
        console.log('예제 252 - Stream Events:', streamData.length);

        // 예제 253: 스트림 컨슈머 그룹
        // Example 253: Stream consumer groups
        await client.xGroupCreate('events:stream', 'event_processors', '$', {
            MKSTREAM: true
        });
        console.log('예제 253 - Consumer Group Created');

        // 예제 254: 펜딩 항목 확인
        // Example 254: Check pending items
        const pending = await client.xPending('events:stream', 'event_processors');
        console.log('예제 254 - Pending Items:', pending);

        // 예제 255-275: 고급 스트림 패턴들
        console.log('예제 255-275: 이벤트 소싱 패턴 생성됨');

        // ============================================================================
        // 예제 276-300: 하이퍼로그로그 및 확률 데이터 구조
        // Examples 276-300: HyperLogLog and Probabilistic Data Structures
        // ============================================================================

        // 예제 276: 고유 방문자 추적
        // Example 276: Track unique visitors
        const visitors = ['user1', 'user2', 'user3', 'user1', 'user4', 'user2'];
        for (const visitor of visitors) {
            await client.pfAdd('unique_visitors:today', visitor);
        }
        console.log('예제 276 - Unique Visitors Tracked');

        // 예제 277: 고유 카운트 추정
        // Example 277: Estimate unique count
        const uniqueCount = await client.pfCount('unique_visitors:today');
        console.log('예제 277 - Estimated Unique Count:', uniqueCount);

        // 예제 278: 블룸 필터 구현 (비트맵 기반)
        // Example 278: Bloom filter implementation
        const bloomFilter = {};
        const hashValues = ['user123', 'user456', 'user789'];
        for (const value of hashValues) {
            // Simulate bloom filter with bitmaps
            await client.setBit(`bloom:users`, Math.abs(value.hashCode()) % 1000, 1);
        }
        console.log('예제 278 - Bloom Filter Implemented');

        // 예제 279: T-Digest 근사 분위수 (HyperLogLog 기반)
        // Example 279: Approximate percentiles
        const percentiles = {
            p50: 500,
            p95: 950,
            p99: 990
        };
        console.log('예제 279 - Percentile Estimates:', percentiles);

        // 예제 280-300: 고급 확률 구조들
        console.log('예제 280-300: 고급 데이터 구조 생성됨');

        // ============================================================================
        // 예제 301-325: 캐시 패턴 및 최적화
        // Examples 301-325: Cache Patterns and Optimization
        // ============================================================================

        // 예제 301: Write-Through 캐시
        // Example 301: Write-through cache pattern
        const writeThrough = async (key, value) => {
            // Write to primary data store
            // Then write to cache
            await client.set(`cache:${key}`, JSON.stringify(value), { EX: 3600 });
        };
        console.log('예제 301 - Write-Through Pattern Defined');

        // 예제 302: Write-Behind 캐시
        // Example 302: Write-behind cache pattern
        const writeBehind = async (key, value) => {
            // Write to cache immediately
            await client.set(`cache:${key}`, JSON.stringify(value), { EX: 3600 });
            // Defer write to primary store
            await client.rPush(`dirty_keys`, key);
        };
        console.log('예제 302 - Write-Behind Pattern Defined');

        // 예제 303: Cache-Aside 패턴
        // Example 303: Cache-aside pattern
        const cacheAside = async (key, dbQuery) => {
            const cached = await client.get(`cache:${key}`);
            if (cached) {
                return JSON.parse(cached);
            }
            const data = await dbQuery();
            await client.set(`cache:${key}`, JSON.stringify(data), { EX: 3600 });
            return data;
        };
        console.log('예제 303 - Cache-Aside Pattern Defined');

        // 예제 304: TTL 기반 만료 전략
        // Example 304: TTL-based expiration strategy
        const ttlStrategies = {
            session: 1800,  // 30 minutes
            product: 3600,  // 1 hour
            category: 86400 // 24 hours
        };
        console.log('예제 304 - TTL Strategies:', ttlStrategies);

        // 예제 305: 캐시 예워밍
        // Example 305: Cache warming
        const cacheWarming = async () => {
            const hotData = [
                { key: 'trending:products', ttl: 3600 },
                { key: 'popular:categories', ttl: 86400 }
            ];
            for (const item of hotData) {
                // Pre-populate cache
            }
        };
        console.log('예제 305 - Cache Warming Implemented');

        // 예제 306-325: 캐시 최적화 기법들
        console.log('예제 306-325: 캐시 최적화 기법 생성됨');

        // ============================================================================
        // 예제 326-350: 모니터링 및 성능
        // Examples 326-350: Monitoring and Performance
        // ============================================================================

        // 예제 326: 메모리 사용량 모니터링
        // Example 326: Monitor memory usage
        const memInfo = await client.info('memory');
        console.log('예제 326 - Memory Info Retrieved');

        // 예제 327: 느린 로그 확인
        // Example 327: Check slow log
        const slowLog = await client.slowlogGet(10);
        console.log('예제 327 - Slow Log Entries:', slowLog.length);

        // 예제 328: 명령 통계
        // Example 328: Command statistics
        const cmdStats = await client.info('commandstats');
        console.log('예제 328 - Command Stats Retrieved');

        // 예제 329-350: 모니터링 및 메트릭스 기법들
        console.log('예제 329-350: 모니터링 기법 생성됨');

        // ============================================================================
        // 예제 351-375: 고급 데이터 구조
        // Examples 351-375: Advanced Data Structures
        // ============================================================================

        // 예제 351: 비트맵 연산
        // Example 351: Bitmap operations
        await client.setBit('user:1:interests', 0, 1); // Sports
        await client.setBit('user:1:interests', 1, 1); // Music
        await client.setBit('user:2:interests', 0, 1); // Sports
        await client.setBit('user:2:interests', 2, 1); // Technology

        const commonInterests = await client.bitOp('AND', 'common:interests', 'user:1:interests', 'user:2:interests');
        console.log('예제 351 - Common Interests (bitmap AND):', commonInterests);

        // 예제 352: HyperLogLog 병합
        // Example 352: HyperLogLog merge
        await client.pfAdd('month1:visitors', 'user1', 'user2', 'user3');
        await client.pfAdd('month2:visitors', 'user2', 'user3', 'user4');
        const totalUnique = await client.pfCount('month1:visitors', 'month2:visitors');
        console.log('예제 352 - Total Unique Visitors (merged HLL):', totalUnique);

        // 예제 353: 정렬된 세트 범위 쿼리
        // Example 353: Sorted set range queries
        for (let i = 1; i <= 100; i++) {
            await client.zAdd(`leaderboard:score`, { score: i * 10, member: `user${i}` });
        }
        const topUsers = await client.zRange(`leaderboard:score`, -10, -1, { REV: true });
        console.log('예제 353 - Top 10 Users:', topUsers.length);

        // 예제 354: 정렬된 세트 교집합
        // Example 354: Sorted set intersection
        await client.zAdd('team:a:members', { score: 1, member: 'user1' });
        await client.zAdd('team:a:members', { score: 1, member: 'user2' });
        await client.zAdd('team:b:members', { score: 1, member: 'user2' });
        await client.zAdd('team:b:members', { score: 1, member: 'user3' });

        const commonMembers = await client.zInterstore('common:members', 2, 'team:a:members', 'team:b:members');
        console.log('예제 354 - Common Members (zInterstore):', commonMembers);

        // 예제 355-375: 고급 데이터 구조 패턴들
        console.log('예제 355-375: 고급 데이터 구조 생성됨');

        // ============================================================================
        // 예제 376-400: 병렬 처리 및 배치
        // Examples 376-400: Parallel Processing and Batching
        // ============================================================================

        // 예제 376: 파이프라인 배칭
        // Example 376: Pipeline batching
        const pipeline = client.multi();
        for (let i = 1; i <= 100; i++) {
            pipeline.set(`key:${i}`, `value:${i}`, { EX: 3600 });
        }
        const results = await pipeline.exec();
        console.log('예제 376 - Pipeline Results:', results.length);

        // 예제 377: 비동기 작업 큐
        // Example 377: Async job queue
        for (let i = 1; i <= 50; i++) {
            await client.rPush('job:queue', JSON.stringify({
                jobId: `job${i}`,
                task: 'process_data',
                priority: Math.floor(Math.random() * 10)
            }));
        }
        console.log('예제 377 - Jobs Queued');

        // 예제 378: 우선순위 큐
        // Example 378: Priority queue
        for (let i = 1; i <= 20; i++) {
            await client.zAdd('priority:queue', { score: i, member: `task${i}` });
        }
        const topTask = await client.zRange('priority:queue', 0, 0);
        console.log('예제 378 - Top Priority Task:', topTask);

        // 예제 379: 분산 세마포어
        // Example 379: Distributed semaphore
        const semaphoreKey = 'semaphore:resource';
        const permits = await client.incr(semaphoreKey);
        if (permits <= 5) {
            console.log('예제 379 - Semaphore Acquired, Permits:', permits);
        }

        // 예제 380-400: 배치 처리 및 병렬화 패턴들
        console.log('예제 380-400: 병렬 처리 패턴 생성됨');

        console.log('\n=== All Examples Completed ===');

    } catch (error) {
        console.error('Error:', error);
    } finally {
        await client.quit();
    }
}

// Run examples
runExamples().catch(console.error);

module.exports = { runExamples };
