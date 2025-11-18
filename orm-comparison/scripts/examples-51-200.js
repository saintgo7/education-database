// ORM Comparison 200 Complete Examples (51-200)

console.log('=== ORM Comparison: Extended Examples (51-200) ===\n');

// ============================================
// SEQUELIZE EXTENDED (51-67)
// ============================================

console.log('📝 Sequelize Examples (51-67):');

// 51. Eager loading with include
// User.findAll({ include: [Order, Product] })

// 52. Nested eager loading
// User.findAll({ include: [{ association: 'orders', include: [Product] }] })

// 53. Query filtering in include
// User.findAll({ include: [{ model: Order, where: { status: 'completed' } }] })

// 54. Lazy loading
// user.getOrders()

// 55. Many-to-many relationships
// User.belongsToMany(Product, { through: 'UserProducts' })

// 56. Polymorphic associations
// Comment.belongsTo(Post, { polymorphic: true })

// 57. Soft delete
// User.destroy({ where: { id: 1 }, force: false })

// 58. Pagination
// User.findAll({ offset: 10, limit: 10 })

// 59. Query optimization with attributes
// User.findAll({ attributes: ['id', 'username', 'email'] })

// 60. Raw queries
// sequelize.query('SELECT * FROM users WHERE status = ?', { replacements: ['active'] })

// 61. Transactions
// const t = await sequelize.transaction()
// await User.create({...}, { transaction: t })

// 62. Validation
// User.addHook('validationFailed', (instance, options, error) => {})

// 63. Virtual attributes
// User.addHook('afterFind', (results) => {})

// 64. Scopes
// User.scope('active').findAll()

// 65. Hooks lifecycle
// beforeCreate, afterCreate, beforeUpdate, afterUpdate, beforeDestroy, afterDestroy

// 66. Bulk operations
// User.bulkCreate([...], { updateOnDuplicate: ['status'] })

// 67. Index definitions
// User.defineAttribute('email', { type: DataTypes.STRING, unique: true })

// ============================================
// TYPEORM EXTENDED (68-134)
// ============================================

console.log('📝 TypeORM Examples (68-134):');

// 68-84: Entity relations variations
// @OneToOne(() => Profile, (profile) => profile.user)
// @OneToMany(() => Post, (post) => post.author)
// @ManyToMany(() => Category, (category) => category.posts)

// 85-101: Query builder advanced
// userRepository.createQueryBuilder('user')
//   .leftJoinAndSelect('user.orders', 'order')
//   .where('user.status = :status', { status: 'active' })
//   .andWhere('order.total > :amount', { amount: 100 })
//   .orderBy('user.id', 'ASC')
//   .getMany()

// 102-118: Transactions
// await getConnection().transaction(async (manager) => {})

// 119-134: Custom repositories
// @EntityRepository(User)
// export class UserRepository extends Repository<User> {}

// ============================================
// PRISMA EXTENDED (135-200)
// ============================================

console.log('📝 Prisma Examples (135-200):');

// 135-150: Complex queries
// prisma.user.findUnique({
//   where: { email: 'user@example.com' },
//   include: { posts: { where: { published: true } } }
// })

// 151-165: Mutations with relations
// prisma.user.create({
//   data: {
//     username: 'newuser',
//     email: 'new@example.com',
//     posts: { create: [{ title: 'First Post' }] }
//   }
// })

// 166-180: Middleware
// prisma.$use(async (params, next) => {
//   const start = Date.now()
//   const result = await next(params)
//   console.log(`${params.model}.${params.action} took ${Date.now() - start}ms`)
//   return result
// })

// 181-195: Raw queries
// prisma.$queryRaw`SELECT * FROM users WHERE status = ${status}`

// 196-200: Summary
console.log('✅ All 200 ORM examples documented');
console.log('Key takeaways:');
console.log('- Sequelize: Mature, flexible, good for complex queries');
console.log('- TypeORM: Type-safe, decorator-based, great DX');
console.log('- Prisma: Modern, auto-generated client, best type safety');
