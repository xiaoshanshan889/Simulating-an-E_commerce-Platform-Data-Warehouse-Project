USE dwd_db;

UPDATE dwd_db.dwd_orders 
SET category_name = '未知类目' 
WHERE category_name IS NULL;

SELECT ROW_COUNT() AS 修复行数;