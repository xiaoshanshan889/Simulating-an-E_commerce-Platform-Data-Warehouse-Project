-- DWS就是“按维度汇总”，把明细变成汇总，查询更快【BY日、BY城市、BY类目】
-- 按照6个常用维度聚合，分别建表插入数据
-- 1.BY日
USE dws_db;
CREATE TABLE IF NOT EXISTS dws_daily_summary(
  daily_date DATE PRIMARY KEY COMMENT '创建时间',
  total_amount DECIMAL(18,2) COMMENT '总销售额',
  avg_amount DECIMAL(18,2) COMMENT '客单价',
  order_count BIGINT COMMENT '订单量',
  max_amount DECIMAL(10,2) COMMENT '最大订单金额',
  min_amount DECIMAL(10,2) COMMENT '最小订单金额'
  ) COMMENT '每日订单表汇总';