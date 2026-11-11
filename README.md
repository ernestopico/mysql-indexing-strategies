# MySQL Indexing Strategies

A hands-on comparison of five MySQL index types. Each one is measured with `EXPLAIN` before and after the index is created, on generated data (50 clients, 10,000 transactions, 2,000 tasks), to show how much work the query optimizer saves.

Based on an indexing project for ECE 471 (Design of Database Systems) at Christian Brothers University, rebuilt as a self-contained database.

## Results

| # | Index type | Query | Before | After |
|---|------------|-------|--------|-------|
| 1 | Unique | Look up a client by email | Full scan, 50 rows | `const`, 1 row |
| 2 | Composite unique | Transactions for one client on one date | 200 rows via the client FK index | 1 row |
| 3 | Prefix | Client names starting with `'Client 4'` | Full scan, 50 rows | `range`, 11 rows |
| 4 | Descending | Top 5 tasks by priority, then deadline | 2,000 rows + filesort | 5 rows, no sort |
| 5 | Functional | Transactions in March, `MONTH(date) = 3` | Full scan, ~10,000 rows | `ref`, 1,550 rows |

Row counts are the optimizer's estimates from `EXPLAIN` on MySQL 8.0.

## What each index shows

1. **Unique index.** Speeds up lookups, and also enforces a rule: two clients can't share an email (Error 1062).
2. **Composite index.** Combines three columns into one key. It follows the *leftmost-prefix rule*: a filter on `client_id` (+ `transaction_date`) uses it, but a filter on `transaction_date` alone can't. The script includes that case so you can see it fall back to a full scan.
3. **Prefix index.** Indexes only the first 10 characters of `client_name`, which makes the index smaller while still supporting `LIKE 'abc%'` searches.
4. **Descending index.** `(priority DESC, deadline ASC)` matches the `ORDER BY` exactly, so MySQL reads rows already in order and stops after 5, with no sorting step.
5. **Functional index.** Wrapping a column in a function, like `MONTH(transaction_date)`, normally stops a regular index from being used. Indexing the expression itself fixes that.

## How to run

Requires MySQL 8.0.13+ (for functional and descending indexes).

```bash
mysql -u root -p < schema.sql
mysql -u root -p < indexes.sql
```

Or open both files in MySQL Workbench and run `schema.sql` first. The data is generated with recursive CTEs, so there are no CSV files to import.

## Files

- `schema.sql`: creates the database and tables, and generates the data
- `indexes.sql`: for each strategy, runs `EXPLAIN`, creates the index, then runs `EXPLAIN` again

## License

MIT
