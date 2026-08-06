-- 3.BY月
 USE dws_db;
CREATE TABLE IF NOT EXISTS dws_monthly_summary(
  monthly_date VARCHAR(20) PRIMARY KEY COMMENT '创建时间',
  total_amount DECIMAL(18,2) COMMENT '总销售额',
  avg_amount DECIMAL(18,2) COMMENT '客单价',
  order_count BIGINT COMMENT '订单量',
  max_amount DECIMAL(10,2) COMMENT '最大订单金额',
  min_amount DECIMAL(10,2) COMMENT '最小订单金额'
  ) COMMENT '每月订单表汇总';