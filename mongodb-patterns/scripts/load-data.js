// MongoDB Sample Data Generation
// Generates 1000+ documents for testing

db = db.getSiblingDB('education_db');

print("Generating sample data...");

// Generate 500 users
print("Generating 500 users...");
const users = [];
const cities = ["Seoul", "Busan", "Incheon", "Daegu", "Gwangju", "Daejeon", "Ulsan"];
const countries = ["South Korea", "USA", "Japan", "China", "Singapore"];

for (let i = 1; i <= 500; i++) {
    users.push({
        username: `user_${i}`,
        email: `user_${i}@example.com`,
        status: ["active", "active", "active", "inactive"][Math.floor(Math.random() * 4)],
        profile: {
            fullName: `User ${i} Full Name`,
            age: Math.floor(Math.random() * 60) + 18,
            location: {
                city: cities[Math.floor(Math.random() * cities.length)],
                country: countries[Math.floor(Math.random() * countries.length)],
                coordinates: {
                    lat: Math.random() * 180 - 90,
                    lng: Math.random() * 360 - 180
                }
            },
            bio: `This is the bio for user ${i}. Passionate about technology and learning.`,
            website: `https://user${i}.example.com`
        },
        preferences: {
            theme: ["light", "dark", "auto"][Math.floor(Math.random() * 3)],
            language: ["en", "ko", "ja", "zh"][Math.floor(Math.random() * 4)],
            notifications: Math.random() > 0.5,
            newsletter: Math.random() > 0.3,
            timezone: "Asia/Seoul"
        },
        createdAt: new Date(Date.now() - Math.random() * 365 * 24 * 60 * 60 * 1000),
        updatedAt: new Date(),
        lastLogin: new Date(Date.now() - Math.random() * 30 * 24 * 60 * 60 * 1000)
    });
}
db.users.insertMany(users);
print(`✓ Inserted ${users.length} users`);

// Get user IDs for references
const userDocs = db.users.find().toArray();
const userIds = userDocs.map(u => u._id);

// Generate 300 products
print("Generating 300 products...");
const products = [];
const categories = ["Electronics", "Computers", "Accessories", "Audio", "Peripherals", "Gaming"];
const brands = ["TechCorp", "InnovateTech", "SmartDevices", "ProGear", "EliteGadgets"];
const productTypes = ["Laptop", "Smartphone", "Tablet", "Headphones", "Keyboard", "Mouse", "Monitor", "Webcam", "Speaker", "Charger"];

for (let i = 1; i <= 300; i++) {
    const category = categories[Math.floor(Math.random() * categories.length)];
    const productType = productTypes[Math.floor(Math.random() * productTypes.length)];
    const brand = brands[Math.floor(Math.random() * brands.length)];

    const numReviews = Math.floor(Math.random() * 10);
    const reviews = [];
    for (let j = 0; j < numReviews; j++) {
        reviews.push({
            userId: userIds[Math.floor(Math.random() * userIds.length)],
            rating: Math.floor(Math.random() * 5) + 1,
            comment: `This is a review comment for product ${i}. ${["Great product!", "Good value", "Excellent quality", "Highly recommend"][Math.floor(Math.random() * 4)]}`,
            date: new Date(Date.now() - Math.random() * 180 * 24 * 60 * 60 * 1000),
            helpful: Math.floor(Math.random() * 50)
        });
    }

    products.push({
        sku: `SKU-${String(i).padStart(6, '0')}`,
        name: `${brand} ${productType} ${["Pro", "Plus", "Max", "Ultra", "Standard"][Math.floor(Math.random() * 5)]}`,
        description: `High-quality ${productType.toLowerCase()} with excellent features and performance. Perfect for professionals and enthusiasts.`,
        price: Math.round((Math.random() * 2000 + 10) * 100) / 100,
        category: category,
        tags: [
            category.toLowerCase(),
            productType.toLowerCase(),
            brand.toLowerCase(),
            Math.random() > 0.5 ? "featured" : "regular",
            Math.random() > 0.7 ? "bestseller" : null
        ].filter(Boolean),
        inventory: {
            quantity: Math.floor(Math.random() * 500),
            warehouse: ["Seoul-Main", "Busan-Central", "Incheon-Hub"][Math.floor(Math.random() * 3)],
            reorderLevel: 10,
            supplier: brand
        },
        specifications: {
            brand: brand,
            color: ["Black", "White", "Silver", "Blue", "Red"][Math.floor(Math.random() * 5)],
            weight: Math.round((Math.random() * 5 + 0.1) * 100) / 100,
            dimensions: {
                length: Math.round(Math.random() * 50 + 10),
                width: Math.round(Math.random() * 40 + 5),
                height: Math.round(Math.random() * 30 + 2)
            },
            warranty: `${[1, 2, 3][Math.floor(Math.random() * 3)]} years`
        },
        reviews: reviews,
        stats: {
            averageRating: reviews.length > 0 ?
                Math.round((reviews.reduce((sum, r) => sum + r.rating, 0) / reviews.length) * 10) / 10 : 0,
            totalReviews: reviews.length,
            totalSold: Math.floor(Math.random() * 1000)
        },
        createdAt: new Date(Date.now() - Math.random() * 365 * 24 * 60 * 60 * 1000),
        updatedAt: new Date()
    });
}
db.products.insertMany(products);
print(`✓ Inserted ${products.length} products`);

// Get product IDs for references
const productDocs = db.products.find().toArray();
const productIds = productDocs.map(p => p._id);

// Generate 1000 orders
print("Generating 1000 orders...");
const statuses = ["pending", "processing", "shipped", "delivered", "delivered", "delivered", "cancelled"];
const paymentMethods = ["credit_card", "paypal", "bank_transfer", "crypto"];

const orderBatches = [];
for (let i = 0; i < 10; i++) {
    const batch = [];
    for (let j = 0; j < 100; j++) {
        const orderId = i * 100 + j + 1;
        const userId = userIds[Math.floor(Math.random() * userIds.length)];
        const numItems = Math.floor(Math.random() * 5) + 1;
        const items = [];
        let total = 0;

        for (let k = 0; k < numItems; k++) {
            const product = productDocs[Math.floor(Math.random() * productDocs.length)];
            const quantity = Math.floor(Math.random() * 3) + 1;
            const price = product.price;
            items.push({
                productId: product._id,
                productName: product.name,
                quantity: quantity,
                price: price,
                subtotal: Math.round(quantity * price * 100) / 100
            });
            total += quantity * price;
        }

        const orderDate = new Date(Date.now() - Math.random() * 180 * 24 * 60 * 60 * 1000);
        const status = statuses[Math.floor(Math.random() * statuses.length)];

        batch.push({
            userId: userId,
            orderNumber: `ORD-${new Date(orderDate).toISOString().slice(0, 10).replace(/-/g, '')}-${String(orderId).padStart(6, '0')}`,
            items: items,
            total: Math.round(total * 100) / 100,
            status: status,
            shipping: {
                address: `${100 + orderId} Main Street`,
                city: cities[Math.floor(Math.random() * cities.length)],
                country: "South Korea",
                postalCode: String(Math.floor(Math.random() * 100000)).padStart(5, '0'),
                method: ["standard", "express", "overnight"][Math.floor(Math.random() * 3)]
            },
            payment: {
                method: paymentMethods[Math.floor(Math.random() * paymentMethods.length)],
                transactionId: `TXN-${Date.now()}-${orderId}`,
                status: status === "cancelled" ? "refunded" : "completed"
            },
            timeline: {
                ordered: orderDate,
                processed: status !== "pending" ? new Date(orderDate.getTime() + 24 * 60 * 60 * 1000) : null,
                shipped: ["shipped", "delivered"].includes(status) ? new Date(orderDate.getTime() + 48 * 60 * 60 * 1000) : null,
                delivered: status === "delivered" ? new Date(orderDate.getTime() + 120 * 60 * 60 * 1000) : null
            },
            createdAt: orderDate,
            updatedAt: new Date()
        });
    }
    orderBatches.push(batch);
}

// Insert orders in batches
orderBatches.forEach((batch, index) => {
    db.orders.insertMany(batch);
    print(`  Batch ${index + 1}/10 complete`);
});
print(`✓ Inserted 1000 orders`);

// Generate 200 blog posts with comments
print("Generating 200 blog posts...");
const blogPosts = [];
const blogTags = ["technology", "tutorial", "review", "news", "opinion", "guide", "best-practices"];

for (let i = 1; i <= 200; i++) {
    const numComments = Math.floor(Math.random() * 20);
    const comments = [];

    for (let j = 0; j < numComments; j++) {
        comments.push({
            userId: userIds[Math.floor(Math.random() * userIds.length)],
            text: `This is comment ${j + 1} on blog post ${i}. ${["Great article!", "Thanks for sharing!", "Very informative", "Learned a lot"][Math.floor(Math.random() * 4)]}`,
            createdAt: new Date(Date.now() - Math.random() * 90 * 24 * 60 * 60 * 1000),
            likes: Math.floor(Math.random() * 30)
        });
    }

    blogPosts.push({
        title: `Blog Post ${i}: ${["Understanding", "Exploring", "Mastering", "Deep Dive into", "Guide to"][Math.floor(Math.random() * 5)]} Technology`,
        content: `This is the content of blog post ${i}. `.repeat(50),
        authorId: userIds[Math.floor(Math.random() * userIds.length)],
        tags: Array.from(
            { length: Math.floor(Math.random() * 3) + 1 },
            () => blogTags[Math.floor(Math.random() * blogTags.length)]
        ),
        comments: comments,
        metadata: {
            views: Math.floor(Math.random() * 10000),
            likes: Math.floor(Math.random() * 500),
            shares: Math.floor(Math.random() * 100),
            readTime: Math.floor(Math.random() * 15) + 3
        },
        published: Math.random() > 0.1,
        createdAt: new Date(Date.now() - Math.random() * 365 * 24 * 60 * 60 * 1000),
        updatedAt: new Date()
    });
}
db.blog_posts.insertMany(blogPosts);
print(`✓ Inserted ${blogPosts.length} blog posts`);

// Generate 5000 events (time-series)
print("Generating 5000 events...");
const eventTypes = ["page_view", "click", "purchase", "signup", "login", "logout"];
const eventBatches = [];

for (let i = 0; i < 50; i++) {
    const batch = [];
    for (let j = 0; j < 100; j++) {
        batch.push({
            timestamp: new Date(Date.now() - Math.random() * 30 * 24 * 60 * 60 * 1000),
            metadata: {
                type: eventTypes[Math.floor(Math.random() * eventTypes.length)],
                userId: userIds[Math.floor(Math.random() * userIds.length)],
                sessionId: `session-${Math.floor(Math.random() * 1000)}`,
                userAgent: "Mozilla/5.0",
                ip: `${Math.floor(Math.random() * 256)}.${Math.floor(Math.random() * 256)}.${Math.floor(Math.random() * 256)}.${Math.floor(Math.random() * 256)}`
            },
            data: {
                page: `/page-${Math.floor(Math.random() * 100)}`,
                duration: Math.floor(Math.random() * 300),
                device: ["mobile", "desktop", "tablet"][Math.floor(Math.random() * 3)]
            }
        });
    }
    eventBatches.push(batch);
}

eventBatches.forEach((batch, index) => {
    db.events.insertMany(batch);
    if ((index + 1) % 10 === 0) {
        print(`  Batch ${index + 1}/50 complete`);
    }
});
print(`✓ Inserted 5000 events`);

// Display summary
print("\n=== Data Generation Summary ===");
print(`Users: ${db.users.countDocuments()}`);
print(`Products: ${db.products.countDocuments()}`);
print(`Orders: ${db.orders.countDocuments()}`);
print(`Blog Posts: ${db.blog_posts.countDocuments()}`);
print(`Events: ${db.events.countDocuments()}`);
print("\n✓ Sample data loaded successfully!");
