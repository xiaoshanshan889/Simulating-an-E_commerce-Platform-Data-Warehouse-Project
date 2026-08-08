-- 插入类目数据
INSERT overwrite table ods_categories (category_id, category_name, parent_category_id) VALUES
(1, '服装', 0), (2, '鞋包', 0), (3, '家电', 0), (4, '数码', 0), (5, '食品', 0),
(11, '男装', 1), (12, '女装', 1), (21, '运动鞋', 2), (22, '箱包', 2),
(31, '冰箱', 3), (32, '洗衣机', 3), (41, '手机', 4), (42, '电脑', 4),
(51, '休闲食品', 5), (52, '饮料', 5);

-- 先把之前的存储过程删掉
DROP PROCEDURE IF EXISTS insert_orders_batch;

-- 创建一个接收批次参数的存储过程
DELIMITER //
CREATE PROCEDURE insert_orders_batch(IN batch_start INT, IN batch_size INT)
BEGIN
    DECLARE i INT DEFAULT 0;
    DECLARE order_status VARCHAR(20);
    DECLARE status_num INT;
    DECLARE order_date DATETIME;
    DECLARE current_id INT;
    
    -- 从batch_start开始，连续插入batch_size条
    SET current_id = batch_start;
    WHILE i < batch_size DO
        SET status_num = FLOOR(1 + RAND() * 100);
        SET order_status = CASE
            WHEN status_num <= 80 THEN 'completed'
            WHEN status_num <= 90 THEN 'paid'
            WHEN status_num <= 95 THEN 'shipped'
            ELSE 'cancelled'
        END;
        SET order_date = DATE_ADD('2024-01-01', INTERVAL FLOOR(RAND() * 365) DAY);
        
        INSERT INTO ods_orders (order_id, user_id, product_id, category_id, order_amount, order_status, create_time, update_time)
        VALUES (
            current_id,
            FLOOR(1 + RAND() * 10000),
            FLOOR(1 + RAND() * 1000),
            FLOOR(1 + RAND() * 15),
            ROUND(10 + RAND() * 990, 2),
            order_status,
            order_date,
            DATE_ADD(order_date, INTERVAL FLOOR(RAND() * 7) DAY)
        );
        SET i = i + 1;
        SET current_id = current_id + 1;
    END WHILE;
END//
DELIMITER ;

-- =============================================
-- 分10批执行，每批5000条，共5万条
-- 每批之间间隔1秒，避免超时
-- =============================================
CALL insert_orders_batch(1, 5000);
SELECT SLEEP(1);
CALL insert_orders_batch(5001, 5000);
SELECT SLEEP(1);
CALL insert_orders_batch(10001, 5000);
SELECT SLEEP(1);
CALL insert_orders_batch(15001, 5000);
SELECT SLEEP(1);
CALL insert_orders_batch(20001, 5000);
SELECT SLEEP(1);
CALL insert_orders_batch(25001, 5000);
SELECT SLEEP(1);
CALL insert_orders_batch(30001, 5000);
SELECT SLEEP(1);
CALL insert_orders_batch(35001, 5000);
SELECT SLEEP(1);
CALL insert_orders_batch(40001, 5000);
SELECT SLEEP(1);
CALL insert_orders_batch(45001, 5000);
