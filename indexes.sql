-- MySQL Indexing Strategies - five index types with EXPLAIN before and after
-- Run schema.sql first. Functional indexes need MySQL 8.0.13+.

USE IndexingDB;

-- =========================================================
-- 1. Unique index: no two clients can share an email
-- =========================================================
EXPLAIN SELECT * FROM clients WHERE client_email = 'client42@example.com';

CREATE UNIQUE INDEX idx_client_email ON clients (client_email);

EXPLAIN SELECT * FROM clients WHERE client_email = 'client42@example.com';

-- Uncomment to see the index reject a duplicate (Error 1062):
-- INSERT INTO clients (client_name, client_email) VALUES ('Copy', 'client42@example.com');

-- =========================================================
-- 2. Composite unique index: one transaction per client, date and type
-- =========================================================
EXPLAIN SELECT * FROM transactions
WHERE client_id = 7 AND transaction_date = '2026-03-15';

CREATE UNIQUE INDEX idx_client_date_type
    ON transactions (client_id, transaction_date, transaction_type);

EXPLAIN SELECT * FROM transactions
WHERE client_id = 7 AND transaction_date = '2026-03-15';

-- Leftmost-prefix rule: filtering on date alone cannot use this index
EXPLAIN SELECT * FROM transactions WHERE transaction_date = '2026-03-15';

-- =========================================================
-- 3. Prefix index: index only the first 10 characters of a long string
-- =========================================================
EXPLAIN SELECT * FROM clients WHERE client_name LIKE 'Client 4%';

CREATE INDEX idx_client_name_prefix ON clients (client_name(10));

EXPLAIN SELECT * FROM clients WHERE client_name LIKE 'Client 4%';

-- =========================================================
-- 4. Descending index: highest priority first, then nearest deadline
-- =========================================================
EXPLAIN SELECT task_name, priority, deadline FROM project_tasks
ORDER BY priority DESC, deadline ASC LIMIT 5;

CREATE INDEX idx_priority_desc_deadline ON project_tasks (priority DESC, deadline ASC);

EXPLAIN SELECT task_name, priority, deadline FROM project_tasks
ORDER BY priority DESC, deadline ASC LIMIT 5;

SELECT task_name, priority, deadline FROM project_tasks
ORDER BY priority DESC, deadline ASC LIMIT 5;

-- =========================================================
-- 5. Functional index: index on MONTH(transaction_date)
-- =========================================================
EXPLAIN SELECT * FROM transactions WHERE MONTH(transaction_date) = 3;

CREATE INDEX idx_txn_month ON transactions ((MONTH(transaction_date)));

EXPLAIN SELECT * FROM transactions WHERE MONTH(transaction_date) = 3;

SELECT MONTH(transaction_date) AS month, COUNT(*) AS total, SUM(amount) AS revenue
FROM transactions
GROUP BY MONTH(transaction_date)
ORDER BY month;
