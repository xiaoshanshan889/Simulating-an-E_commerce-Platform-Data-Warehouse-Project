INSERT INTO dws_user_summary
  SELECT
  user_id,
  SUM(order_amount) AS total_amount,
  ROUND(AVG(order_amount),2) AS avg_amount,
  COUNT(*) AS order_count,
  MAX(order_amount) AS max_amount,
  MIN(order_amount) AS min_amount
  FROM dwd_db.dwd_orders
  GROUP BY user_id;