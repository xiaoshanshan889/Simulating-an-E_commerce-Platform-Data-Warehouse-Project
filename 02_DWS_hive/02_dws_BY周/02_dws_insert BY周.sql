INSERT OVERWRITE TABLE dws_db.dws_weekly_summary
  SELECT
  SUM(order_amount) AS total_amount,
  ROUND(AVG(order_amount),2) AS avg_amount,
  COUNT(*) AS order_count,   -- 不用count(order_id)是防止order_id = NULL时导致漏算
  MAX(order_amount) AS max_amount,
  MIN(order_amount) AS min_amount,
  CAST(CONCAT(YEAR(create_date), LPAD(WEEKOFYEAR(create_date), 2, '0')) AS INT) AS weekly_date
  FROM dwd_db.dwd_orders
  GROUP BY CAST(CONCAT(YEAR(create_date), LPAD(WEEKOFYEAR(create_date), 2, '0')) AS INT);