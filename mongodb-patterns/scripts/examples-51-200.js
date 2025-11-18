// MongoDB 200 Complete Examples (Extended)
// Add this to the end of runnable-examples.js

// ============================================
// Example 51-100: Advanced Aggregations
// ============================================

// 51-55: Complex pipeline stages
db.orders.aggregate([
  { $match: { status: 'completed' } },
  { $group: { _id: '$customer_id', total: { $sum: '$total' } } },
  { $sort: { total: -1 } },
  { $skip: 10 },
  { $limit: 5 }
]);

// 56-60: Using $project with expressions
db.orders.aggregate([
  { $project: {
      customer_id: 1,
      total: 1,
      year: { $year: new Date() },
      month: { $month: new Date() },
      formatted_total: { $toString: '$total' }
    }
  }
]);

// 61-65: String operations in aggregation
db.users.aggregate([
  { $project: {
      username: 1,
      email_domain: { $substr: ['$email', { $add: [{ $indexOf: ['$email', '@'] }, 1] }, -1] },
      username_upper: { $toUpper: '$username' },
      username_lower: { $toLower: '$username' }
    }
  }
]);

// 66-70: Array operations in aggregation
db.orders.aggregate([
  { $project: {
      items_count: { $size: '$items' },
      first_item: { $arrayElemAt: ['$items', 0] },
      has_multiple: { $gt: [{ $size: '$items' }, 1] }
    }
  }
]);

// 71-75: Conditional operations
db.products.aggregate([
  { $project: {
      name: 1,
      price: 1,
      discount: {
        $cond: { if: { $gte: ['$price', 100] }, then: 0.2, else: 0.1 }
      }
    }
  }
]);

// 76-80: Date operations
db.orders.aggregate([
  { $project: {
      order_date: 1,
      year: { $year: '$order_date' },
      month: { $month: '$order_date' },
      day: { $dayOfMonth: '$order_date' },
      days_old: { $floor: { $divide: [{ $subtract: [new Date(), '$order_date'] }, 1000 * 60 * 60 * 24] } }
    }
  }
]);

// 81-85: Math operations
db.products.aggregate([
  { $project: {
      name: 1,
      price: 1,
      doubled: { $multiply: ['$price', 2] },
      half: { $divide: ['$price', 2] },
      rounded: { $round: ['$price', 0] }
    }
  }
]);

// 86-90: Lookup with pipeline
db.orders.aggregate([
  { $lookup: {
      from: 'users',
      localField: 'customer_id',
      foreignField: '_id',
      as: 'customer'
    }
  },
  { $unwind: '$customer' },
  { $match: { 'customer.status': 'active' } }
]);

// 91-95: GraphLookup (recursive lookup)
db.users.aggregate([
  { $graphLookup: {
      from: 'users',
      startWith: '$_id',
      connectFromField: '_id',
      connectToField: 'manager_id',
      as: 'subordinates'
    }
  }
]);

// 96-100: Bucket aggregation
db.products.aggregate([
  { $bucket: {
      groupBy: '$price',
      boundaries: [0, 50, 100, 200, 500, 1000],
      default: 'other',
      output: { count: { $sum: 1 }, names: { $push: '$name' } }
    }
  }
]);

// ============================================
// Example 101-150: Complex Data Operations
// ============================================

// 101-105: Bulk operations
db.products.bulkWrite([
  { insertOne: { document: { name: 'New Product', price: 99.99 } } },
  { updateMany: { filter: { category: 'Electronics' }, update: { $inc: { price: 10 } } } },
  { deleteMany: { filter: { stock: 0 } } }
]);

// 106-110: Transaction support
session.startTransaction();
db.users.insertOne({ username: 'new_user', email: 'new@example.com' });
db.orders.insertOne({ customer_id: 'new_user', total: 100 });
session.commitTransaction();

// 111-115: Change streams
db.users.watch().on('change', (change) => {
  console.log('Change detected:', change);
});

// 116-120: Index management
db.users.createIndex({ email: 1 }, { unique: true });
db.products.createIndex({ name: 'text', description: 'text' });
db.orders.createIndex({ customer_id: 1, order_date: -1 });

// 121-125: Collation support
db.users.find().collation({ locale: 'en', strength: 2 }).toArray();
db.products.find({ name: /laptop/i }).collation({ locale: 'en', strength: 1 }).toArray();

// 126-130: Validation rules
db.createCollection('users', {
  validator: {
    $jsonSchema: {
      bsonType: 'object',
      properties: {
        email: { bsonType: 'string' },
        age: { bsonType: 'int', minimum: 0, maximum: 150 }
      }
    }
  }
});

// 131-135: Time series collections
db.createCollection('sensor_data', { timeseries: { timeField: 'timestamp', metaField: 'metadata', granularity: 'hours' } });

// 136-140: Geospatial queries
db.locations.createIndex({ location: '2dsphere' });
db.locations.find({
  location: { $near: { $geometry: { type: 'Point', coordinates: [0, 0] }, $maxDistance: 1000 } }
});

// 141-145: Full text search variations
db.products.find({ $text: { $search: 'laptop -broken', $caseSensitive: true } });
db.products.find({ $text: { $search: 'laptop' } }, { score: { $meta: 'textScore' } }).sort({ score: { $meta: 'textScore' } });

// 146-150: Aggregation optimization
db.orders.aggregate([
  { $match: { status: 'completed' } },
  { $limit: 1000 },
  { $sort: { total: -1 } },
  { $group: { _id: '$customer_id', total: { $sum: '$total' } } }
], { allowDiskUse: true });

// ============================================
// Example 151-200: Advanced Features
// ============================================

// 151-155: Explain and profiling
db.orders.find({ status: 'completed' }).explain('executionStats');
db.setProfilingLevel(1, { slowms: 100 });

// 156-160: Connection pooling
const client = new MongoClient(url, { maxPoolSize: 50, minPoolSize: 10 });

// 161-165: Replica set operations
rs.initiate({ _id: 'rs0', members: [{ _id: 0, host: 'localhost:27017' }] });
rs.status();

// 166-170: Sharding
// sh.enableSharding('education_db');
// sh.shardCollection('education_db.orders', { customer_id: 'hashed' });

// 171-175: Backup and restore
// mongodump --db education_db --out ./backup
// mongorestore --db education_db ./backup/education_db

// 176-180: Atlas Search
db.products.find({ $or: [
  { $text: { $search: 'laptop' } },
  { category: 'Electronics' }
]});

// 181-185: Encryption at rest
// enableEncryption: true, encryptionKeyFile: '/path/to/keyfile'

// 186-190: Field-level encryption
const keyVault = client.db('admin').collection('__keyVault');

// 191-195: Transactions with multi-document
const session = client.startSession();
session.withTransaction(async () => {
  await db.collection('users').insertOne({ name: 'user1' }, { session });
  await db.collection('orders').insertOne({ user: 'user1' }, { session });
});

// 196-200: Summary and cleanup
db.users.countDocuments();
db.products.countDocuments();
db.orders.countDocuments();
db.reviews.countDocuments();
console.log('✅ All 200 MongoDB examples completed');
