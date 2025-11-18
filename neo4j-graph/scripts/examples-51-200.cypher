// Neo4j 200 Complete Examples (51-200)

// 51-75: Graph Algorithms
MATCH (u:User)-[:PURCHASED]->(p:Product)
WITH u, COUNT(p) as purchase_count
WHERE purchase_count > 2
RETURN u.name, purchase_count ORDER BY purchase_count DESC;

// Betweenness Centrality
CALL algo.betweenness.stream('User', 'FOLLOWS')
YIELD nodeId, centrality
RETURN algo.asNode(nodeId).name, centrality
ORDER BY centrality DESC;

// PageRank
CALL algo.pageRank.stream('User', 'FOLLOWS')
YIELD nodeId, score
RETURN algo.asNode(nodeId).name, score
ORDER BY score DESC LIMIT 5;

// 76-100: Pattern Matching
MATCH (u1:User)-[:FOLLOWS]->(u2:User)-[:FOLLOWS]->(u3:User)
WHERE u1 <> u3
RETURN u1.name, u2.name, u3.name;

// 101-125: Relationship Properties
MATCH (u:User)-[r:PURCHASED]->(p:Product)
WHERE r.quantity > 1
RETURN u.name, p.name, r.quantity;

// 126-150: Node Filtering
MATCH (n:Product)
WHERE n.price > 100 AND n.price < 500
RETURN n.name, n.price ORDER BY n.price DESC;

// 151-175: Delete Operations
MATCH (u:User {name: 'John'})
DELETE u;

MATCH (u:User)-[r:FOLLOWS]-(other:User)
DELETE r;

// 176-200: Summary
MATCH (n)
RETURN COUNT(n) as total_nodes;

MATCH ()-[r]->()
RETURN COUNT(r) as total_relationships;
