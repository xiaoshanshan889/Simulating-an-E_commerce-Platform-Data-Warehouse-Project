INSERT INTO dws_daily_summary
  SELECT
  DATE(create_date) AS daily_date,
  SUM(order_amount) AS total_amount,
  ROUND(AVG(order_amount),2) AS avg_amount,
  COUNT(*) AS order_count,  -- -- 不用count(order_id)是防止order_id = NULL时导致漏算
  MAX(order_amount) AS max_amount,
  MIN(order_amount) AS min_amount
  FROM dwd_db.dwd_orders
  GROUP BY DATE(create_date);