-- 4.BY城市
 USE dws_db;
CREATE TABLE IF NOT EXISTS dws_city_summary(
  city VARCHAR(20) COMMENT '城市',
  total_amount DECIMAL(18,2) COMMENT '总销售额',
  avg_amount DECIMAL(18,2) COMMENT '客单价',
  order_count BIGINT COMMENT '订单量',
  max_amount DECIMAL(10,2) COMMENT '最大订单金额',
  min_amount DECIMAL(10,2) COMMENT '最小订单金额'
  ) USING PARQUET
  COMMENT '城市订单表汇总';