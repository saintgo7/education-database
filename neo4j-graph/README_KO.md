# Neo4j 그래프 (Neo4j Graph)

한국어 문서 | [English Document](./README.md)

## 개요

Neo4j 그래프 모듈은 그래프 데이터베이스의 모델링, 알고리즘, 및 분석에 대한 400개의 예제를 제공합니다.

## 예제 범위

### 기본 (Level 1: Examples 1-50)
- 노드 생성
- 관계 설정
- 기본 Cypher 쿼리
- 속성 관리

### 중급 (Level 2: Examples 51-200)
- 복잡한 패턴 매칭
- 경로 찾기
- 집계 쿼리
- 인덱싱 전략

### 고급 (Level 3: Examples 201-400)
- **그래프 알고리즘 (201-225)**
  - PageRank
  - 중심성 분석
  - 커뮤니티 감지
  - 최단 경로

- **추천 시스템 (226-275)**
  - 협업 필터링
  - 컨텐츠 기반 추천
  - 하이브리드 추천

- **네트워크 분석 (276-350)**
  - 영향도 분석
  - 정보 확산
  - 관계 강도 측정

- **머신러닝 (351-400)**
  - 특성 엔지니어링
  - 노드 임베딩
  - 연결 예측

## 빠른 시작

```bash
cd neo4j-graph
docker-compose up -d

# Neo4j 브라우저 접속
open http://localhost:7687
```

## 주요 기능

### 그래프 알고리즘
```cypher
-- PageRank 알고리즘
CALL gds.pageRank.stream('socialGraph')
YIELD nodeId, score
RETURN gds.util.asNode(nodeId).name AS name, score
ORDER BY score DESC
LIMIT 10;
```

### 추천 시스템
```cypher
-- 협업 필터링
MATCH (user:User {id: 'user123'})-[:LIKES]->(product:Product)<-[:LIKES]-(similarUser:User)
MATCH (similarUser)-[:LIKES]->(recommendedProduct:Product)
WHERE NOT (user)-[:LIKES]->(recommendedProduct)
RETURN recommendedProduct.name, COUNT(*) AS strength
ORDER BY strength DESC
LIMIT 10;
```

## 자주 묻는 질문

### Q: 그래프 알고리즘 vs SQL 쿼리?
**A:** 그래프 알고리즘이 훨씬 빠르고 직관적입니다. 특히 깊은 관계 탐색에서는 필수입니다.

---

**마지막 업데이트:** 2024년 11월 18일
