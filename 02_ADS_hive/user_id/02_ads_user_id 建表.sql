-- 日期+用户、日期+城市、日期+类目
-- 所谓环比、占比、趋势，都是附着在某个维度上的值
-- 整个数仓建设都遵循建表→insert→测试
-- 1.用户主题报表
CREATE TABLE IF NOT EXISTS ads_db.ads_user_report(
  -- NOT NULL 本身不会筛选掉 NULL，它只是一个“警报器”。如果插入时数据里有 NULL，它会直接报错，逼你回到 DWS 层（或者在 INSERT 语句里）去处理掉这个 NULL。
  -- 主键
  user_id BIGINT NOT NULL COMMENT '用户ID',
  daily_date DATE NOT NULL COMMENT '日期',
  -- 描述指标
  city VARCHAR(20) NOT NULL COMMENT '城市',
  -- 指标
  order_count INT NOT NULL COMMENT '订单量',
  total_amount DECIMAL(18,2) NOT NULL COMMENT '总金额',
  avg_amount DECIMAL(18,2) NOT NULL COMMENT '客单价',
  -- （今天销售额-前一天销售额）/今日销售额=增长销售率→日环比
  pre_daily_total_amount DECIMAL(18,2) DEFAULT 0 COMMENT '前一天销售额',
  growth_rate_daily DECIMAL(18,2) DEFAULT 0 COMMENT '日环比',
  -- 周环比
  pre_weekly_total_amount DECIMAL(18,2) DEFAULT 0 COMMENT '7日前销售额',
  growth_rate_weekly DECIMAL(18,2) DEFAULT 0 COMMENT '周环比',
  -- 月环比
  pre_monthly_total_amount DECIMAL(18,2) DEFAULT 0 COMMENT '30日前销售额',
  growth_rate_monthly DECIMAL(18,2) DEFAULT 0 COMMENT '月环比',
  -- 占比
  daily_prop DECIMAL(18,2) DEFAULT 0 COMMENT '占当日全平台比例（%）'
  ) USING PARQUET
  COMMENT '用户日度报表（含日/周/月环比）';
