// Redis 50 Runnable Examples
// Complete executable Node.js script with commands and operations
// Run with: npm install redis && node runnable-examples.js

const redis = require('redis');

const client = redis.createClient({
  host: 'localhost',
  port: 6379
});

async function runExamples() {
  try {
    await client.connect();
    console.log('✅ Connected to Redis\n');
    console.log('='.repeat(60) + '\n');

    // ============================================
    // String Operations (1-10)
    // ============================================

    console.log('📝 Example 1: SET and GET string');
    await client.set('user:1:name', 'John Doe');
    const name = await client.get('user:1:name');
    console.log(`Name: ${name}\n`);

    console.log('📝 Example 2: SET with expiration');
    await client.setEx('session:abc123', 3600, 'session_data_here');
    const session = await client.get('session:abc123');
    console.log(`Session: ${session}\n`);

    console.log('📝 Example 3: SETNX (set if not exists)');
    const result = await client.setNX('key:new', 'value');
    console.log(`Set new key: ${result}\n`);

    console.log('📝 Example 4: MSET multiple keys');
    await client.mSet({
      'user:2:name': 'Jane Smith',
      'user:2:email': 'jane@example.com',
      'user:2:status': 'active'
    });
    console.log('Set multiple keys\n');

    console.log('📝 Example 5: MGET multiple keys');
    const values = await client.mGet(['user:2:name', 'user:2:email', 'user:2:status']);
    console.log(`User data: ${JSON.stringify(values)}\n`);

    console.log('📝 Example 6: APPEND to string');
    await client.append('user:1:name', ' (Premium)');
    const updated = await client.get('user:1:name');
    console.log(`Updated name: ${updated}\n`);

    console.log('📝 Example 7: STRLEN');
    const length = await client.strLen('user:1:name');
    console.log(`Name length: ${length}\n`);

    console.log('📝 Example 8: GETRANGE');
    const range = await client.getRange('user:1:name', 0, 3);
    console.log(`First 4 chars: ${range}\n`);

    console.log('📝 Example 9: SETRANGE');
    await client.setRange('user:1:name', 0, 'Jane');
    const modified = await client.get('user:1:name');
    console.log(`Modified name: ${modified}\n`);

    console.log('📝 Example 10: GETSET');
    const oldValue = await client.getSet('user:1:name', 'John Doe');
    console.log(`Old value: ${oldValue}\n`);

    // ============================================
    // Numeric Operations (11-15)
    // ============================================

    console.log('📝 Example 11: INCR increment');
    await client.set('counter:page_views', '100');
    const incremented = await client.incr('counter:page_views');
    console.log(`Page views: ${incremented}\n`);

    console.log('📝 Example 12: INCRBY');
    const incrBy = await client.incrBy('counter:page_views', 10);
    console.log(`Page views after +10: ${incrBy}\n`);

    console.log('📝 Example 13: INCRBYFLOAT');
    await client.set('price:item1', '19.99');
    const price = await client.incrByFloat('price:item1', 5.50);
    console.log(`New price: ${price}\n`);

    console.log('📝 Example 14: DECR decrement');
    const decremented = await client.decr('counter:page_views');
    console.log(`Page views after -1: ${decremented}\n`);

    console.log('📝 Example 15: DECRBY');
    const decrBy = await client.decrBy('counter:page_views', 5);
    console.log(`Page views after -5: ${decrBy}\n`);

    // ============================================
    // Key Expiration (16-20)
    // ============================================

    console.log('📝 Example 16: EXPIRE set expiration');
    await client.set('temp:data', 'temporary');
    await client.expire('temp:data', 60);
    console.log('Set expiration to 60 seconds\n');

    console.log('📝 Example 17: TTL check time to live');
    const ttl = await client.ttl('temp:data');
    console.log(`TTL: ${ttl} seconds\n`);

    console.log('📝 Example 18: PTTL milliseconds');
    const pttl = await client.pttl('temp:data');
    console.log(`PTTL: ${pttl} ms\n`);

    console.log('📝 Example 19: PERSIST remove expiration');
    await client.persist('temp:data');
    const ttlAfter = await client.ttl('temp:data');
    console.log(`TTL after persist: ${ttlAfter}\n`);

    console.log('📝 Example 20: PEXPIRE millisecond expiration');
    await client.pExpire('temp:data', 5000);
    console.log('Set 5000ms expiration\n');

    // ============================================
    // List Operations (21-30)
    // ============================================

    console.log('📝 Example 21: LPUSH push to left');
    await client.del('queue:tasks');
    const pushed = await client.lPush('queue:tasks', ['task3', 'task2', 'task1']);
    console.log(`List size: ${pushed}\n`);

    console.log('📝 Example 22: RPUSH push to right');
    await client.rPush('queue:tasks', 'task4');
    console.log('Pushed to right\n');

    console.log('📝 Example 23: LLEN list length');
    const listLen = await client.lLen('queue:tasks');
    console.log(`Queue length: ${listLen}\n`);

    console.log('📝 Example 24: LRANGE get range');
    const tasks = await client.lRange('queue:tasks', 0, -1);
    console.log(`All tasks: ${JSON.stringify(tasks)}\n`);

    console.log('📝 Example 25: LPOP pop from left');
    const popped = await client.lPop('queue:tasks');
    console.log(`Popped from left: ${popped}\n`);

    console.log('📝 Example 26: RPOP pop from right');
    const poppedRight = await client.rPop('queue:tasks');
    console.log(`Popped from right: ${poppedRight}\n`);

    console.log('📝 Example 27: LINDEX get by index');
    const atIndex = await client.lIndex('queue:tasks', 0);
    console.log(`Item at index 0: ${atIndex}\n`);

    console.log('📝 Example 28: LSET set by index');
    await client.lSet('queue:tasks', 0, 'updated_task');
    console.log('Updated item at index 0\n');

    console.log('📝 Example 29: LTRIM trim list');
    await client.lTrim('queue:tasks', 0, 1);
    console.log('Trimmed list to first 2 items\n');

    console.log('📝 Example 30: RPOPLPUSH move between lists');
    await client.del('list:source', 'list:dest');
    await client.rPush('list:source', ['a', 'b', 'c']);
    const moved = await client.rPopLPush('list:source', 'list:dest');
    console.log(`Moved: ${moved}\n`);

    // ============================================
    // Set Operations (31-40)
    // ============================================

    console.log('📝 Example 31: SADD add to set');
    await client.del('tags:post1');
    const added = await client.sAdd('tags:post1', ['python', 'redis', 'database']);
    console.log(`Added ${added} items\n`);

    console.log('📝 Example 32: SMEMBERS get all');
    const members = await client.sMembers('tags:post1');
    console.log(`Members: ${JSON.stringify(members)}\n`);

    console.log('📝 Example 33: SISMEMBER check');
    const isMember = await client.sIsMember('tags:post1', 'python');
    console.log(`Is 'python' member: ${isMember}\n`);

    console.log('📝 Example 34: SCARD count');
    const cardSize = await client.sCard('tags:post1');
    console.log(`Set size: ${cardSize}\n`);

    console.log('📝 Example 35: SREM remove');
    const removed = await client.sRem('tags:post1', 'redis');
    console.log(`Removed ${removed} items\n`);

    console.log('📝 Example 36: SPOP random member');
    await client.sAdd('tags:post1', 'javascript');
    const popped2 = await client.sPop('tags:post1');
    console.log(`Random member: ${popped2}\n`);

    console.log('📝 Example 37: SRANDMEMBER');
    const random = await client.sRandMember('tags:post1', 1);
    console.log(`Random members: ${JSON.stringify(random)}\n`);

    console.log('📝 Example 38: SUNION set union');
    await client.del('tags:post2');
    await client.sAdd('tags:post2', ['javascript', 'nodejs']);
    const union = await client.sUnion('tags:post1', 'tags:post2');
    console.log(`Union: ${JSON.stringify(union)}\n`);

    console.log('📝 Example 39: SINTER set intersection');
    const inter = await client.sInter('tags:post1', 'tags:post2');
    console.log(`Intersection: ${JSON.stringify(inter)}\n`);

    console.log('📝 Example 40: SDIFF set difference');
    const diff = await client.sDiff('tags:post1', 'tags:post2');
    console.log(`Difference: ${JSON.stringify(diff)}\n`);

    // ============================================
    // Hash Operations (41-50)
    // ============================================

    console.log('📝 Example 41: HSET set hash field');
    await client.del('user:100');
    await client.hSet('user:100', {
      name: 'Alice',
      email: 'alice@example.com',
      age: 28
    });
    console.log('Set hash fields\n');

    console.log('📝 Example 42: HGET get field');
    const hashName = await client.hGet('user:100', 'name');
    console.log(`User name: ${hashName}\n`);

    console.log('📝 Example 43: HMGET multiple fields');
    const multiField = await client.hMGet('user:100', ['name', 'email']);
    console.log(`User data: ${JSON.stringify(multiField)}\n`);

    console.log('📝 Example 44: HGETALL get all');
    const allFields = await client.hGetAll('user:100');
    console.log(`All fields: ${JSON.stringify(allFields)}\n`);

    console.log('📝 Example 45: HKEYS get keys');
    const keys = await client.hKeys('user:100');
    console.log(`Field names: ${JSON.stringify(keys)}\n`);

    console.log('📝 Example 46: HVALS get values');
    const hashVals = await client.hVals('user:100');
    console.log(`Field values: ${JSON.stringify(hashVals)}\n`);

    console.log('📝 Example 47: HLEN hash size');
    const hashLen = await client.hLen('user:100');
    console.log(`Hash size: ${hashLen}\n`);

    console.log('📝 Example 48: HEXISTS check field');
    const exists = await client.hExists('user:100', 'name');
    console.log(`Field exists: ${exists}\n`);

    console.log('📝 Example 49: HDEL delete field');
    await client.hDel('user:100', 'age');
    console.log('Deleted age field\n');

    console.log('📝 Example 50: HINCRBY increment field');
    await client.hSet('user:100', 'age', '28');
    const newAge = await client.hIncrBy('user:100', 'age', 1);
    console.log(`Incremented age: ${newAge}\n`);

    console.log('✅ All 50 Redis examples completed successfully!');

  } catch (error) {
    console.error('Error:', error);
  } finally {
    await client.quit();
  }
}

runExamples();
