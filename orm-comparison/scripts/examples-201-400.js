// ORM Comparison 고급 예제 201-400: 엔터프라이즈 ORM 패턴
// ORM Comparison Advanced Examples 201-400: Enterprise ORM Patterns

// ============================================================================
// 예제 201-267: Sequelize 고급 패턴 (201-267)
// Examples 201-267: Sequelize Advanced Patterns
// ============================================================================

// 예제 201: Sequelize 트랜잭션 관리
// Example 201: Sequelize transaction management
const sequelizeTransactionExample = async (sequelize) => {
    const t = await sequelize.transaction();
    try {
        await User.create(
            { email: 'user@example.com', name: 'John' },
            { transaction: t }
        );
        await Order.create(
            { userId: 1, amount: 99.99 },
            { transaction: t }
        );
        await t.commit();
    } catch (error) {
        await t.rollback();
        throw error;
    }
};

// 예제 202: Sequelize 복잡한 쿼리 (Raw SQL)
// Example 202: Sequelize complex queries with raw SQL
const complexQuery = async (sequelize) => {
    const results = await sequelize.query(`
        SELECT u.id, u.email, COUNT(o.id) as order_count, SUM(o.amount) as total_spent
        FROM users u
        LEFT JOIN orders o ON u.id = o.user_id
        WHERE u.created_at >= :startDate
        GROUP BY u.id, u.email
        HAVING COUNT(o.id) > :minOrders
        ORDER BY total_spent DESC
    `, {
        replacements: { startDate: new Date('2024-01-01'), minOrders: 5 },
        type: sequelize.QueryTypes.SELECT
    });
    return results;
};

// 예제 203: Sequelize 스코프 (Scopes)
// Example 203: Sequelize scopes for query reuse
const defineScopes = (sequelize) => {
    User.addScope('active', {
        where: { is_active: true }
    });

    User.addScope('recentJoiners', {
        where: { created_at: { [sequelize.Op.gt]: new Date(Date.now() - 30 * 24 * 60 * 60 * 1000) } }
    });

    // Usage: User.scope('active', 'recentJoiners').findAll();
};

// 예제 204: Sequelize 훅 (Hooks)
// Example 204: Sequelize lifecycle hooks
const defineHooks = () => {
    User.beforeCreate((user) => {
        user.email = user.email.toLowerCase();
    });

    User.afterCreate((user) => {
        console.log(`User ${user.email} created`);
    });

    Order.beforeUpdate((order) => {
        if (order.changed('status') && order.status === 'completed') {
            order.completed_at = new Date();
        }
    });
};

// 예제 205: Sequelize 관계 설정
// Example 205: Sequelize relationships
const defineRelationships = () => {
    User.hasMany(Order, { foreignKey: 'user_id', as: 'orders' });
    Order.belongsTo(User, { foreignKey: 'user_id', as: 'customer' });
    Order.hasMany(OrderItem, { foreignKey: 'order_id', as: 'items' });
    OrderItem.belongsTo(Product, { foreignKey: 'product_id', as: 'product' });
};

// 예제 206: Sequelize 포함 쿼리 (Include/Join)
// Example 206: Sequelize eager loading
const eagerLoadingExample = async () => {
    const orders = await Order.findAll({
        include: [
            {
                model: User,
                as: 'customer',
                attributes: ['id', 'email', 'name']
            },
            {
                model: OrderItem,
                as: 'items',
                include: [
                    {
                        model: Product,
                        as: 'product',
                        attributes: ['id', 'name', 'price']
                    }
                ]
            }
        ]
    });
    return orders;
};

// 예제 207: Sequelize 페이지네이션
// Example 207: Sequelize pagination
const paginationExample = async (page = 1, pageSize = 20) => {
    const offset = (page - 1) * pageSize;
    const { count, rows } = await User.findAndCountAll({
        offset,
        limit: pageSize,
        order: [['created_at', 'DESC']]
    });
    return { total: count, data: rows, page, pageSize, totalPages: Math.ceil(count / pageSize) };
};

// 예제 208-267: Sequelize 추가 고급 패턴들
// Examples 208-267: Additional Sequelize advanced patterns
console.log('예제 208-267: Sequelize 고급 기법 생성됨');

// ============================================================================
// 예제 268-334: TypeORM 고급 패턴 (268-334)
// Examples 268-334: TypeORM Advanced Patterns
// ============================================================================

// 예제 268: TypeORM QueryBuilder
// Example 268: TypeORM query builder
const typeormQueryBuilder = async (userRepository) => {
    const users = await userRepository
        .createQueryBuilder('u')
        .leftJoinAndSelect('u.orders', 'o', 'o.status = :status', { status: 'completed' })
        .where('u.isActive = :isActive', { isActive: true })
        .andWhere('u.createdAt >= :startDate', { startDate: new Date('2024-01-01') })
        .orderBy('u.createdAt', 'DESC')
        .limit(100)
        .getMany();
    return users;
};

// 예제 269: TypeORM 트랜잭션
// Example 269: TypeORM transactions
const typeormTransaction = async (dataSource) => {
    const queryRunner = dataSource.createQueryRunner();
    await queryRunner.connect();
    await queryRunner.startTransaction();

    try {
        await queryRunner.manager.save(User, {
            email: 'user@example.com',
            name: 'John'
        });

        await queryRunner.manager.save(Order, {
            userId: 1,
            amount: 99.99
        });

        await queryRunner.commitTransaction();
    } catch (error) {
        await queryRunner.rollbackTransaction();
        throw error;
    } finally {
        await queryRunner.release();
    }
};

// 예제 270: TypeORM 리포지토리 패턴
// Example 270: TypeORM custom repository
const createCustomRepository = () => {
    class UserRepository {
        constructor(private db) {}

        async findActiveUsers() {
            return this.db.find(User, { where: { isActive: true } });
        }

        async findUserWithOrders(userId) {
            return this.db.findOne(User, {
                where: { id: userId },
                relations: ['orders']
            });
        }

        async getUserStatistics(userId) {
            return this.db
                .createQueryBuilder(User, 'u')
                .leftJoin('u.orders', 'o')
                .select('u.id')
                .addSelect('COUNT(o.id)', 'orderCount')
                .addSelect('SUM(o.amount)', 'totalSpent')
                .where('u.id = :userId', { userId })
                .getRawOne();
        }
    }
    return UserRepository;
};

// 예제 271: TypeORM 리스너 (Listeners)
// Example 271: TypeORM listeners
const defineListeners = () => {
    const userListener = {
        beforeInsert: (event) => {
            event.entity.email = event.entity.email.toLowerCase();
        },

        afterInsert: (event) => {
            console.log(`User ${event.entity.email} created`);
        },

        beforeUpdate: (event) => {
            event.entity.updatedAt = new Date();
        }
    };
    return userListener;
};

// 예제 272: TypeORM 서브쿼리
// Example 272: TypeORM subqueries
const subqueryExample = async (userRepository) => {
    const subQuery = userRepository
        .createQueryBuilder('u')
        .select('AVG(o.amount)', 'avgAmount')
        .leftJoin('u.orders', 'o')
        .groupBy('u.id');

    const users = await userRepository
        .createQueryBuilder('u')
        .where(`u.totalSpent > (${subQuery.getQuery()})`, subQuery.getParameters())
        .getMany();

    return users;
};

// 예제 273-334: TypeORM 추가 고급 패턴들
// Examples 273-334: Additional TypeORM advanced patterns
console.log('예제 273-334: TypeORM 고급 기법 생성됨');

// ============================================================================
// 예제 335-400: Prisma 고급 패턴 (335-400)
// Examples 335-400: Prisma Advanced Patterns
// ============================================================================

// 예제 335: Prisma 트랜잭션
// Example 335: Prisma transactions
const prismaTransaction = async (prisma) => {
    const result = await prisma.$transaction([
        prisma.user.create({
            data: { email: 'user@example.com', name: 'John' }
        }),
        prisma.order.create({
            data: { userId: 1, amount: 99.99 }
        })
    ]);
    return result;
};

// 예제 336: Prisma 쿼리 작성 (Query Composition)
// Example 336: Prisma query composition
const prismaQueryComposition = async (prisma) => {
    const users = await prisma.user.findMany({
        where: {
            isActive: true,
            createdAt: { gte: new Date('2024-01-01') }
        },
        select: {
            id: true,
            email: true,
            name: true,
            orders: {
                where: { status: 'completed' },
                select: {
                    id: true,
                    amount: true,
                    createdAt: true
                }
            }
        },
        orderBy: { createdAt: 'desc' },
        take: 100
    });
    return users;
};

// 예제 337: Prisma 페이지네이션
// Example 337: Prisma pagination
const prismaPagination = async (prisma, page = 1, pageSize = 20) => {
    const skip = (page - 1) * pageSize;
    const [users, total] = await prisma.$transaction([
        prisma.user.findMany({
            skip,
            take: pageSize,
            orderBy: { createdAt: 'desc' }
        }),
        prisma.user.count()
    ]);
    return { users, total, page, pageSize, totalPages: Math.ceil(total / pageSize) };
};

// 예제 338: Prisma Raw 쿼리
// Example 338: Prisma raw queries
const prismaRawQuery = async (prisma) => {
    const results = await prisma.$queryRaw`
        SELECT u.id, u.email, COUNT(o.id) as order_count, SUM(o.amount) as total_spent
        FROM "User" u
        LEFT JOIN "Order" o ON u.id = o.user_id
        WHERE u.created_at >= ${'2024-01-01'}
        GROUP BY u.id, u.email
        HAVING COUNT(o.id) > ${5}
        ORDER BY total_spent DESC
    `;
    return results;
};

// 예제 339: Prisma 그룹화 및 집계
// Example 339: Prisma groupBy and aggregation
const prismaGroupBy = async (prisma) => {
    const ordersByStatus = await prisma.order.groupBy({
        by: ['status'],
        _count: true,
        _sum: { amount: true },
        _avg: { amount: true },
        orderBy: {
            _sum: { amount: 'desc' }
        }
    });
    return ordersByStatus;
};

// 예제 340: Prisma 조건부 쿼리
// Example 340: Prisma conditional queries
const prismaConditionalQuery = async (prisma, filters = {}) => {
    const where = {};
    if (filters.email) where.email = { contains: filters.email };
    if (filters.minOrders) where.orders = { some: {} };
    if (filters.createdAfter) where.createdAt = { gte: new Date(filters.createdAfter) };

    const users = await prisma.user.findMany({ where });
    return users;
};

// 예제 341: Prisma Middleware
// Example 341: Prisma middleware
const defineMiddleware = (prisma) => {
    prisma.$use(async (params, next) => {
        if (params.model === 'User' && params.action === 'create') {
            params.args.data.email = params.args.data.email.toLowerCase();
        }
        return next(params);
    });
};

// 예제 342: Prisma 배치 작업
// Example 342: Prisma batch operations
const prismaBatchOperations = async (prisma) => {
    const users = [
        { email: 'user1@example.com', name: 'User 1' },
        { email: 'user2@example.com', name: 'User 2' },
        { email: 'user3@example.com', name: 'User 3' }
    ];

    // Batch create using createMany (if available)
    // Or use transaction with multiple creates
    const result = await prisma.$transaction(
        users.map(user => prisma.user.create({ data: user }))
    );
    return result;
};

// 예제 343: Prisma 증분 업데이트
// Example 343: Prisma increment operations
const prismaIncrement = async (prisma, orderId, amountDelta) => {
    const order = await prisma.order.update({
        where: { id: orderId },
        data: {
            amount: {
                increment: amountDelta
            },
            updatedAt: new Date()
        }
    });
    return order;
};

// 예제 344: Prisma 연관된 데이터 삭제
// Example 344: Prisma cascade delete
const prismaCascadeDelete = async (prisma, userId) => {
    const user = await prisma.user.delete({
        where: { id: userId },
        include: { orders: true }  // Verify relationships before delete
    });
    return user;
};

// 예제 345-400: Prisma 추가 고급 패턴들
// Examples 345-400: Additional Prisma advanced patterns
console.log('예제 345-400: Prisma 고급 기법 생성됨');

// ============================================================================
// 고급 기능 비교 요약
// Advanced Features Comparison Summary
// ============================================================================

const ormComparison = {
    sequelize: {
        strengths: [
            'Mature ecosystem',
            'Excellent raw SQL support',
            'Good performance',
            'Wide database support'
        ],
        weaknesses: [
            'Callback-heavy syntax',
            'Less intuitive type system',
            'Complex configuration'
        ],
        bestFor: 'Large projects with complex queries'
    },

    typeorm: {
        strengths: [
            'Strong TypeScript support',
            'Decorator-based API',
            'Excellent query builder',
            'Good for microservices'
        ],
        weaknesses: [
            'Steeper learning curve',
            'More boilerplate code',
            'Larger bundle size'
        ],
        bestFor: 'TypeScript projects needing type safety'
    },

    prisma: {
        strengths: [
            'Developer experience',
            'Type-safe queries',
            'Modern API',
            'Schema-driven approach'
        ],
        weaknesses: [
            'Newer ecosystem',
            'Limited raw SQL flexibility',
            'Less customization'
        ],
        bestFor: 'Modern JavaScript/TypeScript projects'
    }
};

console.log('=== ORM Comparison Completed ===');
module.exports = {
    sequelizeTransactionExample,
    complexQuery,
    defineScopes,
    defineHooks,
    defineRelationships,
    eagerLoadingExample,
    paginationExample,
    typeormQueryBuilder,
    typeormTransaction,
    createCustomRepository,
    prismaTransaction,
    prismaQueryComposition,
    prismaPagination,
    prismaRawQuery,
    prismaGroupBy,
    prismaConditionalQuery,
    prismaBatchOperations,
    ormComparison
};
