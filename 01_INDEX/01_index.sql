EXPLAIN SELECT
    user_id,
    COUNT(*) AS order_count,
    SUM(order_amount) AS total_spent
FROM dwd_db.dwd_orders
WHERE create_date >= '2024-01-01'
  AND create_date < '2025-01-01'
GROUP BY user_id
ORDER BY total_spent DESC
LIMIT 10;

CREATE INDEX idx_date_user ON dwd_db.dwd_orders (create_date, user_id);
EXPLAIN SELECT
    user_id,
    COUNT(*) AS order_count,
    SUM(order_amount) AS total_spent
FROM dwd_db.dwd_orders FORCE INDEX (idx_date_user)
WHERE create_date >= '2024-01-01'
  AND create_date < '2025-01-01'
GROUP BY user_id
ORDER BY total_spent DESC
LIMIT 10;