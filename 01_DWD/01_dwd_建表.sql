-- 清洗异常值、空值、重复值【清洗订单表ODS→DWD】创建表→插入数据
USE dwd_db;
CREATE TABLE IF NOT EXISTS dwd_db.dwd_orders(
  -- 字段名 类型 COMMENT'备注'
  order_id BIGINT PRIMARY KEY COMMENT '订单号',
  user_id BIGINT COMMENT '用户id',
  product_id INT COMMENT '产品',
  category_id INT COMMENT '商品类目',
  order_amount DECIMAL(18,2) COMMENT'订单金额',
  金额状态 VARCHAR(20) COMMENT'金额状态',
  order_status VARCHAR(50) COMMENT '订单状态',
  create_date DATETIME COMMENT '创建时间',
  update_time DATETIME COMMENT '最新记录',
  order_year INT COMMENT '订单年份'
   ) COMMENT '订单明细表-清洗后';