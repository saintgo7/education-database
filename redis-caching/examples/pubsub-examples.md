# Redis Pub/Sub Examples

## Basic Pub/Sub Pattern

### Publisher
```javascript
// publisher.js
const redis = require('redis');
const publisher = redis.createClient();

await publisher.connect();

// Publish message
await publisher.publish('notifications', JSON.stringify({
    type: 'new_order',
    orderId: '12345',
    userId: '1001',
    timestamp: Date.now()
}));
```

### Subscriber
```javascript
// subscriber.js
const redis = require('redis');
const subscriber = redis.createClient();

await subscriber.connect();

// Subscribe to channel
await subscriber.subscribe('notifications', (message) => {
    const data = JSON.parse(message);
    console.log('Received:', data);

    // Process notification
    if (data.type === 'new_order') {
        processOrder(data.orderId);
    }
});
```

## Pattern Matching (PSubscribe)

```javascript
// Subscribe to multiple channels with pattern
await subscriber.pSubscribe('user:*:notifications', (message, channel) => {
    console.log(`Message on ${channel}:`, message);
});

// Publisher
await publisher.publish('user:1001:notifications', 'You have a new message');
await publisher.publish('user:1002:notifications', 'Order shipped');
```

## Use Cases

### 1. Real-time Notifications

```javascript
// Notification Service
class NotificationService {
    constructor(redis) {
        this.publisher = redis.duplicate();
        this.subscriber = redis.duplicate();
    }

    async sendNotification(userId, notification) {
        await this.publisher.publish(
            `user:${userId}:notifications`,
            JSON.stringify(notification)
        );
    }

    async subscribe(userId, callback) {
        await this.subscriber.subscribe(
            `user:${userId}:notifications`,
            callback
        );
    }
}

// Usage
const notifications = new NotificationService(redis);

// Send notification
await notifications.sendNotification('1001', {
    title: 'New Message',
    body: 'You have received a new message',
    timestamp: Date.now()
});

// Receive notifications
await notifications.subscribe('1001', (message) => {
    const notification = JSON.parse(message);
    displayNotification(notification);
});
```

### 2. Chat Application

```javascript
// Chat Room
class ChatRoom {
    constructor(roomId, redis) {
        this.roomId = roomId;
        this.publisher = redis.duplicate();
        this.subscriber = redis.duplicate();
        this.channel = `chat:room:${roomId}`;
    }

    async sendMessage(user, message) {
        await this.publisher.publish(this.channel, JSON.stringify({
            user,
            message,
            timestamp: Date.now()
        }));
    }

    async join(onMessage) {
        await this.subscriber.subscribe(this.channel, (data) => {
            const msg = JSON.parse(data);
            onMessage(msg);
        });
    }

    async leave() {
        await this.subscriber.unsubscribe(this.channel);
    }
}

// Usage
const room = new ChatRoom('general', redis);

await room.join((msg) => {
    console.log(`${msg.user}: ${msg.message}`);
});

await room.sendMessage('Alice', 'Hello everyone!');
```

### 3. Event Bus

```javascript
// Event Bus Pattern
class EventBus {
    constructor(redis) {
        this.publisher = redis.duplicate();
        this.subscriber = redis.duplicate();
        this.handlers = new Map();
    }

    async publish(event, data) {
        await this.publisher.publish(
            `events:${event}`,
            JSON.stringify(data)
        );
    }

    async on(event, handler) {
        if (!this.handlers.has(event)) {
            this.handlers.set(event, []);

            await this.subscriber.subscribe(`events:${event}`, (message) => {
                const data = JSON.parse(message);
                const handlers = this.handlers.get(event) || [];
                handlers.forEach(h => h(data));
            });
        }

        this.handlers.get(event).push(handler);
    }
}

// Usage
const eventBus = new EventBus(redis);

// Subscribe to events
await eventBus.on('user.created', (user) => {
    console.log('New user:', user);
    sendWelcomeEmail(user.email);
});

await eventBus.on('order.placed', (order) => {
    console.log('New order:', order);
    processOrder(order);
    updateInventory(order.items);
});

// Publish events
await eventBus.publish('user.created', {
    userId: '1001',
    username: 'john',
    email: 'john@example.com'
});

await eventBus.publish('order.placed', {
    orderId: '12345',
    userId: '1001',
    items: [{ productId: 'p1', quantity: 2 }]
});
```

### 4. Job Queue System

```javascript
// Simple Job Queue
class JobQueue {
    constructor(queueName, redis) {
        this.queueName = queueName;
        this.publisher = redis.duplicate();
        this.subscriber = redis.duplicate();
        this.jobChannel = `jobs:${queueName}`;
        this.resultChannel = `jobs:${queueName}:results`;
    }

    async addJob(jobData) {
        const jobId = `${Date.now()}-${Math.random()}`;
        const job = { id: jobId, data: jobData };

        await this.publisher.publish(
            this.jobChannel,
            JSON.stringify(job)
        );

        return jobId;
    }

    async processJobs(processor) {
        await this.subscriber.subscribe(this.jobChannel, async (message) => {
            const job = JSON.parse(message);

            try {
                const result = await processor(job.data);

                await this.publisher.publish(
                    this.resultChannel,
                    JSON.stringify({ jobId: job.id, result, status: 'completed' })
                );
            } catch (error) {
                await this.publisher.publish(
                    this.resultChannel,
                    JSON.stringify({ jobId: job.id, error: error.message, status: 'failed' })
                );
            }
        });
    }

    async onResult(callback) {
        await this.subscriber.subscribe(this.resultChannel, (message) => {
            const result = JSON.parse(message);
            callback(result);
        });
    }
}

// Usage
const queue = new JobQueue('email', redis);

// Worker
await queue.processJobs(async (jobData) => {
    console.log('Processing job:', jobData);
    await sendEmail(jobData.to, jobData.subject, jobData.body);
    return { sent: true };
});

// Producer
const jobId = await queue.addJob({
    to: 'user@example.com',
    subject: 'Welcome',
    body: 'Welcome to our service!'
});

// Listen for results
await queue.onResult((result) => {
    console.log('Job completed:', result);
});
```

### 5. Presence System

```javascript
// Online Users Tracking
class PresenceSystem {
    constructor(redis) {
        this.publisher = redis.duplicate();
        this.subscriber = redis.duplicate();
    }

    async userOnline(userId) {
        await this.publisher.publish('presence', JSON.stringify({
            userId,
            status: 'online',
            timestamp: Date.now()
        }));

        // Set expiring key for heartbeat
        await this.publisher.setex(`presence:${userId}`, 30, 'online');
    }

    async userOffline(userId) {
        await this.publisher.publish('presence', JSON.stringify({
            userId,
            status: 'offline',
            timestamp: Date.now()
        }));

        await this.publisher.del(`presence:${userId}`);
    }

    async trackPresence(callback) {
        await this.subscriber.subscribe('presence', (message) => {
            const data = JSON.parse(message);
            callback(data);
        });
    }

    async getOnlineUsers() {
        const keys = await this.publisher.keys('presence:*');
        return keys.map(key => key.replace('presence:', ''));
    }
}
```

## CLI Examples

```bash
# Terminal 1 - Subscriber
redis-cli
SUBSCRIBE notifications

# Terminal 2 - Publisher
redis-cli
PUBLISH notifications "Hello World"

# Pattern subscribe
PSUBSCRIBE user:*:notifications

# Check subscribers
PUBSUB CHANNELS
PUBSUB NUMSUB notifications
PUBSUB NUMPAT
```

## Performance Considerations

1. **Fire-and-Forget**: Pub/Sub doesn't guarantee delivery
2. **No Persistence**: Messages not stored if no subscribers
3. **Use Redis Streams** for reliable messaging
4. **Connection Overhead**: Each subscriber needs a connection
5. **Memory Usage**: Messages buffered in memory

## Pub/Sub vs Streams

| Feature | Pub/Sub | Streams |
|---------|---------|---------|
| Delivery guarantee | No | Yes |
| Message persistence | No | Yes |
| Consumer groups | No | Yes |
| Message history | No | Yes |
| Use case | Real-time events | Job queues, logs |

## Redis Streams (Modern Alternative)

```javascript
// Add to stream
await redis.xAdd('events', '*', {
    type: 'order.placed',
    orderId: '12345',
    userId: '1001'
});

// Read from stream
const messages = await redis.xRead(
    { key: 'events', id: '0' },
    { COUNT: 10 }
);

// Consumer group
await redis.xGroupCreate('events', 'processors', '$', { MKSTREAM: true });

const messages = await redis.xReadGroup(
    'processors',
    'consumer-1',
    { key: 'events', id: '>' },
    { COUNT: 10 }
);
```

## Best Practices

1. **Use Streams for reliability** - When you need guaranteed delivery
2. **Keep messages small** - Minimize network overhead
3. **Handle reconnections** - Subscribers should auto-reconnect
4. **Monitor lag** - Track subscriber processing speed
5. **Use patterns sparingly** - Can be expensive
6. **Separate Redis instances** - For critical pub/sub systems
7. **Implement heartbeats** - Detect dead subscribers
8. **Graceful shutdown** - Unsubscribe before closing
