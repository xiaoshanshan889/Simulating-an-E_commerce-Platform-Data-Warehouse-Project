CREATE DATABASE IF NOT EXISTS dwd_db;

CREATE TABLE IF NOT EXISTS dwd_db.dwd_orders(
  order_id BIGINT COMMENT '订单号',
  user_id BIGINT COMMENT '用户id',
  product_id INT COMMENT '产品',
  category_id INT COMMENT '商品类目',
  order_amount DECIMAL(18,2) COMMENT '订单金额',
  amount_status VARCHAR(20) COMMENT '金额状态',
  order_status VARCHAR(50) COMMENT '订单状态',
  create_date DATE COMMENT '创建时间',
  update_time TIMESTAMP COMMENT '最新记录',
  order_year INT COMMENT '订单年份',
  user_name STRING COMMENT '用户姓名',
  city STRING COMMENT '城市',
  category_name STRING COMMENT '商品类目名称'
) USING PARQUET
COMMENT '订单明细表-清洗后';