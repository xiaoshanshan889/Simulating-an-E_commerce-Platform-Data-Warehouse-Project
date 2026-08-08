INSERT OVERWRITE TABLE dws_db.dws_category_summary
  SELECT
  SUM(order_amount) AS total_amount,
  ROUND(AVG(order_amount),2) AS avg_amount,
  COUNT(*) AS order_count,
  MAX(order_amount) AS max_amount,
  MIN(order_amount) AS min_amount,
  category_id
  FROM dwd_db.dwd_orders
  GROUP BY category_id;