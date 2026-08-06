-- 用cte分别清洗不同的表最后聚合
  -- 订单表、用户表、类目表
  -- 有效订单（已完成+已支付+已发货），并且时间格式统一，还要关联上用户的城市和类目名称
  INSERT INTO dwd_db.dwd_orders
  WITH
  clean_orders AS(
  SELECT
  order_id,
  user_id,
  product_id,
  category_id,
  -- -- 数值ID：绝不TRIM，绝不IFNULL
  order_amount,
  CASE 
	WHEN order_amount<0 THEN
		'有误_金额为负'
  WHEN order_amount>100000 THEN
  '有误_金额过大'
	ELSE 
		'正常'
    END AS 金额状态,
    CASE 
	WHEN order_status = 'paid' THEN
		'已支付'
    WHEN order_status = 'completed' THEN
    '已发货'
    WHEN order_status = 'shipped' THEN
    '发货中'
    WHEN order_status = 'cancelled' THEN
    '已取消'
	ELSE '异常'
END AS order_status,
  DATE(create_time) AS create_date,
  update_time,
  ROW_NUMBER() OVER(PARTITION by order_id ORDER BY update_time DESC) AS 最新记录,
  YEAR(create_time) AS order_year
  FROM ods_db.ods_orders
  WHERE order_status IN ('paid','completed','shipped')
  ),
  
  clean_users AS(
  SELECT
  user_id,
  LOWER(TRIM(IFNULL(user_name,'未知用户'))) AS user_name,
  TRIM(IFNULL(city,'未知城市'))AS city
  FROM ods_db.ods_users
  ),
  
  clean_categories AS(
  SELECT
  TRIM(IFNULL(category_name,'未知类目')) AS 类目名称,
  category_id
  FROM ods_db.ods_categories
  )
  
  SELECT
  co.order_id,
  co.user_id,
  co.product_id,
  co.category_id,
  co.order_amount,
  co.金额状态,
  co.order_status,
  co.create_date,
  co.update_time,
  co.order_year,
  cu.user_name,
  cu.city,
  cc.类目名称
  FROM clean_orders co
  LEFT JOIN clean_users cu
  ON co.user_id = cu.user_id
  LEFT JOIN clean_categories cc
  ON co.category_id = cc.category_id
  WHERE co.最新记录 = 1