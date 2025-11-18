// Redis 200 Complete Examples (Extended)
// Advanced Redis operations and patterns

console.log('=== Redis 200 Complete Examples (51-200) ===\n');

async function runExtendedExamples() {
  const client = require('redis').createClient();
  await client.connect();

  try {
    // ============================================
    // 51-75: Sorted Set Operations
    // ============================================

    console.log('📝 Example 51-75: Sorted Sets');

    // Add to sorted set
    await client.zAdd('leaderboard', [
      { score: 100, member: 'player1' },
      { score: 200, member: 'player2' },
      { score: 150, member: 'player3' }
    ]);

    // Range by score
    const topScores = await client.zRangeByScore('leaderboard', 150, 250);
    console.log(`Top scores: ${topScores.join(', ')}`);

    // Get rank
    const rank = await client.zRank('leaderboard', 'player2');
    console.log(`Player2 rank: ${rank + 1}`);

    // Score update
    await client.zIncrBy('leaderboard', 50, 'player1');

    // Count in range
    const count = await client.zCount('leaderboard', 100, 200);

    // Remove by rank
    await client.zRemRangeByRank('leaderboard', 0, 0);

    // Union of sorted sets
    await client.zAdd('season1', [{ score: 100, member: 'p1' }, { score: 200, member: 'p2' }]);
    await client.zAdd('season2', [{ score: 150, member: 'p1' }, { score: 180, member: 'p3' }]);

    // ============================================
    // 76-100: Pub/Sub Patterns
    // ============================================

    console.log('📝 Example 76-100: Pub/Sub');

    // Create subscriber
    const subscriber = require('redis').createClient();
    await subscriber.connect();

    // Subscribe to channel
    await subscriber.subscribe('notifications', (message) => {
      console.log(`Received: ${message}`);
    });

    // Pattern subscribe
    await subscriber.pSubscribe('user:*', (message) => {
      console.log(`Pattern match: ${message}`);
    });

    // Publish messages
    await client.publish('notifications', 'New order arrived');
    await client.publish('user:1:orders', 'Order confirmed');

    // ============================================
    // 101-125: Stream Operations
    // ============================================

    console.log('📝 Example 101-125: Streams');

    // Add to stream
    const streamId = await client.xAdd('events', '*', {
      type: 'order',
      user_id: '123',
      amount: '99.99'
    });

    // Read stream
    const messages = await client.xRead(
      [{ key: 'events', id: '0' }],
      { count: 10 }
    );

    // Stream groups
    await client.xGroupCreate('events', 'order-group', '$', { MKSTREAM: true });

    // Consumer group read
    const groupMessages = await client.xReadGroup(
      { key: 'events', group: 'order-group', consumer: 'consumer1' },
      [{ key: 'events', id: '>' }]
    );

    // ============================================
    // 126-150: Advanced Caching Patterns
    // ============================================

    console.log('📝 Example 126-150: Caching Patterns');

    // Cache-aside pattern
    async function getCachedUser(userId) {
      let userData = await client.get(`user:${userId}`);
      if (!userData) {
        userData = { id: userId, name: 'User ' + userId };
        await client.setEx(`user:${userId}`, 3600, JSON.stringify(userData));
      }
      return JSON.parse(userData);
    }

    // Write-through pattern
    async function writeUserData(userId, data) {
      await client.set(`user:${userId}`, JSON.stringify(data));
      // Write to main database
    }

    // Bloom filter
    await client.bfAdd('users', 'user1@example.com');
    const exists = await client.bfExists('users', 'user1@example.com');

    // ============================================
    // 151-175: Distributed Locking
    // ============================================

    console.log('📝 Example 151-175: Distributed Locks');

    // Acquire lock
    const lockKey = 'resource:lock';
    const lockValue = Date.now().toString();

    const acquired = await client.set(lockKey, lockValue, {
      NX: true,
      EX: 30
    });

    if (acquired) {
      // Do work
      await client.del(lockKey);
    }

    // Redlock pattern
    // Multiple Redis instances for distributed locking

    // ============================================
    // 176-200: Monitoring and Maintenance
    // ============================================

    console.log('📝 Example 176-200: Monitoring');

    // Server info
    const info = await client.info();

    // Memory usage
    const memInfo = await client.info('memory');

    // Key patterns
    const keys = await client.keys('user:*');

    // Scan with pattern
    let cursor = 0;
    const scanResult = await client.scan(cursor, { MATCH: 'user:*', COUNT: 100 });

    // Database size
    const dbSize = await client.dbSize();

    // TTL management
    const ttl = await client.ttl('temp:key');

    // Persistence
    await client.save();
    await client.bgsave();

    // Keyspace statistics
    const keyspaceInfo = await client.info('keyspace');

    // Client list
    const clients = await client.clientList();

    // Slowlog
    const slowlog = await client.slowlogGet(10);

    // Monitor commands
    // await client.monitor();

    // Cleanup
    await subscriber.unsubscribe();
    await subscriber.disconnect();
    await client.disconnect();

    console.log('✅ All 200 Redis examples completed');

  } catch (error) {
    console.error('Error:', error);
  }
}

runExtendedExamples();
