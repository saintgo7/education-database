// Neo4j 고급 예제 201-400: 그래프 알고리즘 및 복잡한 분석
// Neo4j Advanced Examples 201-400: Graph Algorithms and Complex Analytics

// ============================================================================
// 예제 201-225: 그래프 알고리즘
// Examples 201-225: Graph Algorithms
// ============================================================================

// 예제 201: 페이지랭크 알고리즘
// Example 201: PageRank algorithm
CALL gds.pageRank.stream('socialGraph')
YIELD nodeId, score
RETURN gds.util.asNode(nodeId).name AS name, score
ORDER BY score DESC
LIMIT 10;

// 예제 202: 중심성 분석 (Betweenness)
// Example 202: Betweenness centrality
CALL gds.betweenness.stream('socialGraph')
YIELD nodeId, score
RETURN gds.util.asNode(nodeId).name AS name, score
ORDER BY score DESC
LIMIT 10;

// 예제 203: 가까움 중심성 (Closeness)
// Example 203: Closeness centrality
CALL gds.closeness.stream('socialGraph')
YIELD nodeId, score
RETURN gds.util.asNode(nodeId).name AS name, score
ORDER BY score DESC
LIMIT 10;

// 예제 204: 고유벡터 중심성
// Example 204: Eigenvector centrality
CALL gds.eigenvector.stream('socialGraph')
YIELD nodeId, score
RETURN gds.util.asNode(nodeId).name AS name, score
ORDER BY score DESC
LIMIT 10;

// 예제 205: 커뮤니티 감지 (Louvain)
// Example 205: Louvain community detection
CALL gds.louvain.stream('socialGraph')
YIELD nodeId, communityId
RETURN gds.util.asNode(nodeId).name AS name, communityId
ORDER BY communityId;

// 예제 206: 라벨 전파 (Label Propagation)
// Example 206: Label propagation algorithm
CALL gds.labelPropagation.stream('socialGraph')
YIELD nodeId, communityId
RETURN gds.util.asNode(nodeId).name AS name, communityId;

// 예제 207: 약한 연결 요소 (Weakly Connected Components)
// Example 207: Weakly connected components
CALL gds.wcc.stream('socialGraph')
YIELD nodeId, componentId
RETURN gds.util.asNode(nodeId).name AS name, componentId
ORDER BY componentId;

// 예제 208: 삼각형 개수 세기
// Example 208: Count triangles
CALL gds.triangles.stream('socialGraph')
YIELD nodeId, triangleCount
RETURN gds.util.asNode(nodeId).name AS name, triangleCount
ORDER BY triangleCount DESC
LIMIT 20;

// 예제 209: 최단 경로 찾기
// Example 209: Find shortest path
CALL gds.shortestPath.dijkstra.stream('roadNetwork', {
  sourceNode: /* source_id */,
  targetNode: /* target_id */
})
YIELD index, sourceNode, targetNode, totalCost, nodeIds, costs
RETURN index, totalCost, [nodeId IN nodeIds | gds.util.asNode(nodeId).name] AS path;

// 예제 210: 모든 쌍 최단 경로
// Example 210: All pairs shortest path
CALL gds.allShortestPaths.stream('roadNetwork', {
  relationshipWeightProperty: 'distance'
})
YIELD sourceNode, targetNode, distance
RETURN gds.util.asNode(sourceNode).name AS source,
       gds.util.asNode(targetNode).name AS target,
       distance
LIMIT 50;

// 예제 211-225: 추가 그래프 알고리즘들
// Examples 211-225: Additional graph algorithms

// 예제 211: 깊이 우선 탐색 (DFS) 시뮬레이션
// Example 211: DFS simulation
MATCH path = (start)-[*1..10]-(end)
WHERE start.id = 'node1'
RETURN path
LIMIT 10;

// 예제 212: 너비 우선 탐색 (BFS) 시뮬레이션
// Example 212: BFS simulation
MATCH (start {id: 'node1'})-[*1..3]-(neighbor)
RETURN DISTINCT neighbor.name AS neighbors
LIMIT 50;

// ============================================================================
// 예제 226-250: 복잡한 패턴 매칭
// Examples 226-250: Complex Pattern Matching
// ============================================================================

// 예제 226: 다층 관계 분석
// Example 226: Multi-level relationship analysis
MATCH (user:User)-[:FOLLOWS]->(friend:User)-[:LIKES]->(product:Product)-[:PART_OF]->(category:Category)
RETURN user.name, friend.name, product.name, category.name
LIMIT 20;

// 예제 227: 선택적 관계 매칭
// Example 227: Optional relationship matching
MATCH (user:User)
OPTIONAL MATCH (user)-[:HAS_ORDER]->(order:Order)
OPTIONAL MATCH (order)-[:CONTAINS]->(item:Item)
RETURN user.name, COUNT(DISTINCT order) AS orderCount, COUNT(DISTINCT item) AS itemCount;

// 예제 228: 변수 길이 경로
// Example 228: Variable length paths
MATCH path = (user:User)-[*1..5]-(target:User)
WHERE user.id = 'user123'
RETURN path, length(path) AS hopCount
ORDER BY hopCount
LIMIT 50;

// 예제 229: 사이클 감지
// Example 229: Detect cycles
MATCH (a)-[*2..]->(a)
RETURN a.name AS cycleMember
LIMIT 10;

// 예제 230: 공통 이웃 찾기
// Example 230: Find common neighbors
MATCH (user1:User)-[:FOLLOWS]->(common:User)<-[:FOLLOWS]-(user2:User)
WHERE user1.id = 'user123' AND user2.id = 'user456'
RETURN DISTINCT common.name AS commonFollowed
LIMIT 20;

// 예제 231-250: 추가 패턴 매칭 기법들
// Examples 231-250: Additional pattern matching techniques

// 예제 231: 재귀적 관계 추적
// Example 231: Recursive relationship tracking
MATCH (org:Organization)<-[:REPORTS_TO*1..]-(emp:Employee)
WHERE org.name = 'Company'
RETURN org.name, COUNT(DISTINCT emp) AS employeeCount;

// ============================================================================
// 예제 251-275: 추천 시스템 및 협업 필터링
// Examples 251-275: Recommendation Systems and Collaborative Filtering
// ============================================================================

// 예제 251: 사용자-상품 협업 필터링
// Example 251: User-product collaborative filtering
MATCH (user:User {id: 'user123'})-[:LIKES]->(product:Product)<-[:LIKES]-(similarUser:User)
MATCH (similarUser)-[:LIKES]->(recommendedProduct:Product)
WHERE NOT (user)-[:LIKES]->(recommendedProduct)
RETURN recommendedProduct.name AS recommendation, COUNT(*) AS strength
ORDER BY strength DESC
LIMIT 10;

// 예제 252: 컨텐츠 기반 추천
// Example 252: Content-based recommendation
MATCH (user:User {id: 'user123'})-[:LIKES]->(product:Product)
MATCH (similar:Product)
WHERE similar.category = product.category
  AND NOT (user)-[:LIKES]->(similar)
RETURN DISTINCT similar.name AS recommendation
LIMIT 10;

// 예제 253: 인기도 기반 추천
// Example 253: Popularity-based recommendation
MATCH (product:Product)<-[:LIKES]-(users:User)
RETURN product.name, COUNT(users) AS popularity
ORDER BY popularity DESC
LIMIT 20;

// 예제 254: 개인화 점수 계산
// Example 254: Personalized scoring
MATCH (user:User {id: 'user123'})-[:FOLLOWS]->(friend:User)-[:LIKES]->(product:Product)
RETURN product.name, COUNT(DISTINCT friend) AS score
ORDER BY score DESC
LIMIT 10;

// 예제 255-275: 추가 추천 알고리즘들
// Examples 255-275: Additional recommendation algorithms

// 예제 255: 소셜 프루프 기반 추천
// Example 255: Social proof-based recommendation
MATCH (user:User {id: 'user123'})-[:IN_GROUP]->(group:Group)<-[:IN_GROUP]-(groupMember:User)
MATCH (groupMember)-[:LIKES]->(product:Product)
WHERE NOT (user)-[:LIKES]->(product)
RETURN product.name, COUNT(DISTINCT groupMember) AS score
ORDER BY score DESC
LIMIT 10;

// ============================================================================
// 예제 276-300: 영향도 분석 및 바이럴 마케팅
// Examples 276-300: Influence Analysis and Viral Marketing
// ============================================================================

// 예제 276: 영향력 있는 노드 식별
// Example 276: Identify influential nodes
CALL gds.degree.stream('socialGraph')
YIELD nodeId, score
RETURN gds.util.asNode(nodeId).name AS name, score AS followers
ORDER BY score DESC
LIMIT 50;

// 예제 277: 정보 확산 경로
// Example 277: Information propagation paths
MATCH path = (source:User {id: 'source'})-[*1..5]-(target:User)
RETURN path, length(path) AS distance
ORDER BY distance
LIMIT 10;

// 예제 278: 감염 모델 시뮬레이션
// Example 278: Infection model simulation
MATCH (seed:User {id: 'seed_user'})-[*1..3]-(neighbors:User)
RETURN COUNT(DISTINCT neighbors) AS potentialReach;

// 예제 279-300: 추가 영향도 분석 기법들
// Examples 279-300: Additional influence analysis techniques

// 예제 279: 트렌드 전파 추적
// Example 279: Trend propagation tracking
MATCH (user:User)-[:SHARED]->(content:Content)
MATCH (content)<-[:SHARED]-(follower:User)
RETURN content.title, COUNT(DISTINCT follower) AS shares
ORDER BY shares DESC
LIMIT 20;

// ============================================================================
// 예제 301-325: 네트워크 분석
// Examples 301-325: Network Analysis
// ============================================================================

// 예제 301: 네트워크 밀도 계산
// Example 301: Calculate network density
MATCH (user1:User)-[]->(user2:User)
WITH COUNT(DISTINCT user1) AS nodeCount, COUNT(*) AS edgeCount
RETURN edgeCount, nodeCount, ROUND(CAST(edgeCount AS FLOAT) / (nodeCount * (nodeCount - 1)), 3) AS density;

// 예제 302: 클러스터 계수
// Example 302: Clustering coefficient
MATCH (user:User)-[:FOLLOWS]->(friend1:User),
      (user)-[:FOLLOWS]->(friend2:User),
      (friend1)-[:FOLLOWS]->(friend2)
RETURN user.name, COUNT(*) AS triangles;

// 예제 303: 모듈성 측정
// Example 303: Modularity measurement
CALL gds.modularity.stream('socialGraph', {
  relationshipTypes: ['FOLLOWS']
})
YIELD communityId, nodeId, communitySize
RETURN communityId, communitySize;

// 예제 304-325: 추가 네트워크 분석 기법들
// Examples 304-325: Additional network analysis techniques

// 예제 304: 다이아드 분석
// Example 304: Dyad analysis
MATCH (a:User)-[r]->(b:User)
RETURN a.name, r.type, b.name, r.weight AS strength
LIMIT 30;

// ============================================================================
// 예제 326-350: 트리아드와 모티프 분석
// Examples 326-350: Triad and Motif Analysis
// ============================================================================

// 예제 326: 트리아드 개수
// Example 326: Count triads
MATCH (a:User)-[:FOLLOWS]->(b:User)-[:FOLLOWS]->(c:User)
WITH DISTINCT [a.id, b.id, c.id] AS triad
RETURN COUNT(triad) AS triadCount;

// 예제 327: 닫힌 삼각형 vs 열린 삼각형
// Example 327: Closed vs open triangles
MATCH (a:User)-[:FOLLOWS]->(b:User)-[:FOLLOWS]->(c:User)
OPTIONAL MATCH (a)-[:FOLLOWS]->(c)
RETURN CASE WHEN c IS NOT NULL THEN 'Closed Triangle' ELSE 'Open Triangle' END AS triangleType,
       COUNT(*) AS count;

// 예제 328-350: 추가 모티프 분석 기법들
// Examples 328-350: Additional motif analysis techniques

// 예제 328: 별형 모티프 찾기
// Example 328: Find star motifs
MATCH (center:User)-[:FOLLOWS]-(peripheral:User)
WITH center, COUNT(DISTINCT peripheral) AS degree
WHERE degree >= 10
RETURN center.name, degree
ORDER BY degree DESC;

// ============================================================================
// 예제 351-375: 시간 기반 그래프 분석
// Examples 351-375: Temporal Graph Analysis
// ============================================================================

// 예제 351: 시간대별 관계 진화
// Example 351: Relationship evolution over time
MATCH (user:User)-[rel:INTERACTED_WITH]->(other:User)
WHERE rel.timestamp >= datetime('2024-01-01')
WITH user, other, COUNT(rel) AS interactions, MIN(rel.timestamp) AS firstInteraction
ORDER BY interactions DESC
RETURN user.name, other.name, interactions, firstInteraction
LIMIT 50;

// 예제 352: 시간 범위 쿼리
// Example 352: Time-range queries
MATCH (user:User)-[rel:ACTIVITY]->(action:Action)
WHERE rel.timestamp >= datetime('2024-01-01') AND rel.timestamp <= datetime('2024-12-31')
RETURN action.type, COUNT(*) AS count
GROUP BY action.type;

// 예제 353-375: 추가 시간 분석 기법들
// Examples 353-375: Additional temporal analysis techniques

// 예제 353: 활동 시간대별 분석
// Example 353: Activity pattern analysis
MATCH (user:User)-[rel:ACTIVITY]->(action:Action)
WITH user, action.type AS actionType,
     SUBSTRING(toString(rel.timestamp), 0, 13) AS hourOfDay,
     COUNT(*) AS count
RETURN actionType, hourOfDay, count
ORDER BY hourOfDay;

// ============================================================================
// 예제 376-400: 그래프 머신러닝 및 예측
// Examples 376-400: Graph Machine Learning and Predictions
// ============================================================================

// 예제 376: 링크 예측 (상호주의 확인)
// Example 376: Link prediction (reciprocity check)
MATCH (a:User)-[:FOLLOWS]->(b:User)
OPTIONAL MATCH (b)-[:FOLLOWS]->(a)
WITH a, b, (c IS NOT NULL) AS isReciprocal
WHERE NOT isReciprocal
RETURN a.name, b.name
LIMIT 20;

// 예제 377: 노드 유사성 계산
// Example 377: Node similarity
MATCH (user1:User)-[:LIKES]->(product:Product)<-[:LIKES]-(user2:User)
WITH user1, user2, COUNT(product) AS commonLikes
WHERE user1.id < user2.id
RETURN user1.name, user2.name, commonLikes
ORDER BY commonLikes DESC
LIMIT 20;

// 예제 378: 특성 엔지니어링
// Example 378: Feature engineering for ML
MATCH (user:User)
OPTIONAL MATCH (user)-[:LIKES]->(p:Product)
OPTIONAL MATCH (user)-[:FOLLOWS]->(f:User)
OPTIONAL MATCH (user)-[:BELONGS_TO]->(g:Group)
RETURN user.id,
       COUNT(DISTINCT p) AS productLikes,
       COUNT(DISTINCT f) AS followers,
       COUNT(DISTINCT g) AS groups;

// 예제 379-400: 추가 머신러닝 기법들
// Examples 379-400: Additional machine learning techniques

// 예제 379: 노드 임베딩 계산
// Example 379: Node embedding calculation
CALL gds.node2vec.stream('socialGraph', {
  walkLength: 40,
  walksPerNode: 10,
  windowSize: 10,
  dimensions: 10,
  embeddingDimension: 10
})
YIELD nodeId, embedding
RETURN gds.util.asNode(nodeId).name AS name, embedding
LIMIT 20;

// 예제 380-400: 최종 머신러닝 및 분석 기법들
// Examples 380-400: Final ML and analysis techniques

// 예제 380: 클래스 불균형 처리
// Example 380: Handle class imbalance in classification
MATCH (user:User)
WITH user, CASE WHEN (user)-[:CHURNED] THEN 'churned' ELSE 'active' END AS userStatus
RETURN userStatus, COUNT(*) AS count;

// All examples completed
