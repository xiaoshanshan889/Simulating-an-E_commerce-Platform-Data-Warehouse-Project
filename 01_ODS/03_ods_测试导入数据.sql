-- =============================================
-- 验证最终数据量
-- =============================================
SELECT COUNT(*) AS total_orders FROM ods_orders;
SELECT 'completed' AS status, COUNT(*) AS cnt FROM ods_orders WHERE order_status = 'completed'
UNION ALL
SELECT 'paid', COUNT(*) FROM ods_orders WHERE order_status = 'paid'
UNION ALL
SELECT 'shipped', COUNT(*) FROM ods_orders WHERE order_status = 'shipped'
UNION ALL
SELECT 'cancelled', COUNT(*) FROM ods_orders WHERE order_status = 'cancelled';