// MongoDB Initialization Script
// Creates database, collections, and sample data

// Switch to education database
db = db.getSiblingDB('education_db');

// Create collections with validation
db.createCollection("users", {
    validator: {
        $jsonSchema: {
            bsonType: "object",
            required: ["username", "email", "createdAt"],
            properties: {
                username: {
                    bsonType: "string",
                    description: "Username must be a string and is required"
                },
                email: {
                    bsonType: "string",
                    pattern: "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$",
                    description: "Email must be a valid email address"
                },
                status: {
                    enum: ["active", "inactive", "suspended"],
                    description: "Status must be one of the enum values"
                },
                profile: {
                    bsonType: "object",
                    properties: {
                        fullName: { bsonType: "string" },
                        age: { bsonType: "int", minimum: 0, maximum: 150 },
                        location: {
                            bsonType: "object",
                            properties: {
                                city: { bsonType: "string" },
                                country: { bsonType: "string" },
                                coordinates: {
                                    bsonType: "object",
                                    properties: {
                                        lat: { bsonType: "double" },
                                        lng: { bsonType: "double" }
                                    }
                                }
                            }
                        }
                    }
                },
                preferences: { bsonType: "object" },
                createdAt: { bsonType: "date" },
                updatedAt: { bsonType: "date" },
                lastLogin: { bsonType: "date" }
            }
        }
    }
});

db.createCollection("products", {
    validator: {
        $jsonSchema: {
            bsonType: "object",
            required: ["sku", "name", "price", "createdAt"],
            properties: {
                sku: {
                    bsonType: "string",
                    description: "SKU is required"
                },
                name: {
                    bsonType: "string",
                    minLength: 1,
                    description: "Product name is required"
                },
                price: {
                    bsonType: "double",
                    minimum: 0,
                    description: "Price must be non-negative"
                },
                category: { bsonType: "string" },
                tags: {
                    bsonType: "array",
                    items: { bsonType: "string" }
                },
                inventory: {
                    bsonType: "object",
                    properties: {
                        quantity: { bsonType: "int", minimum: 0 },
                        warehouse: { bsonType: "string" }
                    }
                },
                specifications: { bsonType: "object" },
                reviews: {
                    bsonType: "array",
                    items: {
                        bsonType: "object",
                        properties: {
                            userId: { bsonType: "objectId" },
                            rating: { bsonType: "int", minimum: 1, maximum: 5 },
                            comment: { bsonType: "string" },
                            date: { bsonType: "date" }
                        }
                    }
                }
            }
        }
    }
});

db.createCollection("orders", {
    validator: {
        $jsonSchema: {
            bsonType: "object",
            required: ["userId", "orderNumber", "items", "total", "createdAt"],
            properties: {
                userId: { bsonType: "objectId" },
                orderNumber: { bsonType: "string" },
                items: {
                    bsonType: "array",
                    minItems: 1,
                    items: {
                        bsonType: "object",
                        required: ["productId", "quantity", "price"],
                        properties: {
                            productId: { bsonType: "objectId" },
                            quantity: { bsonType: "int", minimum: 1 },
                            price: { bsonType: "double", minimum: 0 }
                        }
                    }
                },
                total: { bsonType: "double", minimum: 0 },
                status: {
                    enum: ["pending", "processing", "shipped", "delivered", "cancelled"]
                },
                shipping: {
                    bsonType: "object",
                    properties: {
                        address: { bsonType: "string" },
                        city: { bsonType: "string" },
                        country: { bsonType: "string" },
                        postalCode: { bsonType: "string" }
                    }
                },
                payment: {
                    bsonType: "object",
                    properties: {
                        method: { bsonType: "string" },
                        transactionId: { bsonType: "string" },
                        status: { bsonType: "string" }
                    }
                }
            }
        }
    }
});

// Embedded pattern: Blog posts with comments
db.createCollection("blog_posts", {
    validator: {
        $jsonSchema: {
            bsonType: "object",
            required: ["title", "content", "authorId", "createdAt"],
            properties: {
                title: { bsonType: "string" },
                content: { bsonType: "string" },
                authorId: { bsonType: "objectId" },
                tags: { bsonType: "array", items: { bsonType: "string" } },
                comments: {
                    bsonType: "array",
                    items: {
                        bsonType: "object",
                        properties: {
                            userId: { bsonType: "objectId" },
                            text: { bsonType: "string" },
                            createdAt: { bsonType: "date" },
                            likes: { bsonType: "int" }
                        }
                    }
                },
                metadata: {
                    bsonType: "object",
                    properties: {
                        views: { bsonType: "int" },
                        likes: { bsonType: "int" },
                        shares: { bsonType: "int" }
                    }
                }
            }
        }
    }
});

// Time-series pattern: Events
db.createCollection("events", {
    timeseries: {
        timeField: "timestamp",
        metaField: "metadata",
        granularity: "minutes"
    }
});

print("Collections created successfully");

// Create indexes
print("Creating indexes...");

// Users indexes
db.users.createIndex({ "username": 1 }, { unique: true });
db.users.createIndex({ "email": 1 }, { unique: true });
db.users.createIndex({ "status": 1 });
db.users.createIndex({ "createdAt": -1 });
db.users.createIndex({ "profile.location.city": 1 });
db.users.createIndex({
    "profile.fullName": "text",
    "username": "text"
}, {
    name: "text_search_index"
});

// Products indexes
db.products.createIndex({ "sku": 1 }, { unique: true });
db.products.createIndex({ "category": 1, "price": -1 });
db.products.createIndex({ "tags": 1 });
db.products.createIndex({ "inventory.quantity": 1 });
db.products.createIndex({
    "name": "text",
    "category": "text"
}, {
    name: "product_text_search"
});
db.products.createIndex({ "reviews.rating": 1 });

// Orders indexes
db.orders.createIndex({ "userId": 1, "createdAt": -1 });
db.orders.createIndex({ "orderNumber": 1 }, { unique: true });
db.orders.createIndex({ "status": 1 });
db.orders.createIndex({ "items.productId": 1 });
db.orders.createIndex({ "createdAt": -1 });

// Blog posts indexes
db.blog_posts.createIndex({ "authorId": 1, "createdAt": -1 });
db.blog_posts.createIndex({ "tags": 1 });
db.blog_posts.createIndex({
    "title": "text",
    "content": "text"
}, {
    name: "blog_text_search"
});

// Events indexes
db.events.createIndex({ "timestamp": -1 });
db.events.createIndex({ "metadata.type": 1, "timestamp": -1 });

print("Indexes created successfully");
print("Database initialization complete");
