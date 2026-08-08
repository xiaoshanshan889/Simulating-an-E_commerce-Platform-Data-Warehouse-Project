CREATE TEMPORARY VIEW ods_orders_view
USING jdbc
OPTIONS (
  url 'jdbc:mysql://host.docker.internal:3306/ods_db',
  dbtable 'ods_orders',
  user 'root',
  password '123456'
);

CREATE TEMPORARY VIEW ods_users_view
USING jdbc
OPTIONS (
  url 'jdbc:mysql://host.docker.internal:3306/ods_db',
  dbtable 'ods_users',
  user 'root',
  password '123456'
);

CREATE TEMPORARY VIEW ods_categories_view
USING jdbc
OPTIONS (
  url 'jdbc:mysql://host.docker.internal:3306/ods_db',
  dbtable 'ods_categories',
  user 'root',
  password '123456'
);

INSERT OVERWRITE TABLE dwd_db.dwd_orders
WITH
clean_orders AS(
  SELECT
    order_id,
    user_id,
    product_id,
    category_id,
    order_amount,
    CASE
      WHEN order_amount < 0 THEN '负值'
      WHEN order_amount > 100000 THEN '过大'
      ELSE '正常'
    END AS amount_status,
    CASE
      WHEN order_status = 'paid' THEN '已支付'
      WHEN order_status = 'completed' THEN '已发货'
      WHEN order_status = 'shipped' THEN '发货中'
      WHEN order_status = 'cancelled' THEN '已取消'
      ELSE '异常'
    END AS order_status,
    DATE(create_time) AS create_date,
    update_time,
    ROW_NUMBER() OVER(PARTITION BY order_id ORDER BY update_time DESC, order_id DESC) AS latest_record,
    YEAR(create_time) AS order_year
  FROM ods_orders_view
  WHERE order_status IN ('paid','completed','shipped')
),
clean_users AS(
  SELECT
    user_id,
    LOWER(TRIM(IFNULL(user_name,'未知用户'))) AS user_name,
    TRIM(IFNULL(city,'未知城市')) AS city
  FROM ods_users_view
),
clean_categories AS(
  SELECT
    TRIM(IFNULL(category_name,'未知类目')) AS category_name,
    category_id
  FROM ods_categories_view
)
SELECT
  co.order_id,
  co.user_id,
  co.product_id,
  co.category_id,
  co.order_amount,
  co.amount_status,
  co.order_status,
  co.create_date,
  co.update_time,
  co.order_year,
  cu.user_name,
  cu.city,
  cc.category_name
FROM clean_orders co
LEFT JOIN clean_users cu ON co.user_id = cu.user_id
LEFT JOIN clean_categories cc ON co.category_id = cc.category_id
WHERE co.latest_record = 1;