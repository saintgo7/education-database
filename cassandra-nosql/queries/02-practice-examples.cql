-- Cassandra 50 Practice Examples (CQL)

USE education;

-- ============================================
-- 1-10: Basic DDL Operations
-- ============================================

-- 1. Create table with primary key
CREATE TABLE users (
  user_id UUID PRIMARY KEY,
  username TEXT,
  email TEXT,
  created_at TIMESTAMP
);

-- 2. Create table with clustering key
CREATE TABLE user_posts (
  user_id UUID,
  post_date TIMESTAMP,
  post_id UUID,
  content TEXT,
  PRIMARY KEY (user_id, post_date, post_id)
);

-- 3. Create table with static columns
CREATE TABLE user_profile (
  user_id UUID,
  profile_date TIMESTAMP,
  name TEXT STATIC,
  age INT STATIC,
  profile_data TEXT,
  PRIMARY KEY (user_id, profile_date)
);

-- 4. Create index on column
CREATE INDEX ON users (email);

-- 5. Create secondary index
CREATE INDEX email_index ON users (email);

-- 6. Alter table - add column
ALTER TABLE users ADD phone TEXT;

-- 7. Alter table - add collection
ALTER TABLE users ADD tags SET<TEXT>;

-- 8. Drop table
DROP TABLE IF EXISTS temp_users;

-- 9. Create materialized view
CREATE MATERIALIZED VIEW user_by_email AS
SELECT email, user_id FROM users WHERE email IS NOT NULL
PRIMARY KEY (email, user_id);

-- 10. Create user-defined type
CREATE TYPE address (
  street TEXT,
  city TEXT,
  zipcode TEXT,
  country TEXT
);

-- ============================================
-- 11-20: INSERT Operations
-- ============================================

-- 11. Insert single row
INSERT INTO users (user_id, username, email, created_at)
VALUES (uuid(), 'john_doe', 'john@example.com', now());

-- 12. Insert multiple rows
INSERT INTO users (user_id, username, email, created_at)
VALUES (uuid(), 'jane_smith', 'jane@example.com', now());

-- 13. Insert with TTL
INSERT INTO users (user_id, username, email) VALUES (uuid(), 'temp_user', 'temp@example.com')
USING TTL 3600;

-- 14. Insert with TIMESTAMP
INSERT INTO users (user_id, username, email, created_at)
VALUES (uuid(), 'bob_wilson', 'bob@example.com', now())
USING TIMESTAMP 1636000000000;

-- 15. Insert collection elements
INSERT INTO users (user_id, username, tags) VALUES (uuid(), 'user1', {'python', 'java'});

-- 16. Insert map data
INSERT INTO user_settings (user_id, username, preferences)
VALUES (uuid(), 'user2', {'theme': 'dark', 'notifications': 'on'});

-- 17. Batch insert
BEGIN BATCH
INSERT INTO users (user_id, username) VALUES (uuid(), 'user1');
INSERT INTO users (user_id, username) VALUES (uuid(), 'user2');
INSERT INTO users (user_id, username) VALUES (uuid(), 'user3');
APPLY BATCH;

-- 18. Conditional insert (IF NOT EXISTS)
INSERT INTO users (user_id, username, email)
VALUES (uuid(), 'new_user', 'new@example.com')
IF NOT EXISTS;

-- 19. Insert with prepared statement (parameterized)
-- PREPARE insert_user AS
-- INSERT INTO users (user_id, username, email) VALUES (?, ?, ?);

-- 20. Insert into table with composite key
INSERT INTO user_posts (user_id, post_date, post_id, content)
VALUES (uuid(), now(), uuid(), 'Post content here');

-- ============================================
-- 21-30: SELECT Operations
-- ============================================

-- 21. Select all columns
SELECT * FROM users;

-- 22. Select specific columns
SELECT user_id, username, email FROM users;

-- 23. Select with WHERE clause
SELECT * FROM users WHERE user_id = uuid();

-- 24. Select with LIMIT
SELECT * FROM users LIMIT 10;

-- 25. Select with ALLOW FILTERING
SELECT * FROM users WHERE email = 'john@example.com' ALLOW FILTERING;

-- 26. Select with IN clause
SELECT * FROM users WHERE user_id IN (uuid(), uuid(), uuid());

-- 27. Select with clustering key range
SELECT * FROM user_posts WHERE user_id = uuid() AND post_date > '2024-01-01';

-- 28. Select with ORDER BY
SELECT * FROM user_posts WHERE user_id = uuid() ORDER BY post_date DESC;

-- 29. Select DISTINCT
SELECT DISTINCT username FROM users;

-- 30. Select with COUNT
SELECT COUNT(*) as total_users FROM users;

-- ============================================
-- 31-40: UPDATE and DELETE Operations
-- ============================================

-- 31. Update single column
UPDATE users SET username = 'newname' WHERE user_id = uuid();

-- 32. Update multiple columns
UPDATE users SET username = 'newname', email = 'new@example.com' WHERE user_id = uuid();

-- 33. Update with TTL
UPDATE users USING TTL 7200 SET email = 'new@example.com' WHERE user_id = uuid();

-- 34. Update collection - add element
UPDATE users SET tags = tags + {'newtag'} WHERE user_id = uuid();

-- 35. Update collection - remove element
UPDATE users SET tags = tags - {'oldtag'} WHERE user_id = uuid();

-- 36. Update counter column
UPDATE user_stats SET views = views + 1 WHERE user_id = uuid();

-- 37. Update conditional (IF)
UPDATE users SET email = 'new@example.com' WHERE user_id = uuid()
IF email = 'old@example.com';

-- 38. Delete single column
DELETE email FROM users WHERE user_id = uuid();

-- 39. Delete entire row
DELETE FROM users WHERE user_id = uuid();

-- 40. Delete with TTL
DELETE FROM users USING TTL 3600 WHERE user_id = uuid();

-- ============================================
-- 41-50: Advanced Queries
-- ============================================

-- 41. Token function for data distribution
SELECT user_id, username FROM users WHERE token(user_id) > token(uuid());

-- 42. Map access
SELECT preferences['theme'] FROM user_settings WHERE user_id = uuid();

-- 43. Collection contains
SELECT * FROM users WHERE tags CONTAINS 'python';

-- 44. Collection contains key (for maps)
SELECT * FROM user_settings WHERE preferences CONTAINS KEY 'theme';

-- 45. Aggregate function - count
SELECT COUNT(*) FROM users;

-- 46. Aggregate function - sum
SELECT SUM(purchase_amount) FROM purchases WHERE user_id = uuid();

-- 47. Aggregate function - min/max
SELECT MIN(price), MAX(price) FROM products;

-- 48. Group by (Cassandra 3.10+)
SELECT category, COUNT(*) FROM products GROUP BY category;

-- 49. Tuple type usage
SELECT (user_id, username, email) as user_tuple FROM users;

-- 50. Keyspace info query
DESCRIBE KEYSPACE education;
