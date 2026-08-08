SELECT COUNT(*) FROM dwd_db.dwd_orders;
SELECT * FROM dwd_db.dwd_orders LIMIT 10;
SELECT order_id, COUNT(*) FROM dwd_db.dwd_orders GROUP BY order_id HAVING COUNT(*) > 1;