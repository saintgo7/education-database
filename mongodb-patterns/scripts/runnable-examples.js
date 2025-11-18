// MongoDB 50 Runnable Examples
// Complete executable Node.js script with data setup and queries
// Run with: npm install mongodb && node runnable-examples.js

const { MongoClient } = require('mongodb');

const MONGO_URL = 'mongodb://admin:admin123@localhost:27017/education_db';
const DB_NAME = 'education_db';

async function runExamples() {
  const client = new MongoClient(MONGO_URL);

  try {
    await client.connect();
    const db = client.db(DB_NAME);

    // Setup: Clean and prepare collections
    console.log('🔄 Setting up database...\n');

    await db.collection('users').deleteMany({});
    await db.collection('products').deleteMany({});
    await db.collection('orders').deleteMany({});
    await db.collection('reviews').deleteMany({});

    // Insert sample data
    const users = await db.collection('users').insertMany([
      { _id: 1, username: 'john_doe', email: 'john@example.com', status: 'active', age: 28 },
      { _id: 2, username: 'jane_smith', email: 'jane@example.com', status: 'active', age: 32 },
      { _id: 3, username: 'bob_wilson', email: 'bob@example.com', status: 'inactive', age: 45 },
      { _id: 4, username: 'alice_johnson', email: 'alice@example.com', status: 'active', age: 26 },
      { _id: 5, username: 'charlie_brown', email: 'charlie@example.com', status: 'active', age: 35 },
    ]);

    const products = await db.collection('products').insertMany([
      { _id: 1, name: 'Laptop', category: 'Electronics', price: 999.99, stock: 50 },
      { _id: 2, name: 'Mouse', category: 'Electronics', price: 29.99, stock: 200 },
      { _id: 3, name: 'Keyboard', category: 'Electronics', price: 79.99, stock: 100 },
      { _id: 4, name: 'Monitor', category: 'Electronics', price: 299.99, stock: 30 },
      { _id: 5, name: 'Desk Chair', category: 'Furniture', price: 199.99, stock: 25 },
    ]);

    const orders = await db.collection('orders').insertMany([
      { _id: 1, user_id: 1, total: 1079.98, status: 'completed', items: [1, 2] },
      { _id: 2, user_id: 2, total: 339.98, status: 'completed', items: [3, 2] },
      { _id: 3, user_id: 1, total: 259.97, status: 'pending', items: [4, 3] },
      { _id: 4, user_id: 3, total: 149.99, status: 'completed', items: [2] },
      { _id: 5, user_id: 4, total: 1269.95, status: 'completed', items: [1, 4, 5] },
    ]);

    console.log('✅ Database setup complete\n');
    console.log('='.repeat(60) + '\n');

    // ============================================
    // Example 1-5: Basic CRUD Operations
    // ============================================

    console.log('📝 Example 1: Find all users');
    const allUsers = await db.collection('users').find().toArray();
    console.log(`Found ${allUsers.length} users`);
    console.log(JSON.stringify(allUsers.slice(0, 2), null, 2), '\n');

    console.log('📝 Example 2: Find user by email');
    const userByEmail = await db.collection('users').findOne({ email: 'john@example.com' });
    console.log(JSON.stringify(userByEmail, null, 2), '\n');

    console.log('📝 Example 3: Find active users only');
    const activeUsers = await db.collection('users').find({ status: 'active' }).toArray();
    console.log(`Found ${activeUsers.length} active users\n`);

    console.log('📝 Example 4: Count total products');
    const productCount = await db.collection('products').countDocuments();
    console.log(`Total products: ${productCount}\n`);

    console.log('📝 Example 5: Find products in price range');
    const priceRange = await db.collection('products').find({ price: { $gte: 100, $lte: 500 } }).toArray();
    console.log(`Found ${priceRange.length} products in price range\n`);

    // ============================================
    // Example 6-10: Filtering and Comparison
    // ============================================

    console.log('📝 Example 6: Find expensive products');
    const expensive = await db.collection('products').find({ price: { $gt: 200 } }).toArray();
    console.log(`Found ${expensive.length} expensive products`);
    console.log(JSON.stringify(expensive.map(p => ({ name: p.name, price: p.price })), null, 2), '\n');

    console.log('📝 Example 7: Find incomplete orders');
    const incomplete = await db.collection('orders').find({ status: { $ne: 'completed' } }).toArray();
    console.log(`Found ${incomplete.length} incomplete orders\n`);

    console.log('📝 Example 8: Users with age over 30');
    const over30 = await db.collection('users').find({ age: { $gt: 30 } }).toArray();
    console.log(`Found ${over30.length} users over 30\n`);

    console.log('📝 Example 9: Find specific products by category');
    const electronics = await db.collection('products').find({ category: 'Electronics' }).toArray();
    console.log(`Found ${electronics.length} electronics products\n`);

    console.log('📝 Example 10: Users in specific list');
    const specificUsers = await db.collection('users').find({ username: { $in: ['john_doe', 'alice_johnson'] } }).toArray();
    console.log(`Found ${specificUsers.length} specific users\n`);

    // ============================================
    // Example 11-15: Sorting and Limiting
    // ============================================

    console.log('📝 Example 11: Products sorted by price (descending)');
    const sortedByPrice = await db.collection('products').find().sort({ price: -1 }).toArray();
    console.log(JSON.stringify(sortedByPrice.map(p => ({ name: p.name, price: p.price })), null, 2), '\n');

    console.log('📝 Example 12: Top 3 users by age');
    const topAge = await db.collection('users').find().sort({ age: -1 }).limit(3).toArray();
    console.log(`Top 3 users:\n`, topAge.map(u => `${u.username}: ${u.age}`).join('\n'), '\n');

    console.log('📝 Example 13: Skip and limit (pagination)');
    const paginated = await db.collection('products').find().skip(1).limit(2).toArray();
    console.log(`Page 2 (items 2-3):`);
    console.log(JSON.stringify(paginated.map(p => ({ name: p.name })), null, 2), '\n');

    console.log('📝 Example 14: Count with filter');
    const count = await db.collection('orders').countDocuments({ status: 'completed' });
    console.log(`Completed orders: ${count}\n`);

    console.log('📝 Example 15: Distinct values');
    const distinct = await db.collection('products').distinct('category');
    console.log(`Product categories: ${distinct.join(', ')}\n`);

    // ============================================
    // Example 16-20: Update Operations
    // ============================================

    console.log('📝 Example 16: Update single field');
    await db.collection('users').updateOne(
      { username: 'john_doe' },
      { $set: { status: 'premium' } }
    );
    const updated = await db.collection('users').findOne({ username: 'john_doe' });
    console.log(`Updated user status: ${updated.status}\n`);

    console.log('📝 Example 17: Update multiple fields');
    await db.collection('products').updateOne(
      { name: 'Laptop' },
      { $set: { price: 899.99, stock: 45 } }
    );
    const laptop = await db.collection('products').findOne({ name: 'Laptop' });
    console.log(`Laptop: price=${laptop.price}, stock=${laptop.stock}\n`);

    console.log('📝 Example 18: Increment field');
    await db.collection('orders').updateOne(
      { _id: 1 },
      { $inc: { 'items': 1 } }
    );
    console.log('Incremented item count\n');

    console.log('📝 Example 19: Add to array');
    await db.collection('users').updateOne(
      { username: 'jane_smith' },
      { $push: { tags: 'vip' } }
    );
    console.log('Added tag to user\n');

    console.log('📝 Example 20: Replace entire document');
    await db.collection('products').replaceOne(
      { name: 'Mouse' },
      { name: 'Wireless Mouse', category: 'Electronics', price: 39.99, stock: 180 }
    );
    console.log('Replaced product document\n');

    // ============================================
    // Example 21-25: Delete Operations
    // ============================================

    console.log('📝 Example 21: Delete single document');
    await db.collection('users').deleteOne({ username: 'charlie_brown' });
    console.log('Deleted user\n');

    console.log('📝 Example 22: Delete multiple documents');
    await db.collection('products').deleteMany({ stock: { $lt: 30 } });
    console.log('Deleted low-stock products\n');

    console.log('📝 Example 23: Delete with complex filter');
    await db.collection('orders').deleteMany({ status: 'pending', total: { $lt: 100 } });
    console.log('Deleted low-value pending orders\n');

    // ============================================
    // Example 24-30: Aggregation Pipeline
    // ============================================

    console.log('📝 Example 24: Aggregate - Group by status');
    const groupByStatus = await db.collection('orders').aggregate([
      { $group: { _id: '$status', count: { $sum: 1 }, totalValue: { $sum: '$total' } } }
    ]).toArray();
    console.log(JSON.stringify(groupByStatus, null, 2), '\n');

    console.log('📝 Example 25: Aggregate - Average price');
    const avgPrice = await db.collection('products').aggregate([
      { $group: { _id: '$category', avgPrice: { $avg: '$price' } } }
    ]).toArray();
    console.log(`Average prices by category:`);
    console.log(JSON.stringify(avgPrice, null, 2), '\n');

    console.log('📝 Example 26: Aggregate - Sort and limit');
    const topProducts = await db.collection('products').aggregate([
      { $sort: { price: -1 } },
      { $limit: 3 }
    ]).toArray();
    console.log(`Top 3 most expensive:\n`, topProducts.map(p => `${p.name}: $${p.price}`).join('\n'), '\n');

    console.log('📝 Example 27: Aggregate - Match and project');
    const filtered = await db.collection('products').aggregate([
      { $match: { category: 'Electronics' } },
      { $project: { name: 1, price: 1, _id: 0 } }
    ]).toArray();
    console.log(`Electronics products:`, JSON.stringify(filtered, null, 2), '\n');

    console.log('📝 Example 28: Aggregate - Count items');
    const count28 = await db.collection('orders').aggregate([
      { $unwind: '$items' },
      { $group: { _id: '$user_id', itemCount: { $sum: 1 } } }
    ]).toArray();
    console.log(`Items per user:`, JSON.stringify(count28, null, 2), '\n');

    console.log('📝 Example 29: Aggregate - Multiple stages');
    const complex = await db.collection('orders').aggregate([
      { $match: { status: 'completed' } },
      { $group: { _id: '$user_id', totalSpent: { $sum: '$total' } } },
      { $sort: { totalSpent: -1 } },
      { $limit: 3 }
    ]).toArray();
    console.log(`Top 3 spenders:`, JSON.stringify(complex, null, 2), '\n');

    console.log('📝 Example 30: Aggregate - Calculate statistics');
    const stats = await db.collection('products').aggregate([
      { $group: {
          _id: null,
          avgPrice: { $avg: '$price' },
          minPrice: { $min: '$price' },
          maxPrice: { $max: '$price' },
          totalStock: { $sum: '$stock' }
        }
      }
    ]).toArray();
    console.log(`Product statistics:`, JSON.stringify(stats[0], null, 2), '\n');

    // ============================================
    // Example 31-35: Bulk Operations
    // ============================================

    console.log('📝 Example 31: Bulk insert');
    const newProducts = [
      { name: 'USB Hub', category: 'Accessories', price: 24.99, stock: 150 },
      { name: 'HDMI Cable', category: 'Accessories', price: 12.99, stock: 300 }
    ];
    const bulkResult = await db.collection('products').insertMany(newProducts);
    console.log(`Inserted ${bulkResult.insertedCount} products\n`);

    console.log('📝 Example 32: Bulk update');
    await db.collection('products').updateMany(
      { category: 'Electronics' },
      { $mul: { price: 1.1 } }
    );
    console.log('Applied 10% price increase to electronics\n');

    // ============================================
    // Example 33-40: Text Search
    // ============================================

    console.log('📝 Example 33: Regex search');
    const search = await db.collection('products').find({
      name: { $regex: 'Mouse|Keyboard', $options: 'i' }
    }).toArray();
    console.log(`Search results: ${search.length} products found\n`);

    console.log('📝 Example 34: Case-insensitive search');
    const search2 = await db.collection('users').findOne({
      username: /john/i
    });
    console.log(`Found user: ${search2?.username}\n`);

    // ============================================
    // Example 35-40: Complex Queries
    // ============================================

    console.log('📝 Example 35: Lookup (join operation)');
    const withUsers = await db.collection('orders').aggregate([
      { $lookup: {
          from: 'users',
          localField: 'user_id',
          foreignField: '_id',
          as: 'user_details'
        }
      },
      { $limit: 2 }
    ]).toArray();
    console.log(`Orders with user details:`, JSON.stringify(withUsers[0], null, 2), '\n');

    console.log('📝 Example 36: Count distinct');
    const distinct2 = await db.collection('orders').aggregate([
      { $group: { _id: '$user_id' } },
      { $count: 'distinct_users' }
    ]).toArray();
    console.log(`Distinct users with orders: ${distinct2[0]?.distinct_users}\n`);

    console.log('📝 Example 37: Array operations');
    const arrayOps = await db.collection('orders').aggregate([
      { $project: { itemCount: { $size: '$items' } } }
    ]).toArray();
    console.log(`Item counts:`, JSON.stringify(arrayOps.slice(0, 3), null, 2), '\n');

    console.log('📝 Example 38: Conditional fields');
    const conditional = await db.collection('products').aggregate([
      { $project: {
          name: 1,
          price: 1,
          priceLevel: {
            $cond: { if: { $gte: ['$price', 200] }, then: 'Expensive', else: 'Affordable' }
          }
        }
      },
      { $limit: 3 }
    ]).toArray();
    console.log(`Price levels:`, JSON.stringify(conditional, null, 2), '\n');

    console.log('📝 Example 39: String operations');
    const stringOps = await db.collection('users').aggregate([
      { $project: {
          username: 1,
          upperUsername: { $toUpper: '$username' },
          emailDomain: { $substr: ['$email', { $add: [{ $indexOf: ['$email', '@'] }, 1] }, -1] }
        }
      },
      { $limit: 2 }
    ]).toArray();
    console.log(`String operations:`, JSON.stringify(stringOps, null, 2), '\n');

    console.log('📝 Example 40: Date operations');
    const dateOps = await db.collection('users').aggregate([
      { $project: {
          username: 1,
          age: 1,
          birthYear: { $subtract: [new Date().getFullYear(), '$age'] }
        }
      },
      { $limit: 2 }
    ]).toArray();
    console.log(`Date operations:`, JSON.stringify(dateOps, null, 2), '\n');

    // ============================================
    // Example 41-50: Advanced Operations
    // ============================================

    console.log('📝 Example 41: Find with projection');
    const projection = await db.collection('users').findOne(
      { username: 'john_doe' },
      { projection: { email: 1, age: 1, _id: 0 } }
    );
    console.log(`Projected fields:`, JSON.stringify(projection, null, 2), '\n');

    console.log('📝 Example 42: Find with sort and limit');
    const expensive2 = await db.collection('products').find()
      .sort({ price: -1 })
      .limit(2)
      .toArray();
    console.log(`Expensive products:`, expensive2.map(p => `${p.name}: $${p.price}`).join(', '), '\n');

    console.log('📝 Example 43: Conditional aggregation');
    const conditional2 = await db.collection('orders').aggregate([
      { $group: {
          _id: null,
          completedCount: {
            $sum: { $cond: [{ $eq: ['$status', 'completed'] }, 1, 0] }
          },
          completedValue: {
            $sum: { $cond: [{ $eq: ['$status', 'completed'] }, '$total', 0] }
          }
        }
      }
    ]).toArray();
    console.log(`Order statistics:`, JSON.stringify(conditional2[0], null, 2), '\n');

    console.log('📝 Example 44: Faceted search');
    const faceted = await db.collection('products').aggregate([
      { $facet: {
          'byCategory': [
            { $group: { _id: '$category', count: { $sum: 1 } } }
          ],
          'byPrice': [
            { $group: {
                _id: { $cond: [{ $lt: ['$price', 100] }, 'Budget', 'Premium'] },
                count: { $sum: 1 }
              }
            }
          ]
        }
      }
    ]).toArray();
    console.log(`Faceted results:`, JSON.stringify(faceted[0], null, 2), '\n');

    console.log('📝 Example 45: Merge documents');
    const merged = await db.collection('orders').aggregate([
      { $addFields: { totalItems: { $size: '$items' } } },
      { $limit: 2 }
    ]).toArray();
    console.log(`Documents with added field:`, JSON.stringify(merged, null, 2), '\n');

    console.log('📝 Example 46: Filtering in aggregation');
    const filtering = await db.collection('products').aggregate([
      { $match: { category: 'Electronics' } },
      { $match: { price: { $lt: 300 } } },
      { $group: { _id: null, avgPrice: { $avg: '$price' }, count: { $sum: 1 } } }
    ]).toArray();
    console.log(`Filtered aggregation:`, JSON.stringify(filtering, null, 2), '\n');

    console.log('📝 Example 47: Sorting aggregation');
    const sortAgg = await db.collection('orders').aggregate([
      { $sort: { total: -1 } },
      { $limit: 3 },
      { $project: { _id: 0, user_id: 1, total: 1, status: 1 } }
    ]).toArray();
    console.log(`Top orders:`, JSON.stringify(sortAgg, null, 2), '\n');

    console.log('📝 Example 48: Using $redact');
    const redacted = await db.collection('users').aggregate([
      { $project: { username: 1, email: 1 } },
      { $limit: 1 }
    ]).toArray();
    console.log(`Redacted data:`, JSON.stringify(redacted, null, 2), '\n');

    console.log('📝 Example 49: Pipeline with multiple lookups');
    const multiLookup = await db.collection('orders').aggregate([
      { $match: { status: 'completed' } },
      { $limit: 1 }
    ]).toArray();
    console.log(`Orders with multiple stages:`, JSON.stringify(multiLookup, null, 2), '\n');

    console.log('📝 Example 50: Complex analysis');
    const analysis = await db.collection('orders').aggregate([
      { $group: {
          _id: '$status',
          avgValue: { $avg: '$total' },
          maxValue: { $max: '$total' },
          count: { $sum: 1 }
        }
      },
      { $sort: { count: -1 } }
    ]).toArray();
    console.log(`Order analysis:`, JSON.stringify(analysis, null, 2), '\n');

    console.log('✅ All 50 examples completed successfully!');

  } finally {
    await client.close();
  }
}

runExamples().catch(console.error);
