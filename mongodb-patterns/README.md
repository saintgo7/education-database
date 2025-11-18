# MongoDB Patterns

MongoDB schema design patterns, aggregation pipelines, and data modeling best practices.

## Features

- **Schema Design Patterns**: Embedded, Reference, Hybrid, Polymorphic
- **Aggregation Pipelines**: 15+ advanced aggregation examples
- **Data Modeling**: 1000+ sample documents across 5 collections
- **Text Search**: Full-text search indexes and queries
- **Time-Series**: Event tracking with time-series collection
- **Performance**: Indexes, query optimization, benchmarks

## Quick Start

```bash
# Start MongoDB
docker-compose up -d

# Load sample data
docker exec -i mongodb-patterns mongosh -u admin -p admin123 education_db < scripts/load-data.js

# Access Mongo Express (GUI)
# http://localhost:8081 (admin/admin)

# Access MongoDB Shell
docker exec -it mongodb-patterns mongosh -u admin -p admin123 education_db
```

## Collections

| Collection | Documents | Pattern | Purpose |
|------------|-----------|---------|---------|
| users | 500 | Reference | User profiles with embedded preferences |
| products | 300 | Embedded | Products with embedded reviews |
| orders | 1000 | Reference + Denormalization | Orders referencing users/products |
| blog_posts | 200 | Embedded | Posts with embedded comments |
| events | 5000 | Time-Series | Event tracking |

## Schema Patterns

### 1. Embedded Documents
```javascript
// Product with embedded reviews
{
  "_id": ObjectId("..."),
  "name": "Laptop Pro",
  "price": 1299.99,
  "reviews": [
    {
      "userId": ObjectId("..."),
      "rating": 5,
      "comment": "Excellent!",
      "date": ISODate("2025-01-15")
    }
  ]
}
```

### 2. Reference Pattern
```javascript
// Order references user and products
{
  "_id": ObjectId("..."),
  "userId": ObjectId("..."),  // Reference to users
  "items": [
    {
      "productId": ObjectId("..."),  // Reference to products
      "quantity": 2,
      "price": 99.99
    }
  ]
}
```

### 3. Extended Reference (Denormalization)
```javascript
// Order with denormalized product name
{
  "items": [
    {
      "productId": ObjectId("..."),
      "productName": "Laptop Pro",  // Denormalized for performance
      "quantity": 1,
      "price": 1299.99
    }
  ]
}
```

## Aggregation Examples

### Revenue by Category
```javascript
db.orders.aggregate([
  { $unwind: "$items" },
  { $lookup: {
      from: "products",
      localField: "items.productId",
      foreignField: "_id",
      as: "product"
  }},
  { $group: {
      _id: "$product.category",
      totalRevenue: { $sum: "$items.subtotal" }
  }}
])
```

### Customer Lifetime Value
```javascript
db.orders.aggregate([
  { $match: { status: "delivered" } },
  { $group: {
      _id: "$userId",
      totalSpent: { $sum: "$total" },
      orderCount: { $sum: 1 }
  }},
  { $lookup: {
      from: "users",
      localField: "_id",
      foreignField: "_id",
      as: "user"
  }},
  { $sort: { totalSpent: -1 } }
])
```

### Top Products per Category
```javascript
db.products.aggregate([
  { $sort: { category: 1, "stats.totalSold": -1 } },
  { $group: {
      _id: "$category",
      products: { $push: { name: "$name", sold: "$stats.totalSold" } }
  }},
  { $project: {
      topProducts: { $slice: ["$products", 3] }
  }}
])
```

## Indexes

```javascript
// Users
db.users.createIndex({ "username": 1 }, { unique: true })
db.users.createIndex({ "email": 1 }, { unique: true })
db.users.createIndex({ "profile.fullName": "text" })

// Products
db.products.createIndex({ "sku": 1 }, { unique: true })
db.products.createIndex({ "category": 1, "price": -1 })
db.products.createIndex({ "name": "text" })

// Orders
db.orders.createIndex({ "userId": 1, "createdAt": -1 })
db.orders.createIndex({ "status": 1 })
```

## Best Practices

1. **Embed for one-to-few** relationships (< 100 subdocuments)
2. **Reference for one-to-many** relationships
3. **Denormalize frequently accessed** data
4. **Use indexes** on query fields
5. **Limit embedded array size** to avoid document size limits (16MB)
6. **Use projection** to return only needed fields
7. **Aggregate efficiently** with $match early in pipeline

## Performance Tips

- Use `explain()` to analyze query performance
- Create compound indexes for multi-field queries
- Use covered queries (query + projection only need index)
- Avoid `$where` and JavaScript expressions
- Use aggregation pipeline instead of MapReduce
- Shard large collections (>100GB)

## File Structure

```
mongodb-patterns/
├── docker-compose.yml
├── config/mongod.conf
├── scripts/
│   ├── init/01-init.js
│   ├── load-data.js
│   ├── backup.sh
│   └── restore.sh
├── queries/
│   ├── 01-schema-patterns.js
│   └── 02-aggregation.js
└── README.md
```
