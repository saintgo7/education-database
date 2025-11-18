// ORM Comparison - 50 Practice Examples
// Simplified examples showing concepts across ORMs

// ============================================
// SEQUELIZE EXAMPLES (1-17)
// ============================================

// 1. Define model
const User = sequelize.define('User', {
  username: { type: DataTypes.STRING, allowNull: false, unique: true },
  email: { type: DataTypes.STRING, allowNull: false, unique: true },
  status: { type: DataTypes.STRING, defaultValue: 'active' }
});

// 2. Define relationship (1:N)
User.hasMany(Order, { foreignKey: 'user_id' });
Order.belongsTo(User);

// 3. Define relationship (N:M)
User.belongsToMany(Product, { through: 'UserProducts' });
Product.belongsToMany(User, { through: 'UserProducts' });

// 4. Create record
const user = await User.create({
  username: 'john_doe',
  email: 'john@example.com'
});

// 5. Bulk create
await User.bulkCreate([
  { username: 'jane_smith', email: 'jane@example.com' },
  { username: 'bob_wilson', email: 'bob@example.com' }
]);

// 6. Find by primary key
const user = await User.findByPk(1);

// 7. Find with WHERE
const activeUsers = await User.findAll({ where: { status: 'active' } });

// 8. Find one
const user = await User.findOne({ where: { email: 'john@example.com' } });

// 9. Update
await User.update({ status: 'inactive' }, { where: { id: 1 } });

// 10. Delete
await User.destroy({ where: { id: 1 } });

// 11. Count
const count = await User.count();

// 12. Include/Join
const user = await User.findByPk(1, {
  include: [{ model: Order }]
});

// 13. Eager loading
const users = await User.findAll({
  include: [{ model: Order, include: [{ model: Product }] }]
});

// 14. Lazy loading (query later)
const user = await User.findByPk(1);
const orders = await user.getOrders();

// 15. Transaction
const t = await sequelize.transaction();
try {
  await User.create({...}, { transaction: t });
  await t.commit();
} catch (e) {
  await t.rollback();
}

// 16. Raw query
const users = await sequelize.query('SELECT * FROM users WHERE status = ?', {
  replacements: ['active'],
  type: QueryTypes.SELECT
});

// 17. Scopes
User.addScope('active', { where: { status: 'active' } });
const activeUsers = await User.scope('active').findAll();

// ============================================
// TYPEORM EXAMPLES (18-34)
// ============================================

// 18. Define entity
@Entity()
class User {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ unique: true })
  username: string;

  @Column({ unique: true })
  email: string;

  @Column({ default: 'active' })
  status: string;

  @OneToMany(() => Order, order => order.user)
  orders: Order[];
}

// 19. Define relationship (1:N)
@Entity()
class Order {
  @PrimaryGeneratedColumn()
  id: number;

  @ManyToOne(() => User, user => user.orders)
  user: User;

  @Column()
  total: number;
}

// 20. Define N:M relationship
@Entity()
class Product {
  @PrimaryGeneratedColumn()
  id: number;

  @ManyToMany(() => User, user => user.products)
  @JoinTable()
  users: User[];
}

// 21. Save entity
const user = new User();
user.username = 'john_doe';
user.email = 'john@example.com';
await userRepository.save(user);

// 22. Find by ID
const user = await userRepository.findOne({ where: { id: 1 } });

// 23. Find with conditions
const users = await userRepository.find({ where: { status: 'active' } });

// 24. Update entity
const user = await userRepository.findOne({ where: { id: 1 } });
user.status = 'inactive';
await userRepository.save(user);

// 25. Delete entity
await userRepository.delete({ id: 1 });

// 26. Count records
const count = await userRepository.count();

// 27. Query with relations
const user = await userRepository.findOne({
  where: { id: 1 },
  relations: ['orders', 'products']
});

// 28. Query builder
const users = await userRepository
  .createQueryBuilder('user')
  .where('user.status = :status', { status: 'active' })
  .getMany();

// 29. Join in query builder
const users = await userRepository
  .createQueryBuilder('user')
  .leftJoinAndSelect('user.orders', 'order')
  .where('user.status = :status', { status: 'active' })
  .getMany();

// 30. Aggregate query
const result = await userRepository
  .createQueryBuilder('user')
  .select('COUNT(user.id)', 'total')
  .getRawOne();

// 31. Transaction in TypeORM
await getConnection().transaction(async manager => {
  await manager.save(user);
});

// 32. Timestamps (createdAt, updatedAt)
@Entity()
class User {
  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}

// 33. Soft delete
@Entity()
class User {
  @DeleteDateColumn()
  deletedAt: Date;
}

// 34. Listeners (hooks)
@Entity()
class User {
  @BeforeInsert()
  setUsername() {
    this.username = this.username.toLowerCase();
  }
}

// ============================================
// PRISMA EXAMPLES (35-50)
// ============================================

// 35. Define model in schema.prisma
/*
model User {
  id        Int     @id @default(autoincrement())
  username  String  @unique
  email     String  @unique
  status    String  @default("active")
  orders    Order[]
}
*/

// 36. Create record
const user = await prisma.user.create({
  data: {
    username: 'john_doe',
    email: 'john@example.com'
  }
});

// 37. Create with relationship
const user = await prisma.user.create({
  data: {
    username: 'john_doe',
    email: 'john@example.com',
    orders: {
      create: [
        { total: 100 },
        { total: 200 }
      ]
    }
  }
});

// 38. Batch create
const users = await prisma.user.createMany({
  data: [
    { username: 'jane', email: 'jane@example.com' },
    { username: 'bob', email: 'bob@example.com' }
  ]
});

// 39. Find by ID
const user = await prisma.user.findUnique({ where: { id: 1 } });

// 40. Find many
const users = await prisma.user.findMany({
  where: { status: 'active' }
});

// 41. Find with include (relations)
const user = await prisma.user.findUnique({
  where: { id: 1 },
  include: { orders: true }
});

// 42. Find with nested include
const user = await prisma.user.findUnique({
  where: { id: 1 },
  include: {
    orders: {
      include: { items: true }
    }
  }
});

// 43. Update
const user = await prisma.user.update({
  where: { id: 1 },
  data: { status: 'inactive' }
});

// 44. Update many
await prisma.user.updateMany({
  where: { status: 'pending' },
  data: { status: 'active' }
});

// 45. Delete
await prisma.user.delete({ where: { id: 1 } });

// 46. Count
const count = await prisma.user.count();

// 47. Aggregate
const result = await prisma.user.aggregate({
  _count: true,
  _avg: { age: true }
});

// 48. GroupBy
const results = await prisma.user.groupBy({
  by: ['status'],
  _count: true
});

// 49. Transaction
await prisma.$transaction(async (tx) => {
  await tx.user.create({...});
  await tx.order.create({...});
});

// 50. Pagination
const users = await prisma.user.findMany({
  skip: 10,
  take: 5
});
