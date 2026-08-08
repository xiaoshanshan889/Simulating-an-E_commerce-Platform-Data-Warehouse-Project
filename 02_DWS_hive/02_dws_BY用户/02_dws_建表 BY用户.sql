-- 5.BY用户
 USE dws_db;
CREATE TABLE IF NOT EXISTS dws_user_summary(
  total_amount DECIMAL(18,2) COMMENT '总销售额',
  avg_amount DECIMAL(18,2) COMMENT '客单价',
  order_count BIGINT COMMENT '订单量',
  max_amount DECIMAL(10,2) COMMENT '最大订单金额',
  min_amount DECIMAL(10,2) COMMENT '最小订单金额'
  ) USING PARQUET PARTITIONED BY (user_id BIGINT)
  COMMENT '用户订单表汇总';