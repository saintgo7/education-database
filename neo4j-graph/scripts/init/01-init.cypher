// Neo4j Initialization Script - Cypher Queries

// Create User nodes
CREATE (john:User {id: 'U001', name: 'John Doe', email: 'john@example.com', created_at: timestamp()}),
       (jane:User {id: 'U002', name: 'Jane Smith', email: 'jane@example.com', created_at: timestamp()}),
       (bob:User {id: 'U003', name: 'Bob Johnson', email: 'bob@example.com', created_at: timestamp()});

// Create Product nodes
CREATE (headphones:Product {id: 'P001', name: 'Wireless Headphones', price: 199.99, category: 'Electronics'}),
       (keyboard:Product {id: 'P002', name: 'Mechanical Keyboard', price: 129.99, category: 'Electronics'}),
       (monitor:Product {id: 'P003', name: 'Portable Monitor', price: 299.99, category: 'Electronics'});

// Create relationships
MATCH (john:User {name: 'John Doe'}), (headphones:Product {name: 'Wireless Headphones'})
CREATE (john)-[:PURCHASED {date: timestamp(), rating: 5}]->(headphones);

MATCH (jane:User {name: 'Jane Smith'}), (keyboard:Product {name: 'Mechanical Keyboard'})
CREATE (jane)-[:PURCHASED {date: timestamp(), rating: 4}]->(keyboard);

MATCH (john:User {name: 'John Doe'}), (jane:User {name: 'Jane Smith'})
CREATE (john)-[:FOLLOWS {since: timestamp()}]->(jane);

MATCH (headphones:Product {name: 'Wireless Headphones'}), (keyboard:Product {name: 'Mechanical Keyboard'})
CREATE (headphones)-[:RELATED_TO]->(keyboard);

// Create indexes
CREATE INDEX user_id_index IF NOT EXISTS FOR (u:User) ON (u.id);
CREATE INDEX product_id_index IF NOT EXISTS FOR (p:Product) ON (p.id);

// Return summary
RETURN 'Neo4j initialization complete' AS status;
