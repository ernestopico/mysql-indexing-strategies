-- MySQL Indexing Strategies - schema and data
-- Ernesto Pico

DROP DATABASE IF EXISTS IndexingDB;
CREATE DATABASE IndexingDB;
USE IndexingDB;

CREATE TABLE clients (
    client_id     INT AUTO_INCREMENT PRIMARY KEY,
    client_name   VARCHAR(100) NOT NULL,
    client_email  VARCHAR(100) NOT NULL,
    phone         VARCHAR(20),
    city          VARCHAR(50)
);

CREATE TABLE transactions (
    transaction_id    INT AUTO_INCREMENT PRIMARY KEY,
    client_id         INT NOT NULL,
    transaction_date  DATE NOT NULL,
    transaction_type  VARCHAR(20) NOT NULL,
    amount            DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (client_id) REFERENCES clients(client_id)
);

CREATE TABLE project_tasks (
    task_id      INT AUTO_INCREMENT PRIMARY KEY,
    task_name    VARCHAR(100) NOT NULL,
    priority     INT NOT NULL,
    deadline     DATE NOT NULL,
    assigned_to  VARCHAR(50)
);

-- 50 clients
SET SESSION cte_max_recursion_depth = 20000;

INSERT INTO clients (client_name, client_email, phone, city)
WITH RECURSIVE seq (n) AS (
    SELECT 1 UNION ALL SELECT n + 1 FROM seq WHERE n < 50
)
SELECT CONCAT('Client ', n),
       CONCAT('client', n, '@example.com'),
       CONCAT('901-555-', LPAD(n, 4, '0')),
       ELT(1 + n % 5, 'Memphis', 'Manta', 'Chicago', 'Miami', 'Nashville')
FROM seq;

-- 10,000 transactions (one per client per day, so client + date + type stays unique)
INSERT INTO transactions (client_id, transaction_date, transaction_type, amount)
WITH RECURSIVE seq (n) AS (
    SELECT 0 UNION ALL SELECT n + 1 FROM seq WHERE n < 9999
)
SELECT 1 + n % 50,
       DATE_ADD('2026-01-01', INTERVAL n DIV 50 DAY),
       ELT(1 + n % 3, 'Purchase', 'Refund', 'Payment'),
       ROUND(10 + (n * 37) % 990, 2)
FROM seq;

-- 2,000 project tasks with priorities 1-5
INSERT INTO project_tasks (task_name, priority, deadline, assigned_to)
WITH RECURSIVE seq (n) AS (
    SELECT 1 UNION ALL SELECT n + 1 FROM seq WHERE n < 2000
)
SELECT CONCAT('Task ', n),
       1 + (n * 7) % 5,
       DATE_ADD('2026-01-01', INTERVAL (n * 13) % 365 DAY),
       ELT(1 + n % 4, 'Alice', 'Bob', 'Charlie', 'Dana')
FROM seq;
