# Redis Caching Patterns

## 1. Cache-Aside (Lazy Loading)

Application checks cache first, then database.

```javascript
// Node.js example
async function getUser(userId) {
    const cacheKey = `user:${userId}`;

    // Check cache
    let user = await redis.get(cacheKey);

    if (user) {
        return JSON.parse(user);  // Cache hit
    }

    // Cache miss - fetch from database
    user = await database.users.findById(userId);

    // Store in cache
    await redis.setex(cacheKey, 3600, JSON.stringify(user));

    return user;
}
```

**Use Case**: User profiles, product details
**TTL**: 1 hour to 1 day
**Pros**: Only cache data that's actually requested
**Cons**: Initial request is slow (cache miss)

## 2. Write-Through Cache

Update cache and database simultaneously.

```javascript
async function updateUser(userId, userData) {
    const cacheKey = `user:${userId}`;

    // Update database
    const user = await database.users.update(userId, userData);

    // Update cache
    await redis.setex(cacheKey, 3600, JSON.stringify(user));

    return user;
}
```

**Use Case**: Frequently read data that changes often
**Pros**: Cache is always consistent
**Cons**: Write penalty (two operations)

## 3. Write-Behind (Write-Back) Cache

Write to cache immediately, database asynchronously.

```javascript
async function updateUserScore(userId, score) {
    const cacheKey = `user:${userId}:score`;

    // Update cache immediately
    await redis.set(cacheKey, score);

    // Queue database update (async)
    await queue.add('update-score', { userId, score });

    return score;
}
```

**Use Case**: High-write applications, leaderboards
**Pros**: Fast writes
**Cons**: Risk of data loss if cache fails

## 4. Refresh-Ahead

Refresh cache before expiration.

```javascript
async function getProductWithRefresh(productId) {
    const cacheKey = `product:${productId}`;

    let product = await redis.get(cacheKey);
    const ttl = await redis.ttl(cacheKey);

    if (product && ttl < 300) {  // Refresh if TTL < 5 min
        // Async refresh
        refreshProduct(productId);
    }

    if (!product) {
        product = await database.products.findById(productId);
        await redis.setex(cacheKey, 3600, JSON.stringify(product));
    }

    return JSON.parse(product);
}
```

**Use Case**: Popular items, hot data
**Pros**: Always fast, no cache misses
**Cons**: Wastes resources on unpopular data

## 5. Cache Patterns in Redis

### String Pattern
```bash
# Simple key-value
SET user:1001:name "John Doe"
GET user:1001:name
SETEX session:abc123 3600 "user_data"  # With TTL
```

### Hash Pattern (Object Caching)
```bash
# Store object fields
HSET user:1001 name "John" email "john@example.com" age 30
HGETALL user:1001
HINCRBY user:1001 login_count 1
```

### List Pattern (Recent Items)
```bash
# Recent activity feed
LPUSH user:1001:activity "logged_in"
LPUSH user:1001:activity "viewed_product_123"
LRANGE user:1001:activity 0 9  # Get latest 10
LTRIM user:1001:activity 0 99  # Keep only latest 100
```

### Set Pattern (Tags, Followers)
```bash
# User tags
SADD user:1001:tags "developer" "nodejs" "react"
SMEMBERS user:1001:tags
SISMEMBER user:1001:tags "nodejs"  # Check membership

# Mutual followers
SINTER user:1001:followers user:1002:followers
```

### Sorted Set Pattern (Leaderboards)
```bash
# Game leaderboard
ZADD leaderboard 1500 "player1" 2000 "player2" 1800 "player3"
ZRANGE leaderboard 0 9 WITHSCORES  # Top 10
ZREVRANGE leaderboard 0 9 WITHSCORES  # Top 10 (descending)
ZRANK leaderboard "player1"  # Get rank
ZINCRBY leaderboard 100 "player1"  # Increment score
```

## 6. Session Storage

```javascript
// Express session with Redis
const session = require('express-session');
const RedisStore = require('connect-redis')(session);

app.use(session({
    store: new RedisStore({ client: redis }),
    secret: 'secret',
    resave: false,
    saveUninitialized: false,
    cookie: { maxAge: 3600000 }  // 1 hour
}));
```

```bash
# Redis session structure
SETEX session:abc123 3600 '{"userId":1001,"username":"john"}'
```

## 7. Rate Limiting

```javascript
async function checkRateLimit(userId, limit = 100, window = 60) {
    const key = `ratelimit:${userId}`;

    const current = await redis.incr(key);

    if (current === 1) {
        await redis.expire(key, window);
    }

    if (current > limit) {
        throw new Error('Rate limit exceeded');
    }

    return { remaining: limit - current };
}
```

```bash
# Sliding window rate limit
MULTI
ZADD ratelimit:user:1001 ${timestamp} ${requestId}
ZREMRANGEBYSCORE ratelimit:user:1001 0 ${timestamp - 60000}
ZCARD ratelimit:user:1001
EXEC
```

## 8. Distributed Locks

```javascript
async function acquireLock(resource, timeout = 10000) {
    const lockKey = `lock:${resource}`;
    const lockValue = Date.now() + timeout;

    const acquired = await redis.setnx(lockKey, lockValue);

    if (acquired) {
        await redis.pexpire(lockKey, timeout);
        return lockValue;
    }

    return null;
}

async function releaseLock(resource, lockValue) {
    const lockKey = `lock:${resource}`;
    const currentValue = await redis.get(lockKey);

    if (currentValue === lockValue.toString()) {
        await redis.del(lockKey);
        return true;
    }

    return false;
}
```

## 9. Caching Strategies by Use Case

| Use Case | Pattern | Data Structure | TTL |
|----------|---------|----------------|-----|
| User sessions | Cache-aside | String/Hash | 30min-2hours |
| Product catalog | Refresh-ahead | Hash | 1-24 hours |
| Leaderboards | Write-through | Sorted Set | No expire |
| Recent activity | Write-through | List | 7 days |
| API rate limiting | Write-through | String/Sorted Set | 1 minute |
| Full-page cache | Cache-aside | String | 5-15 minutes |
| Shopping cart | Write-through | Hash | 24 hours |
| Real-time counters | Write-behind | String | No expire |

## 10. Cache Invalidation Strategies

### Time-based (TTL)
```bash
SETEX cache:key 3600 "value"  # Expires in 1 hour
```

### Event-based
```javascript
// Invalidate on update
await database.users.update(userId, data);
await redis.del(`user:${userId}`);
```

### Tag-based
```javascript
// Invalidate related caches
await redis.del(
    `user:${userId}`,
    `user:${userId}:orders`,
    `user:${userId}:profile`
);
```

### Pattern-based
```bash
# Delete all user caches
EVAL "return redis.call('del', unpack(redis.call('keys', ARGV[1])))" 0 user:*
```

## Best Practices

1. **Use appropriate TTLs** - Balance freshness vs database load
2. **Cache high-read, low-write data** - Maximum benefit
3. **Monitor cache hit ratio** - Aim for >80%
4. **Use connection pooling** - Reuse connections
5. **Handle cache failures gracefully** - Fallback to database
6. **Compress large values** - Save memory
7. **Use pipelining** - Batch multiple commands
8. **Monitor memory usage** - Use maxmemory policies
9. **Version your cache keys** - Easy invalidation
10. **Log cache misses** - Identify optimization opportunities
