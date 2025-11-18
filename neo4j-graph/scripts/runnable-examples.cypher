// Neo4j 50 Runnable Examples

// Setup: Create nodes
CREATE (u1:User {id: 1, name: 'John', age: 28})
CREATE (u2:User {id: 2, name: 'Jane', age: 32})
CREATE (p1:Product {id: 1, name: 'Laptop', price: 999.99})
CREATE (p2:Product {id: 2, name: 'Mouse', price: 29.99})
CREATE (p3:Product {id: 3, name: 'Keyboard', price: 79.99});

// Example 1-5: Basic queries
MATCH (n:User) RETURN n;
MATCH (p:Product) RETURN p.name, p.price;
MATCH (u:User {name: 'John'}) RETURN u;
MATCH (n) RETURN COUNT(n);

// Example 6-10: Relationships
MATCH (u:User), (p:Product) WHERE u.id = 1 AND p.id = 1 CREATE (u)-[:PURCHASED]->(p);
MATCH (u:User)-[:PURCHASED]->(p:Product) RETURN u.name, p.name;
MATCH (u:User)-[r:PURCHASED]->(p:Product) RETURN u, r, p;

// Example 11-15: Aggregations
MATCH (u:User)-[:PURCHASED]->(p:Product) RETURN u.name, COUNT(p) as purchases;
MATCH (p:Product) RETURN AVG(p.price) as avg_price;
MATCH (:User)-[:PURCHASED]->(p:Product) RETURN p.name, COUNT(*) as times_purchased;

// Example 16-20: Updates
MATCH (u:User {name: 'John'}) SET u.age = 29;
MATCH (p:Product {name: 'Laptop'}) SET p.price = 899.99;
MATCH (u:User {name: 'Jane'}) REMOVE u.age;

// Example 21-25: Complex patterns
MATCH (u1:User)-[:PURCHASED]->(p:Product)<-[:PURCHASED]-(u2:User) RETURN u1.name, p.name, u2.name;
MATCH (u:User)-[:PURCHASED]->(p:Product) WHERE p.price > 100 RETURN u.name, p.name;
MATCH p=(u:User)-[:PURCHASED]->(p:Product) RETURN length(p);

// Example 26-30: More operations
MATCH (u:User) RETURN u ORDER BY u.age DESC;
MATCH (u:User) RETURN DISTINCT u.name;
MATCH (p:Product) RETURN p LIMIT 5;

// Example 31-35: Delete operations
MATCH (u:User {name: 'John'})-[r:PURCHASED]->(p:Product) DELETE r;
MATCH (p:Product {price: 29.99}) DELETE p;

// Example 36-40: Sorting and limiting
MATCH (p:Product) RETURN p.name, p.price ORDER BY p.price LIMIT 3;
MATCH (u:User) RETURN u SKIP 1 LIMIT 2;

// Example 41-45: String operations
MATCH (u:User) WHERE u.name STARTS WITH 'J' RETURN u.name;
MATCH (p:Product) WHERE p.name CONTAINS 'top' RETURN p.name;

// Example 46-50: Advanced
MATCH (n) RETURN DISTINCT labels(n);
MATCH (u:User)-[r]->(p:Product) RETURN type(r);
MATCH (u:User)-[r:PURCHASED {since: date()}]->(p:Product) RETURN u, p;
MATCH (u:User) RETURN u.name, SIZE((u)-[:PURCHASED]->()) as purchase_count;
MATCH p=shortestPath((u1:User)-[*]-(u2:User)) WHERE u1 <> u2 RETURN length(p);
