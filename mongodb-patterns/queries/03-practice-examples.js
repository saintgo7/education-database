// MongoDB 50 Practice Examples
// Comprehensive examples covering various MongoDB concepts

// Connect to database
use('education_db');

// ============================================
// 1-10: Basic CRUD Operations
// ============================================

// 1. Insert single document
db.users.insertOne({
  username: 'john_doe',
  email: 'john@example.com',
  status: 'active'
});

// 2. Insert multiple documents
db.users.insertMany([
  { username: 'jane_smith', email: 'jane@example.com', status: 'active' },
  { username: 'bob_wilson', email: 'bob@example.com', status: 'inactive' }
]);

// 3. Find all documents
db.users.find();

// 4. Find with filter
db.users.find({ status: 'active' });

// 5. Find single document
db.users.findOne({ username: 'john_doe' });

// 6. Find with projection
db.users.find({ status: 'active' }, { username: 1, email: 1, _id: 0 });

// 7. Find with limit
db.users.find().limit(5);

// 8. Find with sort
db.users.find().sort({ username: 1 });

// 9. Find with skip and limit (pagination)
db.users.find().skip(10).limit(5);

// 10. Update single document
db.users.updateOne(
  { username: 'john_doe' },
  { $set: { status: 'inactive' } }
);

// ============================================
// 11-20: Array and Object Operations
// ============================================

// 11. Push element to array
db.users.updateOne(
  { username: 'john_doe' },
  { $push: { tags: 'vip' } }
);

// 12. Push multiple elements to array
db.users.updateOne(
  { username: 'john_doe' },
  { $push: { tags: { $each: ['premium', 'verified'] } } }
);

// 13. Remove element from array
db.users.updateOne(
  { username: 'john_doe' },
  { $pull: { tags: 'vip' } }
);

// 14. Pop element from array
db.users.updateOne(
  { username: 'john_doe' },
  { $pop: { tags: 1 } }  // Remove last element
);

// 15. Update array element at index
db.users.updateOne(
  { username: 'john_doe' },
  { $set: { 'tags.0': 'newTag' } }
);

// 16. Add to numeric field
db.users.updateOne(
  { username: 'john_doe' },
  { $inc: { loginCount: 1 } }
);

// 17. Set default value if not exists
db.users.updateOne(
  { username: 'john_doe' },
  { $setOnInsert: { createdAt: new Date() } },
  { upsert: true }
);

// 18. Unset field
db.users.updateOne(
  { username: 'john_doe' },
  { $unset: { temporaryField: '' } }
);

// 19. Rename field
db.users.updateOne(
  { username: 'john_doe' },
  { $rename: { 'oldFieldName': 'newFieldName' } }
);

// 20. Delete document
db.users.deleteOne({ username: 'temp_user' });

// ============================================
// 21-30: Query Operators
// ============================================

// 21. Comparison operator: $eq (equal)
db.products.find({ category: { $eq: 'Electronics' } });

// 22. Comparison operator: $ne (not equal)
db.products.find({ category: { $ne: 'Electronics' } });

// 23. Comparison operator: $gt (greater than)
db.products.find({ price: { $gt: 100 } });

// 24. Comparison operator: $gte (greater than or equal)
db.products.find({ price: { $gte: 100 } });

// 25. Comparison operator: $lt (less than)
db.products.find({ price: { $lt: 100 } });

// 26. Comparison operator: $lte (less than or equal)
db.products.find({ price: { $lte: 100 } });

// 27. Comparison operator: $in (in array)
db.products.find({ category: { $in: ['Electronics', 'Books'] } });

// 28. Comparison operator: $nin (not in array)
db.products.find({ category: { $nin: ['Electronics', 'Books'] } });

// 29. Logical operator: $and
db.products.find({
  $and: [
    { price: { $gt: 50 } },
    { category: 'Electronics' }
  ]
});

// 30. Logical operator: $or
db.products.find({
  $or: [
    { price: { $gt: 500 } },
    { category: 'Premium' }
  ]
});

// ============================================
// 31-40: Aggregation Pipeline
// ============================================

// 31. $match stage - filter documents
db.orders.aggregate([
  { $match: { status: 'completed' } }
]);

// 32. $project stage - reshape documents
db.orders.aggregate([
  { $project: { customer_name: 1, total_amount: 1, _id: 0 } }
]);

// 33. $group stage - grouping
db.orders.aggregate([
  { $group: { _id: '$customer_id', totalSpent: { $sum: '$total_amount' } } }
]);

// 34. $sort stage - sorting
db.orders.aggregate([
  { $sort: { order_date: -1 } }
]);

// 35. $limit stage - limiting results
db.orders.aggregate([
  { $limit: 10 }
]);

// 36. $skip stage - skipping documents
db.orders.aggregate([
  { $skip: 10 }
]);

// 37. $lookup stage - join collections
db.orders.aggregate([
  { $lookup: {
      from: 'users',
      localField: 'customer_id',
      foreignField: '_id',
      as: 'customer'
    }
  }
]);

// 38. $unwind stage - flatten arrays
db.orders.aggregate([
  { $unwind: '$items' }
]);

// 39. Multiple aggregation stages
db.orders.aggregate([
  { $match: { status: 'completed' } },
  { $group: { _id: '$customer_id', total: { $sum: '$total_amount' } } },
  { $sort: { total: -1 } },
  { $limit: 5 }
]);

// 40. Aggregation with $facet (multiple pipelines)
db.orders.aggregate([
  { $facet: {
      'by_status': [
        { $group: { _id: '$status', count: { $sum: 1 } } }
      ],
      'by_customer': [
        { $group: { _id: '$customer_id', totalSpent: { $sum: '$total_amount' } } }
      ]
    }
  }
]);

// ============================================
// 41-50: Advanced Queries
// ============================================

// 41. Text search
db.products.find({ $text: { $search: 'wireless headphones' } });

// 42. Regex search
db.products.find({ name: /^Wireless/i });

// 43. Exists operator
db.users.find({ phone: { $exists: true } });

// 44. Type operator
db.users.find({ loginCount: { $type: 'int' } });

// 45. Array size operator
db.orders.find({ 'items': { $size: 3 } });

// 46. Array element match
db.orders.find({
  items: { $elemMatch: { price: { $gt: 50 } } }
});

// 47. Bulk write operations
db.orders.bulkWrite([
  { insertOne: { document: { customer_id: 'C001', total_amount: 250 } } },
  { updateOne: { filter: { _id: ObjectId('...') }, update: { $set: { status: 'shipped' } } } },
  { deleteOne: { filter: { _id: ObjectId('...') } } }
]);

// 48. Replace document
db.users.replaceOne(
  { username: 'old_user' },
  { username: 'new_user', email: 'new@example.com' }
);

// 49. Update many documents
db.products.updateMany(
  { category: 'Sale' },
  { $set: { discount: 0.2 } }
);

// 50. Complex aggregation with calculations
db.orders.aggregate([
  { $match: { order_date: { $gte: new Date('2024-01-01') } } },
  { $group: {
      _id: '$customer_id',
      totalOrders: { $sum: 1 },
      totalSpent: { $sum: '$total_amount' },
      avgOrderValue: { $avg: '$total_amount' },
      maxOrder: { $max: '$total_amount' },
      minOrder: { $min: '$total_amount' }
    }
  },
  { $sort: { totalSpent: -1 } },
  { $limit: 10 }
]);
