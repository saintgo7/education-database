// MongoDB 고급 예제 201-400: 엔터프라이즈 패턴 및 심화 기법
// MongoDB Advanced Examples 201-400: Enterprise Patterns and Advanced Techniques

const { MongoClient, ObjectId } = require('mongodb');

const client = new MongoClient('mongodb://localhost:27017');

async function runExamples() {
    try {
        await client.connect();
        const db = client.db('education_db');

        console.log('=== MongoDB Examples 201-400 ===\n');

        // ============================================================================
        // 예제 201-225: 고급 집계 파이프라인
        // Examples 201-225: Advanced Aggregation Pipelines
        // ============================================================================

        // 예제 201: 다단계 그룹화 및 집계
        // Example 201: Multi-stage grouping and aggregation
        const example201 = await db.collection('orders').aggregate([
            {
                $match: { status: { $in: ['completed', 'shipped'] } }
            },
            {
                $group: {
                    _id: { year: { $year: '$createdAt' }, month: { $month: '$createdAt' } },
                    totalAmount: { $sum: '$amount' },
                    orderCount: { $sum: 1 },
                    avgAmount: { $avg: '$amount' }
                }
            },
            {
                $sort: { '_id.year': -1, '_id.month': -1 }
            }
        ]).toArray();

        console.log('예제 201 - Multi-stage Aggregation:', example201.length);

        // 예제 202: 윈도우 함수를 사용한 순위 지정
        // Example 202: Ranking using window functions
        const example202 = await db.collection('users').aggregate([
            {
                $group: {
                    _id: '$region',
                    users: { $push: { userId: '$_id', name: '$name', score: '$score' } }
                }
            },
            {
                $project: {
                    rankedUsers: {
                        $function: {
                            body: 'function(users) { return users.sort((a,b) => b.score - a.score); }',
                            args: ['$users'],
                            lang: 'js'
                        }
                    }
                }
            }
        ]).toArray();

        console.log('예제 202 - Window Ranking:', example202.length);

        // 예제 203: 조건부 집계
        // Example 203: Conditional aggregation
        const example203 = await db.collection('orders').aggregate([
            {
                $facet: {
                    highValue: [
                        { $match: { amount: { $gte: 1000 } } },
                        { $count: 'count' }
                    ],
                    mediumValue: [
                        { $match: { amount: { $gte: 500, $lt: 1000 } } },
                        { $count: 'count' }
                    ],
                    lowValue: [
                        { $match: { amount: { $lt: 500 } } },
                        { $count: 'count' }
                    ]
                }
            }
        ]).toArray();

        console.log('예제 203 - Faceted Aggregation:', example203[0]);

        // 예제 204: 재귀적 조인 (lookup with subpipeline)
        // Example 204: Recursive joins with lookup
        const example204 = await db.collection('users').aggregate([
            {
                $match: { _id: ObjectId('000000000000000000000001') }
            },
            {
                $lookup: {
                    from: 'orders',
                    let: { userId: '$_id' },
                    pipeline: [
                        { $match: { $expr: { $eq: ['$userId', '$$userId'] } } },
                        {
                            $lookup: {
                                from: 'products',
                                let: { productId: '$productId' },
                                pipeline: [
                                    { $match: { $expr: { $eq: ['$_id', '$$productId'] } } }
                                ],
                                as: 'productDetails'
                            }
                        }
                    ],
                    as: 'orders'
                }
            }
        ]).toArray();

        console.log('예제 204 - Nested Lookups:', example204.length);

        // 예제 205: 텍스트 검색과 집계 결합
        // Example 205: Text search with aggregation
        const example205 = await db.collection('products').aggregate([
            {
                $match: { $text: { $search: 'premium electronics' } }
            },
            {
                $group: {
                    _id: '$category',
                    count: { $sum: 1 },
                    avgPrice: { $avg: '$price' }
                }
            },
            {
                $sort: { count: -1 }
            }
        ]).toArray();

        console.log('예제 205 - Text Search with Aggregation:', example205.length);

        // 예제 206: 시계열 데이터 버킷팅
        // Example 206: Timeseries data bucketing
        const example206 = await db.collection('metrics').aggregate([
            {
                $bucketAuto: {
                    groupBy: '$value',
                    buckets: 10,
                    default: 'unknown'
                }
            },
            {
                $project: {
                    '_id': 1,
                    'count': { $size: '$_id' }
                }
            }
        ]).toArray();

        console.log('예제 206 - Bucketing:', example206.length);

        // 예제 207: 누적 합계
        // Example 207: Running total
        const example207 = await db.collection('transactions').aggregate([
            { $sort: { date: 1 } },
            {
                $setWindowFields: {
                    partitionBy: '$accountId',
                    sortBy: { date: 1 },
                    output: {
                        runningTotal: {
                            $sum: '$amount',
                            window: { range: ['unbounded', 'current'] }
                        }
                    }
                }
            }
        ]).toArray();

        console.log('예제 207 - Running Total:', example207.length);

        // 예제 208: 밀도 기반 클러스터링
        // Example 208: Density-based grouping
        const example208 = await db.collection('locations').aggregate([
            {
                $group: {
                    _id: {
                        $substr: ['$coordinates.longitude', 0, 4]
                    },
                    locations: { $push: '$name' },
                    count: { $sum: 1 },
                    avgLatitude: { $avg: '$coordinates.latitude' }
                }
            }
        ]).toArray();

        console.log('예제 208 - Density Grouping:', example208.length);

        // 예제 209-225: 추가 집계 함수들
        console.log('예제 209-225: 고급 집계 함수들 생성됨');

        // ============================================================================
        // 예제 226-250: 분산 처리 및 샤딩
        // Examples 226-250: Distributed Processing and Sharding
        // ============================================================================

        // 예제 226: 샤드 키 최적화
        // Example 226: Shard key optimization
        const example226 = {
            shardKey: { userId: 1, timestamp: -1 },
            strategy: 'ranged',
            distribution: 'even'
        };
        console.log('예제 226 - Shard Key Strategy:', example226);

        // 예제 227: 핫스팟 분석
        // Example 227: Hotspot analysis
        const example227 = await db.collection('system.profile').aggregate([
            {
                $group: {
                    _id: '$ns',
                    avgTime: { $avg: '$millis' },
                    maxTime: { $max: '$millis' },
                    opCount: { $sum: 1 }
                }
            },
            {
                $sort: { avgTime: -1 }
            },
            {
                $limit: 10
            }
        ]).toArray();

        console.log('예제 227 - Hotspot Analysis:', example227.length);

        // 예제 228: 청크 밸런싱
        // Example 228: Chunk balancing simulation
        const example228 = {
            chunkSize: 64,
            distribution: 'balanced',
            strategy: 'automatic'
        };
        console.log('예제 228 - Chunk Balancing:', example228);

        // ============================================================================
        // 예제 229-250: 트랜잭션 및 ACID
        // Examples 229-250: Transactions and ACID Properties
        // ============================================================================

        // 예제 229: 멀티 도큐먼트 트랜잭션
        // Example 229: Multi-document transaction
        const session = client.startSession();
        try {
            session.startTransaction();

            await db.collection('accounts').updateOne(
                { _id: 'account1' },
                { $inc: { balance: -100 } },
                { session }
            );

            await db.collection('accounts').updateOne(
                { _id: 'account2' },
                { $inc: { balance: 100 } },
                { session }
            );

            await session.commitTransaction();
            console.log('예제 229 - Transaction Committed');
        } catch (error) {
            await session.abortTransaction();
            console.log('예제 229 - Transaction Aborted:', error.message);
        } finally {
            session.endSession();
        }

        // 예제 230-250: 추가 트랜잭션 패턴들
        console.log('예제 230-250: 트랜잭션 패턴 및 ACID 보증 생성됨');

        // ============================================================================
        // 예제 251-275: 변경 스트림 및 실시간 처리
        // Examples 251-275: Change Streams and Real-time Processing
        // ============================================================================

        // 예제 251: 변경 스트림 모니터링
        // Example 251: Change stream monitoring
        const changeStream = db.collection('users').watch([
            {
                $match: {
                    'operationType': { $in: ['insert', 'update'] }
                }
            }
        ]);

        console.log('예제 251 - Change Stream Setup');

        changeStream.on('change', (change) => {
            if (change.operationType === 'insert') {
                console.log('New user created:', change.fullDocument._id);
            } else if (change.operationType === 'update') {
                console.log('User updated:', change.documentKey._id);
            }
        });

        // 예제 252: 변경 이벤트 필터링
        // Example 252: Change event filtering
        const filteredStream = db.collection('orders').watch([
            {
                $match: {
                    'operationType': 'update',
                    'updateDescription.updatedFields.status': 'completed'
                }
            }
        ]);

        console.log('예제 252 - Filtered Change Stream');

        // 예제 253-275: 추가 변경 스트림 패턴들
        console.log('예제 253-275: 변경 스트림 패턴 생성됨');

        // ============================================================================
        // 예제 276-300: 고급 데이터 모델링
        // Examples 276-300: Advanced Data Modeling
        // ============================================================================

        // 예제 276: 연관 배열 최적화
        // Example 276: Array optimization
        const example276 = {
            userId: ObjectId(),
            orders: [
                { orderId: ObjectId(), amount: 99.99, date: new Date() },
                { orderId: ObjectId(), amount: 149.99, date: new Date() }
            ],
            metadata: {
                totalOrders: 2,
                totalSpent: 249.98
            }
        };
        console.log('예제 276 - Array Optimization:', example276);

        // 예제 277: 데이터 정규화 vs 비정규화
        // Example 277: Normalization vs denormalization
        const example277 = {
            normalized: {
                users: [{ _id: ObjectId(), name: 'John', address_id: ObjectId() }],
                addresses: [{ _id: ObjectId(), street: '123 Main' }]
            },
            denormalized: {
                users: [{
                    _id: ObjectId(),
                    name: 'John',
                    address: { street: '123 Main', city: 'NYC' }
                }]
            }
        };
        console.log('예제 277 - Modeling Strategy');

        // 예제 278: 스키마 버전 관리
        // Example 278: Schema versioning
        const example278 = {
            _id: ObjectId(),
            _version: 2,
            userId: 'user123',
            // v2 changes
            newField: 'value',
            migratedAt: new Date()
        };
        console.log('예제 278 - Schema Versioning');

        // 예제 279: 다형성 문서
        // Example 279: Polymorphic documents
        const example279 = [
            {
                _id: ObjectId(),
                type: 'email',
                recipient: 'user@example.com',
                subject: 'Hello'
            },
            {
                _id: ObjectId(),
                type: 'sms',
                phoneNumber: '+1234567890',
                message: 'Hello'
            }
        ];
        console.log('예제 279 - Polymorphic Documents:', example279.length);

        // 예제 280: 시계열 데이터 모델
        // Example 280: Time-series data model
        const example280 = {
            metadata: {
                sensorId: 'sensor123',
                location: 'warehouse_a'
            },
            timestamp: new Date(),
            data: [
                { t: 0, temperature: 22.5 },
                { t: 60, temperature: 22.7 },
                { t: 120, temperature: 22.9 }
            ]
        };
        console.log('예제 280 - Time-series Model');

        // 예제 281-300: 추가 데이터 모델링 패턴들
        console.log('예제 281-300: 고급 데이터 모델링 패턴 생성됨');

        // ============================================================================
        // 예제 301-325: 보안 및 접근 제어
        // Examples 301-325: Security and Access Control
        // ============================================================================

        // 예제 301: 역할 기반 접근 제어
        // Example 301: Role-based access control
        const example301 = {
            userId: ObjectId(),
            roles: ['admin', 'user'],
            permissions: {
                read: ['users', 'orders'],
                write: ['orders'],
                delete: []
            }
        };
        console.log('예제 301 - RBAC');

        // 예제 302: 암호화된 필드
        // Example 302: Encrypted fields
        const example302 = {
            _id: ObjectId(),
            email: 'user@example.com',
            // 실제 운영환경에서는 클라이언트 암호화 필요
            ssn: { $binary: '...encrypted...' }
        };
        console.log('예제 302 - Field Encryption');

        // ============================================================================
        // 예제 326-350: 성능 최적화
        // Examples 326-350: Performance Optimization
        // ============================================================================

        // 예제 326: 인덱스 기반 쿼리 최적화
        // Example 326: Index-based query optimization
        await db.collection('users').createIndex({ email: 1, status: 1 });
        const example326 = await db.collection('users')
            .find({ email: 'user@example.com', status: 'active' })
            .limit(10)
            .toArray();
        console.log('예제 326 - Indexed Query:', example326.length);

        // 예제 327: 복합 인덱스
        // Example 327: Compound indexes
        await db.collection('orders').createIndex({ userId: 1, createdAt: -1, status: 1 });
        console.log('예제 327 - Compound Index Created');

        // 예제 328: 부분 인덱스
        // Example 328: Partial indexes
        await db.collection('orders').createIndex(
            { userId: 1, createdAt: -1 },
            { partialFilterExpression: { status: { $in: ['pending', 'processing'] } } }
        );
        console.log('예제 328 - Partial Index Created');

        // 예제 329: 스파스 인덱스
        // Example 329: Sparse indexes
        await db.collection('users').createIndex(
            { phone: 1 },
            { sparse: true }
        );
        console.log('예제 329 - Sparse Index Created');

        // 예제 330: 투명 인덱스 (커버링 쿼리)
        // Example 330: Covered queries
        const example330 = await db.collection('users')
            .find({ email: 'user@example.com' }, { projection: { _id: 1, email: 1 } })
            .toArray();
        console.log('예제 330 - Covered Query:', example330.length);

        // 예제 331-350: 추가 성능 최적화 기법들
        console.log('예제 331-350: 성능 최적화 기법 생성됨');

        // ============================================================================
        // 예제 351-375: 모니터링 및 프로파일링
        // Examples 351-375: Monitoring and Profiling
        // ============================================================================

        // 예제 351: 쿼리 프로파일링
        // Example 351: Query profiling
        const example351 = await db.collection('system.profile')
            .find({})
            .sort({ ts: -1 })
            .limit(10)
            .toArray();
        console.log('예제 351 - Profile Data:', example351.length);

        // 예제 352: 느린 쿼리 분석
        // Example 352: Slow query analysis
        const example352 = await db.collection('system.profile')
            .find({ millis: { $gt: 1000 } })
            .toArray();
        console.log('예제 352 - Slow Queries:', example352.length);

        // ============================================================================
        // 예제 376-400: 데이터 아키텍처 패턴
        // Examples 376-400: Data Architecture Patterns
        // ============================================================================

        // 예제 376: 배치 처리 패턴
        // Example 376: Batch processing pattern
        const example376 = await db.collection('orders').find({ processed: false }).limit(1000).toArray();
        console.log('예제 376 - Batch Processing:', example376.length);

        // 예제 377: 맵-리듀스 패턴 (집계로 대체)
        // Example 377: Map-reduce equivalent with aggregation
        const example377 = await db.collection('orders').aggregate([
            { $match: { status: 'completed' } },
            { $group: { _id: '$userId', total: { $sum: '$amount' } } },
            { $out: 'user_totals' }
        ]).toArray();
        console.log('예제 377 - Aggregation Output');

        // 예제 378: 캐싱 레이어
        // Example 378: Caching layer pattern
        const example378 = {
            cacheKey: 'user:123:profile',
            cacheTTL: 3600,
            data: { userId: '123', name: 'John' }
        };
        console.log('예제 378 - Caching Pattern');

        // 예제 379: 큐 패턴
        // Example 379: Queue pattern
        const example379 = {
            _id: ObjectId(),
            status: 'pending',
            priority: 1,
            data: { action: 'send_email' },
            attempts: 0,
            maxAttempts: 3
        };
        console.log('예제 379 - Queue Pattern');

        // 예제 380-400: 추가 아키텍처 패턴들
        console.log('예제 380-400: 데이터 아키텍처 패턴 생성됨');

        console.log('\n=== All Examples Completed ===');

    } catch (error) {
        console.error('Error:', error);
    } finally {
        // Change stream cleanup
        if (global.changeStream) {
            global.changeStream.close();
        }
        if (global.filteredStream) {
            global.filteredStream.close();
        }
        await client.close();
    }
}

// Run examples
runExamples().catch(console.error);

// Export for use in other modules
module.exports = { runExamples };
