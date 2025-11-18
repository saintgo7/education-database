// MongoDB Schema Design Patterns
// Demonstrates various data modeling approaches

db = db.getSiblingDB('education_db');

print("=== MongoDB Schema Design Patterns ===\n");

// ============================================
// Pattern 1: Embedded Documents (One-to-Few)
// ============================================

print("1. Embedded Documents Pattern");
print("Use case: Product reviews embedded in product document");

// Query: Find products with high ratings
const highRatedProducts = db.products.find({
    "reviews.rating": { $gte: 4 },
    "reviews": { $exists: true, $ne: [] }
}, {
    name: 1,
    category: 1,
    "stats.averageRating": 1,
    "reviews": 1
}).limit(5);

print("Products with reviews rated 4+:");
highRatedProducts.forEach(p => printjson(p));

// Update embedded document
db.products.updateOne(
    { sku: "SKU-000001" },
    {
        $push: {
            reviews: {
                userId: db.users.findOne()._id,
                rating: 5,
                comment: "Excellent product!",
                date: new Date(),
                helpful: 0
            }
        }
    }
);
print("✓ Added review to product\n");

// ============================================
// Pattern 2: Reference Pattern (One-to-Many)
// ============================================

print("2. Reference Pattern");
print("Use case: Orders reference users and products");

// Query with $lookup (JOIN)
const userOrders = db.orders.aggregate([
    { $match: { status: "delivered" } },
    { $limit: 5 },
    {
        $lookup: {
            from: "users",
            localField: "userId",
            foreignField: "_id",
            as: "user"
        }
    },
    { $unwind: "$user" },
    {
        $project: {
            orderNumber: 1,
            "user.username": 1,
            "user.email": 1,
            total: 1,
            itemCount: { $size: "$items" }
        }
    }
]).toArray();

print("Orders with user information:");
userOrders.forEach(o => printjson(o));
print("");

// ============================================
// Pattern 3: Extended Reference (Denormalization)
// ============================================

print("3. Extended Reference Pattern");
print("Use case: Store frequently accessed fields to avoid lookups");

// Order items include productName (denormalized)
const ordersWithProductNames = db.orders.find({}, {
    orderNumber: 1,
    "items.productName": 1,
    "items.quantity": 1,
    "items.price": 1
}).limit(3);

print("Orders with denormalized product names:");
ordersWithProductNames.forEach(o => printjson(o));
print("");

// ============================================
// Pattern 4: Subset Pattern
// ============================================

print("4. Subset Pattern");
print("Use case: Blog posts with comment summary");

// Store only recent comments in main document
const blogWithComments = db.blog_posts.findOne(
    { comments: { $exists: true, $ne: [] } },
    {
        title: 1,
        "metadata.views": 1,
        "metadata.likes": 1,
        recentComments: { $slice: ["$comments", -5] }
    }
);

print("Blog post with 5 most recent comments:");
printjson(blogWithComments);
print("");

// ============================================
// Pattern 5: Computed Pattern
// ============================================

print("5. Computed Pattern");
print("Use case: Pre-calculated statistics");

// Products have pre-computed average ratings
const productsWithStats = db.products.find(
    { "stats.totalReviews": { $gt: 0 } },
    {
        name: 1,
        price: 1,
        "stats.averageRating": 1,
        "stats.totalReviews": 1,
        "stats.totalSold": 1
    }
).limit(5);

print("Products with computed statistics:");
productsWithStats.forEach(p => printjson(p));
print("");

// ============================================
// Pattern 6: Bucket Pattern
// ============================================

print("6. Bucket Pattern");
print("Use case: Time-series data bucketing");

// Events bucketed by type
const eventsBucketed = db.events.aggregate([
    {
        $group: {
            _id: {
                type: "$metadata.type",
                hour: { $hour: "$timestamp" }
            },
            count: { $sum: 1 },
            avgDuration: { $avg: "$data.duration" }
        }
    },
    { $sort: { "_id.type": 1, "_id.hour": 1 } },
    { $limit: 10 }
]).toArray();

print("Events bucketed by type and hour:");
eventsBucketed.forEach(e => printjson(e));
print("");

// ============================================
// Pattern 7: Schema Versioning
// ============================================

print("7. Schema Versioning Pattern");
print("Use case: Track document schema version for migrations");

// Add schema version to documents
db.users.updateMany(
    { schemaVersion: { $exists: false } },
    { $set: { schemaVersion: 1 } },
    { upsert: false }
);

const versionedUser = db.users.findOne(
    {},
    { username: 1, email: 1, schemaVersion: 1 }
);

print("User with schema version:");
printjson(versionedUser);
print("");

// ============================================
// Pattern 8: Polymorphic Pattern
// ============================================

print("8. Polymorphic Pattern");
print("Use case: Different product types in one collection");

// Insert different product types
db.products.insertOne({
    sku: "BOOK-001",
    name: "MongoDB Design Patterns Book",
    type: "book",
    price: 39.99,
    category: "Books",
    bookSpecific: {
        author: "Author Name",
        isbn: "978-1234567890",
        pages: 350,
        publisher: "Tech Publisher"
    },
    createdAt: new Date()
});

// Query by type
const books = db.products.find({ type: "book" }, { name: 1, bookSpecific: 1 });
print("Books in product collection:");
books.forEach(b => printjson(b));
print("");

// ============================================
// Pattern 9: Attribute Pattern
// ============================================

print("9. Attribute Pattern");
print("Use case: Products with varying specifications");

// Transform specifications to searchable format
const productWithAttributes = db.products.findOne(
    { specifications: { $exists: true } },
    { name: 1, specifications: 1 }
);

print("Product with varying specifications:");
printjson(productWithAttributes);

// Alternative: Store as array of key-value pairs
db.products.updateOne(
    { sku: "SKU-000001" },
    {
        $set: {
            attributesArray: [
                { key: "brand", value: "TechCorp" },
                { key: "color", value: "Black" },
                { key: "warranty", value: "2 years" }
            ]
        }
    }
);
print("✓ Added attributesArray field\n");

// ============================================
// Pattern 10: Outlier Pattern
// ============================================

print("10. Outlier Pattern");
print("Use case: Handle documents with extreme values");

// Mark orders with unusually high number of items
db.orders.updateMany(
    { $expr: { $gt: [{ $size: "$items" }, 10] } },
    { $set: { outlier: true, outlierReason: "high_item_count" } }
);

const outlierOrders = db.orders.find(
    { outlier: true },
    { orderNumber: 1, itemCount: { $size: "$items" }, outlier: 1 }
);

print("Outlier orders:");
outlierOrders.forEach(o => printjson(o));
print("");

// ============================================
// Best Practices Summary
// ============================================

print("=== Schema Design Best Practices ===");
print("1. Embed for one-to-few relationships");
print("2. Reference for one-to-many relationships");
print("3. Denormalize frequently accessed data");
print("4. Use subset pattern for large arrays");
print("5. Pre-compute expensive calculations");
print("6. Bucket time-series data");
print("7. Version your schemas for migrations");
print("8. Use polymorphic pattern for variants");
print("9. Attribute pattern for varying fields");
print("10. Handle outliers separately");
