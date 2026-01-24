---
name: database-schema
description: Design robust, scalable database schemas for SQL and NoSQL databases. Provides normalization guidelines, indexing strategies, migration patterns, constraint design, and performance optimization. Use when designing tables, reviewing schemas, or planning migrations.
---

# Database Schema Designer

Design production-ready database schemas with best practices built-in.

## Quick Start

Describe your data model:
```
design a schema for an e-commerce platform with users, products, orders
```

## Process

1. **Analyze**: Identify entities, relationships, access patterns
2. **Design**: Normalize to 3NF, define keys, add constraints
3. **Optimize**: Indexing strategy, consider denormalization
4. **Migrate**: Reversible scripts, backward compatible

## Quick Reference

| Task | Approach |
|------|----------|
| New schema | Normalize to 3NF first |
| SQL vs NoSQL | Access patterns decide |
| Primary keys | INT or UUID (UUID for distributed) |
| Foreign keys | Always constrain, define ON DELETE |
| Indexes | FKs + WHERE columns |
| Migrations | Always reversible |

## Normal Forms

| Form | Rule | Violation |
|------|------|-----------|
| 1NF | Atomic values | `product_ids = '1,2,3'` |
| 2NF | No partial dependencies | customer_name in order_items |
| 3NF | No transitive dependencies | country derived from postal_code |

## Data Types

```sql
-- Money: ALWAYS DECIMAL, never FLOAT
price DECIMAL(10, 2)

-- Timestamps
created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
updated_at TIMESTAMP ON UPDATE CURRENT_TIMESTAMP

-- IDs
id BIGINT AUTO_INCREMENT PRIMARY KEY  -- Simple
id CHAR(36) DEFAULT (UUID())          -- Distributed
```

## Relationships

```sql
-- One-to-Many
CREATE TABLE orders (
  id BIGINT PRIMARY KEY,
  customer_id BIGINT NOT NULL REFERENCES customers(id)
);

-- Many-to-Many (junction table)
CREATE TABLE enrollments (
  student_id BIGINT REFERENCES students(id) ON DELETE CASCADE,
  course_id BIGINT REFERENCES courses(id) ON DELETE CASCADE,
  PRIMARY KEY (student_id, course_id)
);
```

## Indexing

```sql
-- Always index foreign keys
CREATE INDEX idx_orders_customer ON orders(customer_id);

-- Composite: most selective first
CREATE INDEX idx_orders_status_date ON orders(status, created_at);
```

## Anti-Patterns

| Avoid | Instead |
|-------|---------|
| VARCHAR(255) everywhere | Size appropriately |
| FLOAT for money | DECIMAL(10,2) |
| Missing FK constraints | Always define FKs |
| No indexes on FKs | Index every FK |
| Dates as strings | DATE, TIMESTAMP types |
| Non-reversible migrations | Always write DOWN |

## Migration Template

```sql
-- UP
BEGIN;
ALTER TABLE users ADD COLUMN phone VARCHAR(20);
CREATE INDEX idx_users_phone ON users(phone);
COMMIT;

-- DOWN
BEGIN;
DROP INDEX idx_users_phone ON users;
ALTER TABLE users DROP COLUMN phone;
COMMIT;
```

## Checklist

- [ ] Every table has a primary key
- [ ] All relationships have FK constraints
- [ ] ON DELETE strategy defined for each FK
- [ ] Indexes on all FKs and frequently queried columns
- [ ] DECIMAL for money, proper types everywhere
- [ ] NOT NULL on required fields
- [ ] created_at and updated_at timestamps
- [ ] Migrations are reversible
