# ORM 비교 (ORM Comparison)

한국어 문서 | [English Document](./README.md)

## 개요

ORM Comparison 모듈은 세 가지 주요 Node.js ORM (Sequelize, TypeORM, Prisma)의 비교 분석과 400개의 실용적인 예제를 제공합니다.

## 예제 범위

### Sequelize (Examples 1-67)
- 기본 모델 정의
- 관계 설정 (1:1, 1:N, M:N)
- 쿼리 빌더
- 트랜잭션 및 훅
- 페이지네이션

### TypeORM (Examples 68-134)
- 데코레이터 기반 모델
- QueryBuilder API
- 리포지토리 패턴
- 관계 로딩
- 마이그레이션

### Prisma (Examples 135-200)
- 스키마 정의
- 타입 안전 쿼리
- 관계 조회
- 트랜잭션
- 미들웨어

### 고급 패턴 (Examples 201-400)
- **Sequelize 고급 (201-267)**
  - 복잡한 쿼리
  - 스코프 활용
  - 훅 최적화

- **TypeORM 고급 (268-334)**
  - 커스텀 리포지토리
  - 쿼리 최적화
  - 관계 로딩 전략

- **Prisma 고급 (335-400)**
  - 배치 연산
  - 조건부 쿼리
  - 성능 최적화

## 빠른 시작

```bash
cd orm-comparison/scripts
npm install

# 기본 예제
node runnable-examples.js

# 고급 예제
node examples-201-400.js
```

## ORM 비교표

| 기능 | Sequelize | TypeORM | Prisma |
|------|-----------|---------|--------|
| 문법 | Callback | Decorator | Schema-first |
| 타입 안전 | 낮음 | 높음 | 매우 높음 |
| 성능 | 좋음 | 좋음 | 매우 좋음 |
| 학습곡선 | 낮음 | 중간 | 낮음 |
| 데이터베이스 지원 | 광범위 | 광범위 | 제한적 |

## 선택 가이드

### Sequelize 추천
- 레거시 프로젝트
- 다양한 DB 지원 필요
- 복잡한 쿼리

### TypeORM 추천
- TypeScript 프로젝트
- 엔터프라이즈 애플리케이션
- 타입 안전성 필요

### Prisma 추천
- 신규 프로젝트
- 최신 기술 스택
- 개발자 경험 중요

## 자주 묻는 질문

### Q: 어떤 ORM을 선택해야 하나요?
**A:** 프로젝트 요구사항, 팀의 경험, 기존 스택에 따라 결정하세요.

### Q: ORM의 성능 영향은?
**A:** 현대 ORM들은 충분한 성능을 제공합니다. 쿼리 최적화가 더 중요합니다.

---

**마지막 업데이트:** 2024년 11월 18일
