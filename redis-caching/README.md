# Redis Caching

Redis caching strategies, patterns, data structures, and Pub/Sub messaging.

## Features

- **Caching Patterns**: Cache-Aside, Write-Through, Write-Behind, Refresh-Ahead
- **Data Structures**: Strings, Hashes, Lists, Sets, Sorted Sets
- **Pub/Sub**: Real-time messaging, event bus, notifications
- **Use Cases**: Session storage, rate limiting, leaderboards, distributed locks
- **Performance**: Connection pooling, pipelining, benchmarks

## Quick Start

```bash
# Start Redis
docker-compose up -d

# Access Redis CLI
docker exec -it redis-caching redis-cli

# Access Redis Commander (GUI)
# http://localhost:8082

# Access RedisInsight (Advanced GUI)
# http://localhost:8001
```

## Caching Patterns

### 1. Cache-Aside (Lazy Loading)
```javascript
async function getUser(id) {
    let user = await redis.get(`user:${id}`);
    if (!user) {
        user = await db.users.findById(id);
        await redis.setex(`user:${id}`, 3600, JSON.stringify(user));
    }
    return JSON.parse(user);
}
```

### 2. Write-Through
```javascript
async function updateUser(id, data) {
    const user = await db.users.update(id, data);
    await redis.setex(`user:${id}`, 3600, JSON.stringify(user));
    return user;
}
```

### 3. Write-Behind
```javascript
async function incrementScore(userId, points) {
    await redis.incrby(`user:${userId}:score`, points);
    queue.add('update-db', { userId, points });  // Async DB update
}
```

## Data Structures

### Strings
```bash
SET key "value"
GET key
INCR counter
SETEX session:123 3600 "data"  # With TTL
```

### Hashes (Objects)
```bash
HSET user:1001 name "John" age 30
HGETALL user:1001
HINCRBY user:1001 visits 1
```

### Lists (Queues, Activity Feeds)
```bash
LPUSH queue "job1"
RPOP queue
LRANGE recent:items 0 9  # Latest 10
```

### Sets (Tags, Unique Items)
```bash
SADD tags "redis" "cache" "nosql"
SMEMBERS tags
SINTER set1 set2  # Intersection
```

### Sorted Sets (Leaderboards)
```bash
ZADD leaderboard 1500 "player1" 2000 "player2"
ZRANGE leaderboard 0 9 WITHSCORES
ZREVRANK leaderboard "player1"
```

## Pub/Sub Examples

### Basic
```javascript
// Subscribe
await subscriber.subscribe('channel', (message) => {
    console.log('Received:', message);
});

// Publish
await publisher.publish('channel', 'Hello');
```

### Pattern Matching
```javascript
await subscriber.pSubscribe('user:*:events', (message, channel) => {
    console.log(`${channel}: ${message}`);
});
```

## Use Cases

| Use Case | Data Structure | Pattern | TTL |
|----------|----------------|---------|-----|
| Sessions | String/Hash | Cache-Aside | 30min |
| Rate Limiting | String/Sorted Set | Write-Through | 1min |
| Leaderboard | Sorted Set | Write-Through | No expire |
| Recent Items | List | Write-Through | 7 days |
| Tags/Categories | Set | Cache-Aside | 1 hour |
| Distributed Lock | String | SETNX | 10sec |

## Performance Tips

1. **Use Pipelining** - Batch commands
2. **Connection Pooling** - Reuse connections
3. **Compression** - For large values
4. **Appropriate TTLs** - Balance freshness vs load
5. **Monitor Hit Ratio** - Aim for >80%
6. **Use Lua Scripts** - Atomic operations

## Commands Cheat Sheet

```bash
# Keys
SET key value
GET key
DEL key
EXISTS key
EXPIRE key 60
TTL key

# Strings
INCR counter
DECR counter
APPEND key " more"

# Hashes
HSET hash field value
HGET hash field
HDEL hash field

# Lists
LPUSH list value
RPUSH list value
LPOP list
LLEN list

# Sets
SADD set member
SREM set member
SISMEMBER set member

# Sorted Sets
ZADD zset score member
ZRANK zset member
ZINCRBY zset increment member

# Pub/Sub
PUBLISH channel message
SUBSCRIBE channel
PSUBSCRIBE pattern

# Server
INFO stats
MONITOR
SLOWLOG GET 10
```

## File Structure

```
redis-caching/
├── docker-compose.yml
├── config/redis.conf
├── examples/
│   ├── caching-patterns.md
│   ├── pubsub-examples.md
│   └── data-structures.js
└── README.md
```

See [caching-patterns.md](./examples/caching-patterns.md) for detailed examples.
See [pubsub-examples.md](./examples/pubsub-examples.md) for messaging patterns.
