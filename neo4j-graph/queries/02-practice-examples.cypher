// Neo4j 50 Practice Examples (Cypher)

// ============================================
// 1-10: Node Operations
// ============================================

// 1. Create single node
CREATE (u:User {name: 'John Doe', email: 'john@example.com'});

// 2. Create multiple nodes
CREATE (u:User {name: 'Jane Smith'}), (p:Product {name: 'Laptop'});

// 3. Create node with properties
CREATE (u:User {
  name: 'Bob Wilson',
  email: 'bob@example.com',
  created_at: timestamp(),
  age: 30
});

// 4. Create node with return
CREATE (u:User {name: 'Alice Johnson'}) RETURN u;

// 5. Match single node
MATCH (u:User {name: 'John Doe'}) RETURN u;

// 6. Match multiple nodes
MATCH (u:User), (p:Product) RETURN u, p;

// 7. Match with WHERE clause
MATCH (u:User) WHERE u.age > 25 RETURN u;

// 8. Match with OPTIONAL MATCH
MATCH (u:User) OPTIONAL MATCH (u)-[:PURCHASED]->(p:Product) RETURN u, p;

// 9. Delete node
MATCH (u:User {name: 'Alice Johnson'}) DELETE u;

// 10. Delete multiple nodes
MATCH (u:User) WHERE u.age < 18 DELETE u;

// ============================================
// 11-20: Relationship Operations
// ============================================

// 11. Create relationship
MATCH (u:User {name: 'John Doe'}), (p:Product {name: 'Laptop'})
CREATE (u)-[:PURCHASED]->(p);

// 12. Create relationship with properties
MATCH (u:User {name: 'Jane Smith'}), (p:Product {name: 'Laptop'})
CREATE (u)-[:PURCHASED {date: date(), quantity: 1}]->(p);

// 13. Match relationship
MATCH (u:User)-[:PURCHASED]->(p:Product) RETURN u, p;

// 14. Match with relationship direction
MATCH (u:User)<-[:PURCHASED]-(p:Product) RETURN u, p;

// 15. Match ignoring direction
MATCH (u:User)-[:PURCHASED]-(p:Product) RETURN u, p;

// 16. Match multiple relationships
MATCH (u:User)-[:PURCHASED]->(p:Product)-[:IN_CATEGORY]->(c:Category)
RETURN u, p, c;

// 17. Create multiple relationships
MATCH (u:User {name: 'John Doe'}), (p1:Product {name: 'Laptop'}), (p2:Product {name: 'Mouse'})
CREATE (u)-[:PURCHASED]->(p1), (u)-[:PURCHASED]->(p2);

// 18. Update relationship properties
MATCH (u:User)-[r:PURCHASED]->(p:Product)
SET r.quantity = 2, r.date = date()
RETURN r;

// 19. Delete relationship
MATCH (u:User)-[r:PURCHASED]->(p:Product {name: 'Laptop'})
DELETE r;

// 20. Delete all relationships of type
MATCH (u:User)-[r:PURCHASED]->()
DELETE r;

// ============================================
// 21-30: Path Traversal and Graph Patterns
// ============================================

// 21. Simple path
MATCH p = (u:User)-[:PURCHASED]->(p:Product) RETURN p;

// 22. Variable-length path
MATCH (u:User)-[:FOLLOWS*1..3]->(other:User) RETURN u, other;

// 23. Shortest path
MATCH p = shortestPath((u:User)-[*]->(p:Product)) RETURN p;

// 24. All shortest paths
MATCH p = allShortestPaths((u:User)-[*]->(p:Product)) RETURN p;

// 25. Relationship with property filter
MATCH (u:User)-[r:PURCHASED {quantity: 1}]->(p:Product) RETURN u, p;

// 26. Complex path with multiple relationships
MATCH (u:User)-[:PURCHASED]->(p:Product)<-[:SIMILAR_TO]-(other:Product)
RETURN u, p, other;

// 27. Path with WHERE on relationships
MATCH (u:User)-[r:PURCHASED]->(p:Product)
WHERE r.date > date('2024-01-01')
RETURN u, p, r;

// 28. Collect nodes from path
MATCH p = (u:User)-[:PURCHASED*]->(p:Product)
RETURN nodes(p) as path_nodes;

// 29. Relationship length in path
MATCH (u:User)-[rs:FOLLOWS*]->(other:User)
RETURN length(rs) as hop_count;

// 30. Extract relationships from path
MATCH p = (u:User)-[:PURCHASED]->(p:Product)
RETURN relationships(p) as rels;

// ============================================
// 31-40: Aggregations and Collections
// ============================================

// 31. COUNT aggregation
MATCH (u:User) RETURN COUNT(u) as total_users;

// 32. COUNT DISTINCT
MATCH (u:User)-[:PURCHASED]->(p:Product)
RETURN COUNT(DISTINCT u) as users_who_purchased;

// 33. COLLECT function
MATCH (u:User)-[:PURCHASED]->(p:Product)
RETURN u.name, COLLECT(p.name) as products;

// 34. SUM aggregation
MATCH (u:User)-[r:PURCHASED]->(p:Product)
RETURN u.name, SUM(r.quantity) as total_quantity;

// 35. AVG aggregation
MATCH (u:User)-[r:PURCHASED]->(p:Product)
RETURN u.name, AVG(r.quantity) as avg_quantity;

// 36. MIN/MAX aggregation
MATCH (p:Product)<-[r:PURCHASED]-(u:User)
RETURN p.name, MIN(r.quantity) as min_qty, MAX(r.quantity) as max_qty;

// 37. Group aggregates
MATCH (u:User)-[:PURCHASED]->(p:Product)
RETURN u.name, COUNT(p) as product_count
ORDER BY product_count DESC;

// 38. Collect with DISTINCT
MATCH (u:User)-[:FOLLOWS]->(other:User)
RETURN COLLECT(DISTINCT other.name) as followers;

// 39. Using LIMIT
MATCH (u:User)-[:PURCHASED]->(p:Product)
RETURN u.name, COUNT(p) as product_count
ORDER BY product_count DESC
LIMIT 10;

// 40. Using SKIP and LIMIT (pagination)
MATCH (u:User) RETURN u
SKIP 10 LIMIT 5;

// ============================================
// 41-50: Advanced Graph Queries
// ============================================

// 41. Recommendation query
MATCH (u:User)-[:PURCHASED]->(p:Product)<-[:PURCHASED]-(other:User)
WHERE u <> other
RETURN DISTINCT other.name as recommended_user;

// 42. Community detection (simple)
MATCH (u:User)-[:FOLLOWS]-(other:User)
WITH u, COUNT(other) as follower_count
WHERE follower_count > 5
RETURN u.name, follower_count;

// 43. Transitive relationships
MATCH (u:User)-[:FOLLOWS*1..]->(distant:User)
RETURN DISTINCT u.name, distant.name;

// 44. Create indexes
CREATE INDEX ON :User(email);

// 45. Unique constraint
CREATE CONSTRAINT ON (u:User) ASSERT u.email IS UNIQUE;

// 46. Update node properties
MATCH (u:User {name: 'John Doe'})
SET u.age = 31, u.updated_at = timestamp();

// 47. Remove node properties
MATCH (u:User {name: 'John Doe'})
REMOVE u.age, u.updated_at;

// 48. CASE statement
MATCH (u:User)
RETURN u.name,
CASE
  WHEN u.age < 18 THEN 'Minor'
  WHEN u.age >= 18 AND u.age < 65 THEN 'Adult'
  ELSE 'Senior'
END as age_group;

// 49. Graph statistics
MATCH (n) RETURN labels(n) as node_type, COUNT(n) as count GROUP BY labels(n);

// 50. Performance query with EXPLAIN
EXPLAIN MATCH (u:User)-[:PURCHASED]->(p:Product)
RETURN u.name, p.name;
