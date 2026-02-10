---
name: database-pro
description: Design and optimize database schemas for SQL and NoSQL. Schema design, normalization, indexing strategies, query optimization, execution plan analysis, migration patterns, performance tuning, slow query diagnosis, partitioning, and configuration tuning. Supports PostgreSQL and MySQL.
license: MIT
mcp: postgres
---

# Database Pro

Design production-ready schemas and optimize database performance.

---

## Quick Start

Describe your data model or performance problem:

```
design a schema for an e-commerce platform with users, products, orders
```

```
this query is slow, help me optimize it
```

**What to include:**
- Entities and relationships (users have orders, orders have items)
- Scale hints (high-traffic, millions of records)
- Database preference (PostgreSQL/MySQL/NoSQL) - defaults to PostgreSQL
- For optimization: the slow query and EXPLAIN output

---

## Triggers

| Trigger | Example |
|---------|---------|
| `design schema` | "design a schema for user authentication" |
| `database design` | "database design for multi-tenant SaaS" |
| `create tables` | "create tables for a blog system" |
| `slow query` | "this query takes 5 seconds, help me fix it" |
| `optimize query` | "optimize this SELECT with JOINs" |
| `execution plan` | "explain this EXPLAIN ANALYZE output" |
| `add indexes` | "what indexes should I add for this table" |
| `database performance` | "my database is slow under load" |

---

## Quick Reference

| Task | Approach | Key Consideration |
|------|----------|-------------------|
| New schema | Normalize to 3NF first | Model domain, not UI |
| SQL vs NoSQL | Access patterns decide | Read/write ratio matters |
| Primary keys | INT or UUID | UUID for distributed systems |
| Foreign keys | Always constrain | ON DELETE strategy critical |
| Indexes | FKs + WHERE + ORDER BY columns | Column order matters in composites |
| Slow queries | EXPLAIN ANALYZE first | Measure before and after |
| Migrations | Always reversible | Backward compatible first |

---

## Process Overview

```
Requirements / Performance Problem
    |
    v
+-----------------------------------------------------+
| Phase 1: ANALYZE                                     |
| * Identify entities and relationships                |
| * Determine access patterns (read vs write heavy)    |
| * For optimization: run EXPLAIN ANALYZE              |
| * Establish baseline metrics                         |
+-----------------------------------------------------+
    |
    v
+-----------------------------------------------------+
| Phase 2: DESIGN / DIAGNOSE                           |
| * Schema: Normalize to 3NF, define keys/constraints  |
| * Optimization: Identify missing indexes, bad joins  |
| * Choose appropriate data types                      |
+-----------------------------------------------------+
    |
    v
+-----------------------------------------------------+
| Phase 3: OPTIMIZE                                    |
| * Plan indexing strategy                             |
| * Rewrite inefficient queries                        |
| * Consider denormalization for read-heavy queries    |
| * Tune configuration parameters                      |
+-----------------------------------------------------+
    |
    v
+-----------------------------------------------------+
| Phase 4: IMPLEMENT & VALIDATE                        |
| * Generate migration scripts (up + down)             |
| * Apply changes incrementally                        |
| * Measure improvement with EXPLAIN ANALYZE           |
| * Monitor impact on write performance                |
+-----------------------------------------------------+
    |
    v
Production-Ready Schema / Optimized Queries
```

---

## Core Principles

| Principle | Why | Implementation |
|-----------|-----|----------------|
| Model the Domain | UI changes, domain doesn't | Entity names reflect business concepts |
| Data Integrity First | Corruption is costly | Constraints at database level |
| Measure Before Optimizing | Intuition misleads | EXPLAIN ANALYZE before any change |
| Optimize for Access Pattern | Can't optimize for both | OLTP: normalized, OLAP: denormalized |
| One Change at a Time | Isolate impact | Apply and measure incrementally |

---

## Anti-Patterns

| Avoid | Why | Instead |
|-------|-----|---------|
| VARCHAR(255) everywhere | Wastes storage, hides intent | Size appropriately per field |
| FLOAT for money | Rounding errors | DECIMAL(10,2) |
| Missing FK constraints | Orphaned data | Always define foreign keys |
| No indexes on FKs | Slow JOINs | Index every foreign key |
| Optimizing without EXPLAIN | Guessing wastes time | Always read the execution plan |
| Over-indexing | Slow writes, wasted space | Only index what's actually queried |
| SELECT * | Fetches unnecessary data | Explicit column lists |
| Non-reversible migrations | Can't rollback | Always write DOWN migration |
| Multiple simultaneous changes | Can't isolate impact | One optimization at a time |
| Ignoring VACUUM/ANALYZE | Stale statistics, bloat | Schedule regular maintenance |

---

## Constraints

### MUST DO
- Analyze EXPLAIN plans before optimizing
- Measure performance before and after changes
- Test changes in non-production first
- Document optimization decisions
- Monitor write performance impact after index changes
- Consider replication lag for distributed systems

### MUST NOT DO
- Apply optimizations without measurement
- Create redundant or unused indexes
- Make multiple changes simultaneously
- Optimize without understanding query patterns
- Skip execution plan analysis

---

## Verification Checklist

After designing or optimizing a schema:

- [ ] Every table has a primary key
- [ ] All relationships have foreign key constraints with ON DELETE strategy
- [ ] Indexes exist on all foreign keys
- [ ] Indexes exist on frequently queried WHERE/ORDER BY columns
- [ ] Appropriate data types (DECIMAL for money, TIMESTAMP for dates)
- [ ] NOT NULL on required fields, UNIQUE where needed
- [ ] CHECK constraints for validation
- [ ] created_at and updated_at timestamps
- [ ] Migration scripts are reversible
- [ ] EXPLAIN ANALYZE confirms index usage on critical queries
- [ ] No full table scans on large tables

---

<details>
<summary><strong>Deep Dive: Normalization (SQL)</strong></summary>

### Normal Forms

| Form | Rule | Violation Example |
|------|------|-------------------|
| **1NF** | Atomic values, no repeating groups | `product_ids = '1,2,3'` |
| **2NF** | 1NF + no partial dependencies | customer_name in order_items |
| **3NF** | 2NF + no transitive dependencies | country derived from postal_code |

### 1NF

```sql
-- BAD: Multiple values in column
CREATE TABLE orders (
  id INT PRIMARY KEY,
  product_ids VARCHAR(255)  -- '101,102,103'
);

-- GOOD: Separate table
CREATE TABLE order_items (
  id INT PRIMARY KEY,
  order_id INT REFERENCES orders(id),
  product_id INT
);
```

### 2NF

```sql
-- BAD: customer_name depends only on customer_id
CREATE TABLE order_items (
  order_id INT,
  product_id INT,
  customer_name VARCHAR(100),  -- Partial dependency!
  PRIMARY KEY (order_id, product_id)
);

-- GOOD: Customer data in separate table
CREATE TABLE customers (
  id INT PRIMARY KEY,
  name VARCHAR(100)
);
```

### When to Denormalize

| Scenario | Strategy |
|----------|----------|
| Read-heavy reporting | Pre-calculated aggregates |
| Expensive JOINs | Cached derived columns |
| Analytics dashboards | Materialized views |

</details>

<details>
<summary><strong>Deep Dive: Indexing & Query Optimization</strong></summary>

### When to Create Indexes

| Always Index | Reason |
|--------------|--------|
| Foreign keys | Speed up JOINs |
| WHERE clause columns | Speed up filtering |
| ORDER BY columns | Speed up sorting |
| Unique constraints | Enforced uniqueness |

### Index Types

| Type | Best For | Example |
|------|----------|---------|
| B-Tree | Ranges, equality | `price > 100` |
| Hash | Exact matches only | `email = 'x@y.com'` |
| GIN | Arrays, JSONB, full-text | `tags @> '{urgent}'` |
| Partial | Subset of rows | `WHERE is_active = true` |

### Composite Index Order

```sql
CREATE INDEX idx_customer_status ON orders(customer_id, status);

-- Uses index (leftmost prefix)
SELECT * FROM orders WHERE customer_id = 123;
SELECT * FROM orders WHERE customer_id = 123 AND status = 'pending';

-- Does NOT use index (no leftmost column)
SELECT * FROM orders WHERE status = 'pending';
```

**Rule:** Most selective column first, or column most queried alone.

### Reading EXPLAIN ANALYZE

```sql
EXPLAIN ANALYZE SELECT * FROM orders
WHERE customer_id = 123 AND status = 'pending';
```

| Look For | Meaning | Action |
|----------|---------|--------|
| Seq Scan | Full table scan | Add index |
| Index Scan | Index used | Good |
| Nested Loop (high rows) | N+1 pattern | Rewrite as JOIN |
| Sort (on disk) | Insufficient work_mem | Add index or increase work_mem |
| Hash Join (large) | Big hash table | Check join selectivity |
| rows=estimated vs actual | Stale statistics | Run ANALYZE |

### N+1 Query Problem

```sql
-- BAD: N+1 queries
SELECT * FROM orders;
-- then for each order:
SELECT * FROM customers WHERE id = ?;

-- GOOD: Single JOIN
SELECT orders.*, customers.name
FROM orders
JOIN customers ON orders.customer_id = customers.id;
```

### Optimization Techniques

| Technique | When to Use |
|-----------|-------------|
| Add indexes | Slow WHERE/ORDER BY/JOIN |
| Covering indexes | Avoid table lookups |
| Denormalize | Expensive repeated JOINs |
| Pagination (keyset) | Large result sets |
| Partitioning | Very large tables (100M+ rows) |
| Read replicas | Read-heavy load |
| Connection pooling | Many short-lived connections |

</details>

<details>
<summary><strong>Deep Dive: Data Types & Constraints</strong></summary>

### Numeric Types

| Type | Use Case |
|------|----------|
| INT / BIGINT | IDs, counts |
| DECIMAL(p,s) | Money (exact) |
| FLOAT/DOUBLE | Scientific data (approximate) |

```sql
-- ALWAYS use DECIMAL for money
price DECIMAL(10, 2)  -- up to $99,999,999.99
```

### Date/Time

```sql
-- Always store in UTC
created_at TIMESTAMPTZ DEFAULT NOW()
updated_at TIMESTAMPTZ DEFAULT NOW()
```

### Foreign Keys

```sql
FOREIGN KEY (customer_id) REFERENCES customers(id)
  ON DELETE CASCADE     -- Delete children with parent
  ON DELETE RESTRICT    -- Prevent if referenced
  ON DELETE SET NULL    -- Nullify on parent delete
```

| Strategy | Use When |
|----------|----------|
| CASCADE | Dependent data (order_items) |
| RESTRICT | Important references (prevent accidents) |
| SET NULL | Optional relationships |

### Primary Keys

```sql
-- Auto-increment
id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY

-- UUID (distributed systems)
id UUID PRIMARY KEY DEFAULT gen_random_uuid()

-- Composite (junction tables)
PRIMARY KEY (student_id, course_id)
```

### Check Constraints

```sql
price DECIMAL(10,2) CHECK (price >= 0)
discount INT CHECK (discount BETWEEN 0 AND 100)
email VARCHAR(255) UNIQUE NOT NULL
```

</details>

<details>
<summary><strong>Deep Dive: Relationship Patterns</strong></summary>

### One-to-Many

```sql
CREATE TABLE order_items (
  id INT PRIMARY KEY,
  order_id INT NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  product_id INT NOT NULL,
  quantity INT NOT NULL CHECK (quantity > 0)
);
```

### Many-to-Many

```sql
CREATE TABLE enrollments (
  student_id INT REFERENCES students(id) ON DELETE CASCADE,
  course_id INT REFERENCES courses(id) ON DELETE CASCADE,
  enrolled_at TIMESTAMPTZ DEFAULT NOW(),
  PRIMARY KEY (student_id, course_id)
);
```

### Self-Referencing

```sql
CREATE TABLE employees (
  id INT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  manager_id INT REFERENCES employees(id)
);
```

### Polymorphic

```sql
-- Separate FKs (stronger integrity)
CREATE TABLE comments (
  id INT PRIMARY KEY,
  content TEXT NOT NULL,
  post_id INT REFERENCES posts(id),
  photo_id INT REFERENCES photos(id),
  CHECK (
    (post_id IS NOT NULL AND photo_id IS NULL) OR
    (post_id IS NULL AND photo_id IS NOT NULL)
  )
);
```

</details>

<details>
<summary><strong>Deep Dive: Migrations</strong></summary>

### Adding a Column (Zero-Downtime)

```sql
-- Step 1: Add nullable column
ALTER TABLE users ADD COLUMN phone VARCHAR(20);

-- Step 2: Deploy code that writes to new column
-- Step 3: Backfill existing rows
UPDATE users SET phone = '' WHERE phone IS NULL;

-- Step 4: Make required (if needed)
ALTER TABLE users ALTER COLUMN phone SET NOT NULL;
```

### Renaming a Column (Zero-Downtime)

```sql
-- Step 1: Add new column
ALTER TABLE users ADD COLUMN email_address VARCHAR(255);

-- Step 2: Copy data
UPDATE users SET email_address = email;

-- Step 3: Deploy code reading/writing new column
-- Step 4: Drop old column
ALTER TABLE users DROP COLUMN email;
```

### Migration Template

```sql
-- Migration: YYYYMMDDHHMMSS_description.sql

-- UP
BEGIN;
ALTER TABLE users ADD COLUMN phone VARCHAR(20);
CREATE INDEX idx_users_phone ON users(phone);
COMMIT;

-- DOWN
BEGIN;
DROP INDEX idx_users_phone;
ALTER TABLE users DROP COLUMN phone;
COMMIT;
```

</details>

<details>
<summary><strong>Deep Dive: NoSQL Design (MongoDB)</strong></summary>

### Embedding vs Referencing

| Factor | Embed | Reference |
|--------|-------|-----------|
| Access pattern | Read together | Read separately |
| Relationship | 1:few | 1:many |
| Document size | Small | Approaching 16MB |
| Update frequency | Rarely | Frequently |

### Embedded Document

```json
{
  "_id": "order_123",
  "customer": {
    "id": "cust_456",
    "name": "Jane Smith"
  },
  "items": [
    { "product_id": "prod_789", "quantity": 2, "price": 29.99 }
  ],
  "total": 109.97
}
```

### Referenced Document

```json
{
  "_id": "order_123",
  "customer_id": "cust_456",
  "item_ids": ["item_1", "item_2"],
  "total": 109.97
}
```

</details>

---

## PostgreSQL MCP

When `postgres` MCP is available, use it for:
- Running EXPLAIN ANALYZE on live queries
- Checking pg_stat_statements for slow query patterns
- Inspecting index usage with pg_stat_user_indexes
- Running schema migrations
- Checking table bloat and VACUUM status
