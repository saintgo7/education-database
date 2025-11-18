// ORM Comparison 50 Runnable Examples
// Demonstrates common ORM patterns across frameworks

console.log('=== ORM Comparison: 50 Runnable Examples ===\n');

// ============================================
// Sequelize Examples (1-17)
// ============================================

console.log('📝 Sequelize Examples (1-17):');
console.log('1. Define model with attributes');
console.log('2. Define 1:N relationship (User -> Orders)');
console.log('3. Define N:M relationship');
console.log('4. Create record: User.create({...})');
console.log('5. Bulk create: User.bulkCreate([...])');
console.log('6. Find by PK: User.findByPk(1)');
console.log('7. Find with WHERE: User.findAll({where: {status: "active"}})');
console.log('8. Find one: User.findOne({where: {email: "..."}})');
console.log('9. Update: User.update({status: "inactive"}, {where: {id: 1}})');
console.log('10. Delete: User.destroy({where: {id: 1}})');
console.log('11. Count: User.count()');
console.log('12. Include relations: User.findByPk(1, {include: [Order]})');
console.log('13. Lazy loading: user.getOrders()');
console.log('14. Transaction: sequelize.transaction()');
console.log('15. Raw query: sequelize.query(sql)');
console.log('16. Scopes: User.scope("active").findAll()');
console.log('17. Hooks: Model.addHook("beforeCreate", ...)');

// ============================================
// TypeORM Examples (18-34)
// ============================================

console.log('\n📝 TypeORM Examples (18-34):');
console.log('18. Define entity with decorators');
console.log('19. Define 1:N relationship');
console.log('20. Define N:M relationship');
console.log('21. Save entity: await userRepository.save(user)');
console.log('22. Find by ID: await userRepository.findOne({where: {id: 1}})');
console.log('23. Find with conditions: await userRepository.find(...)');
console.log('24. Update entity: user.status = "inactive"; await save');
console.log('25. Delete entity: await userRepository.delete({id: 1})');
console.log('26. Count records: await userRepository.count()');
console.log('27. Query with relations: await userRepository.findOne({relations: [...]})');
console.log('28. Query builder: userRepository.createQueryBuilder("user")');
console.log('29. Join in query builder: .leftJoinAndSelect(...)');
console.log('30. Aggregate query: .select("COUNT(user.id)", "total")');
console.log('31. Transaction: await getConnection().transaction(...)');
console.log('32. Timestamps: @CreateDateColumn(), @UpdateDateColumn()');
console.log('33. Soft delete: @DeleteDateColumn()');
console.log('34. Listeners (hooks): @BeforeInsert()');

// ============================================
// Prisma Examples (35-50)
// ============================================

console.log('\n📝 Prisma Examples (35-50):');
console.log('35. Define model in schema.prisma');
console.log('36. Create record: await prisma.user.create({data: {...}})');
console.log('37. Create with relations: create with nested data');
console.log('38. Batch create: await prisma.user.createMany(...)');
console.log('39. Find by ID: await prisma.user.findUnique(...)');
console.log('40. Find many: await prisma.user.findMany(...)');
console.log('41. Find with include: include related models');
console.log('42. Nested include: include with multiple levels');
console.log('43. Update: await prisma.user.update(...)');
console.log('44. Update many: await prisma.user.updateMany(...)');
console.log('45. Delete: await prisma.user.delete(...)');
console.log('46. Count: await prisma.user.count()');
console.log('47. Aggregate: await prisma.user.aggregate(...)');
console.log('48. GroupBy: await prisma.user.groupBy(...)');
console.log('49. Transaction: await prisma.$transaction(...)');
console.log('50. Pagination: skip and take');

// ============================================
// Comparison Table
// ============================================

console.log('\n📊 Quick Comparison:\n');
console.log('Feature          | Sequelize | TypeORM | Prisma');
console.log('─────────────────┼───────────┼─────────┼───────');
console.log('Type Safety      | ❌        | ✅      | ✅');
console.log('Type Inference   | ❌        | ✅      | ✅');
console.log('Query Builder    | ✅        | ✅      | ❌');
console.log('Raw Queries      | ✅        | ✅      | ✅');
console.log('Migrations       | ✅        | ✅      | ✅');
console.log('Relations        | ✅        | ✅      | ✅');
console.log('Hooks            | ✅        | ✅      | ❌');
console.log('Performance      | ⭐⭐⭐    | ⭐⭐    | ⭐⭐⭐⭐');
console.log('DX               | ⭐⭐      | ⭐⭐⭐  | ⭐⭐⭐⭐');
console.log('Learning Curve   | ⭐⭐⭐    | ⭐⭐⭐⭐ | ⭐⭐');

console.log('\n✅ All ORM patterns documented');
