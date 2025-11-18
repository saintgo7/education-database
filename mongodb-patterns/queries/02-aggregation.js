// MongoDB Aggregation Pipeline Examples
// Advanced data processing and analytics

db = db.getSiblingDB('education_db');

print("=== MongoDB Aggregation Pipelines ===\n");

// ============================================
// 1. Basic Aggregation
// ============================================

print("1. Basic Aggregation - Count by Category");
const categoryCount = db.products.aggregate([
    { $group: { _id: "$category", count: { $sum: 1 }, avgPrice: { $avg: "$price" } } },
    { $sort: { count: -1 } }
]).toArray();

printjson(categoryCount);
print("");

// ============================================
// 2. $match and $project
// ============================================

print("2. Filter and Shape Documents");
const activeUsers = db.users.aggregate([
    { $match: { status: "active" } },
    { $project: {
        username: 1,
        email: 1,
        city: "$profile.location.city",
        accountAge: {
            $dateDiff: {
                startDate: "$createdAt",
                endDate: new Date(),
                unit: "day"
            }
        }
    }},
    { $limit: 5 }
]).toArray();

printjson(activeUsers);
print("");

// ============================================
// 3. $lookup (JOIN)
// ============================================

print("3. Join Collections - Orders with User Details");
const ordersWithUsers = db.orders.aggregate([
    { $match: { status: "delivered" } },
    { $lookup: {
        from: "users",
        localField: "userId",
        foreignField: "_id",
        as: "customer"
    }},
    { $unwind: "$customer" },
    { $project: {
        orderNumber: 1,
        total: 1,
        "customer.username": 1,
        "customer.email": 1,
        "customer.profile.location.city": 1
    }},
    { $limit: 3 }
]).toArray();

printjson(ordersWithUsers);
print("");

// ============================================
// 4. $unwind Array Fields
// ============================================

print("4. Unwind Order Items");
const orderItems = db.orders.aggregate([
    { $match: { status: "delivered" } },
    { $limit: 2 },
    { $unwind: "$items" },
    { $project: {
        orderNumber: 1,
        productName: "$items.productName",
        quantity: "$items.quantity",
        price: "$items.price",
        subtotal: "$items.subtotal"
    }}
]).toArray();

printjson(orderItems);
print("");

// ============================================
// 5. Multi-stage Group By
// ============================================

print("5. Revenue by Category and Month");
const revenueByMonth = db.orders.aggregate([
    { $match: { status: "delivered" } },
    { $unwind: "$items" },
    {
        $lookup: {
            from: "products",
            localField: "items.productId",
            foreignField: "_id",
            as: "product"
        }
    },
    { $unwind: "$product" },
    {
        $group: {
            _id: {
                category: "$product.category",
                month: { $month: "$createdAt" },
                year: { $year: "$createdAt" }
            },
            totalRevenue: { $sum: "$items.subtotal" },
            orderCount: { $sum: 1 },
            avgOrderValue: { $avg: "$items.subtotal" }
        }
    },
    { $sort: { "_id.year": -1, "_id.month": -1, "totalRevenue": -1 } },
    { $limit: 10 }
]).toArray();

printjson(revenueByMonth);
print("");

// ============================================
// 6. $facet - Multiple Aggregations
// ============================================

print("6. Multiple Aggregations with $facet");
const productAnalytics = db.products.aggregate([
    {
        $facet: {
            "byCategory": [
                { $group: { _id: "$category", count: { $sum: 1 }, avgPrice: { $avg: "$price" } } },
                { $sort: { avgPrice: -1 } }
            ],
            "priceRanges": [
                {
                    $bucket: {
                        groupBy: "$price",
                        boundaries: [0, 100, 500, 1000, 2000, 5000],
                        default: "5000+",
                        output: {
                            count: { $sum: 1 },
                            products: { $push: "$name" }
                        }
                    }
                }
            ],
            "topRated": [
                { $match: { "stats.averageRating": { $gte: 4 } } },
                { $sort: { "stats.averageRating": -1, "stats.totalReviews": -1 } },
                { $limit: 5 },
                { $project: { name: 1, "stats.averageRating": 1, "stats.totalReviews": 1 } }
            ]
        }
    }
]).toArray();

printjson(productAnalytics[0]);
print("");

// ============================================
// 7. $bucket - Histogram
// ============================================

print("7. Price Distribution Histogram");
const priceHistogram = db.products.aggregate([
    {
        $bucket: {
            groupBy: "$price",
            boundaries: [0, 100, 500, 1000, 2000],
            default: "2000+",
            output: {
                count: { $sum: 1 },
                avgPrice: { $avg: "$price" },
                minPrice: { $min: "$price" },
                maxPrice: { $max: "$price" }
            }
        }
    }
]).toArray();

printjson(priceHistogram);
print("");

// ============================================
// 8. $addFields and Computed Fields
// ============================================

print("8. Add Computed Fields");
const usersWithScores = db.users.aggregate([
    { $match: { status: "active" } },
    {
        $addFields: {
            accountDays: {
                $dateDiff: {
                    startDate: "$createdAt",
                    endDate: new Date(),
                    unit: "day"
                }
            },
            daysSinceLogin: {
                $dateDiff: {
                    startDate: "$lastLogin",
                    endDate: new Date(),
                    unit: "day"
                }
            }
        }
    },
    {
        $addFields: {
            engagementScore: {
                $cond: {
                    if: { $eq: ["$daysSinceLogin", 0] },
                    then: 100,
                    else: {
                        $multiply: [
                            { $divide: [1, { $add: ["$daysSinceLogin", 1] }] },
                            100
                        ]
                    }
                }
            }
        }
    },
    { $sort: { engagementScore: -1 } },
    { $limit: 5 },
    { $project: { username: 1, accountDays: 1, daysSinceLogin: 1, engagementScore: 1 } }
]).toArray();

printjson(usersWithScores);
print("");

// ============================================
// 9. Text Search Aggregation
// ============================================

print("9. Full-Text Search with Scoring");
const searchResults = db.products.aggregate([
    { $match: { $text: { $search: "laptop computer" } } },
    { $addFields: { score: { $meta: "textScore" } } },
    { $sort: { score: -1 } },
    { $limit: 5 },
    { $project: { name: 1, category: 1, price: 1, score: 1 } }
]).toArray();

printjson(searchResults);
print("");

// ============================================
// 10. Window Functions (MongoDB 5.0+)
// ============================================

print("10. Window Functions - Running Total");
const runningTotal = db.orders.aggregate([
    { $match: { status: "delivered" } },
    { $sort: { createdAt: 1 } },
    {
        $setWindowFields: {
            sortBy: { createdAt: 1 },
            output: {
                runningTotal: {
                    $sum: "$total",
                    window: {
                        documents: ["unbounded", "current"]
                    }
                },
                rank: {
                    $rank: {}
                }
            }
        }
    },
    { $limit: 10 },
    { $project: { orderNumber: 1, total: 1, runningTotal: 1, rank: 1, createdAt: 1 } }
]).toArray();

printjson(runningTotal);
print("");

// ============================================
// 11. Top N per Group
// ============================================

print("11. Top 3 Products per Category");
const topProductsPerCategory = db.products.aggregate([
    { $match: { "stats.totalSold": { $gt: 0 } } },
    { $sort: { category: 1, "stats.totalSold": -1 } },
    {
        $group: {
            _id: "$category",
            products: {
                $push: {
                    name: "$name",
                    sold: "$stats.totalSold",
                    price: "$price"
                }
            }
        }
    },
    {
        $project: {
            category: "$_id",
            topProducts: { $slice: ["$products", 3] }
        }
    }
]).toArray();

printjson(topProductsPerCategory);
print("");

// ============================================
// 12. Customer Lifetime Value
// ============================================

print("12. Customer Lifetime Value Analysis");
const customerLTV = db.orders.aggregate([
    { $match: { status: "delivered" } },
    {
        $group: {
            _id: "$userId",
            totalSpent: { $sum: "$total" },
            orderCount: { $sum: 1 },
            avgOrderValue: { $avg: "$total" },
            firstOrder: { $min: "$createdAt" },
            lastOrder: { $max: "$createdAt" }
        }
    },
    {
        $lookup: {
            from: "users",
            localField: "_id",
            foreignField: "_id",
            as: "user"
        }
    },
    { $unwind: "$user" },
    {
        $addFields: {
            daysBetweenOrders: {
                $dateDiff: {
                    startDate: "$firstOrder",
                    endDate: "$lastOrder",
                    unit: "day"
                }
            }
        }
    },
    { $sort: { totalSpent: -1 } },
    { $limit: 10 },
    {
        $project: {
            username: "$user.username",
            email: "$user.email",
            totalSpent: 1,
            orderCount: 1,
            avgOrderValue: { $round: ["$avgOrderValue", 2] },
            daysBetweenOrders: 1
        }
    }
]).toArray();

printjson(customerLTV);
print("");

// ============================================
// 13. Time-Series Analytics
// ============================================

print("13. Daily Event Statistics");
const dailyEvents = db.events.aggregate([
    {
        $group: {
            _id: {
                date: { $dateToString: { format: "%Y-%m-%d", date: "$timestamp" } },
                type: "$metadata.type"
            },
            count: { $sum: 1 },
            avgDuration: { $avg: "$data.duration" },
            devices: { $addToSet: "$data.device" }
        }
    },
    { $sort: { "_id.date": -1, "_id.type": 1 } },
    { $limit: 20 }
]).toArray();

printjson(dailyEvents);
print("");

// ============================================
// 14. Cohort Analysis
// ============================================

print("14. User Cohort Analysis by Signup Month");
const cohortAnalysis = db.users.aggregate([
    {
        $addFields: {
            cohort: {
                $dateToString: {
                    format: "%Y-%m",
                    date: "$createdAt"
                }
            }
        }
    },
    {
        $group: {
            _id: "$cohort",
            userCount: { $sum: 1 },
            activeUsers: {
                $sum: {
                    $cond: [{ $eq: ["$status", "active"] }, 1, 0]
                }
            }
        }
    },
    {
        $addFields: {
            activeRate: {
                $multiply: [
                    { $divide: ["$activeUsers", "$userCount"] },
                    100
                ]
            }
        }
    },
    { $sort: { _id: -1 } }
]).toArray();

printjson(cohortAnalysis);
print("");

// ============================================
// 15. Recommendation System (Simple)
// ============================================

print("15. Product Recommendations based on Co-purchases");
const recommendations = db.orders.aggregate([
    { $match: { status: "delivered" } },
    { $unwind: "$items" },
    {
        $group: {
            _id: "$items.productId",
            coProducts: {
                $push: "$items.productId"
            }
        }
    },
    { $unwind: "$coProducts" },
    {
        $match: {
            $expr: { $ne: ["$_id", "$coProducts"] }
        }
    },
    {
        $group: {
            _id: {
                product: "$_id",
                recommendation: "$coProducts"
            },
            frequency: { $sum: 1 }
        }
    },
    { $sort: { frequency: -1 } },
    {
        $group: {
            _id: "$_id.product",
            recommendations: {
                $push: {
                    productId: "$_id.recommendation",
                    frequency: "$frequency"
                }
            }
        }
    },
    {
        $project: {
            topRecommendations: { $slice: ["$recommendations", 3] }
        }
    },
    { $limit: 5 }
]).toArray();

printjson(recommendations);
print("");

print("=== Aggregation Complete ===");
