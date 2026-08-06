INSERT INTO ads_db.ads_category_report
  WITH
   -- 每个类目的每日总数据
   daily_category_total AS(
  SELECT
  do.category_id,
  do.create_date AS daily_date,
  MAX(category_name) AS category_name,
  COUNT(*) AS order_count,
  SUM(order_amount) AS total_amount,
  ROUND((SUM(order_amount))/NULLIF(COUNT(*),0),2) AS avg_amount
  FROM dwd_db.dwd_orders do
  GROUP BY do.category_id,create_date
   ),
  
  -- 把当天的数据与前1天，前7天，前30天拼在同一条数据里
  category_with_pre AS(
  SELECT
  today.category_id,
  today.daily_date,
  today.category_name,
  today.order_count,
  today.total_amount,
  today.avg_amount,
  -- 日环比
  COALESCE(yesterday.total_amount,0) AS pre_daily_total_amount,
  -- 周环比
  COALESCE(week_ago.total_amount,0) AS pre_weekly_total_amount,
  -- 月环比
  COALESCE(month_ago.total_amount,0) AS pre_monthly_total_amount
  FROM daily_category_total today
  LEFT JOIN daily_category_total yesterday
  ON yesterday.category_id = today.category_id
  AND yesterday.daily_date = DATE_SUB(today.daily_date,INTERVAL 1 DAY)
  LEFT JOIN daily_category_total week_ago
  ON week_ago.category_id = today.category_id
  AND week_ago.daily_date = DATE_SUB(today.daily_date,INTERVAL 7 DAY)
  LEFT JOIN daily_category_total month_ago
  ON month_ago.category_id = today.category_id
  AND month_ago.daily_date = DATE_SUB(today.daily_date,INTERVAL 30 DAY)
  ),
  
  -- 每日平台全天销售额
  platform_daily AS (
  SELECT 
  create_date, 
  SUM(order_amount) AS platform_total
  FROM dwd_db.dwd_orders
  GROUP BY create_date
)
  
  -- 计算环比
  SELECT
  cate.category_id,
  cate.daily_date,
  cate.category_name,
  cate.order_count,
  cate.total_amount,
  cate.avg_amount,
  cate.pre_daily_total_amount,
  cate.pre_weekly_total_amount,
  cate.pre_monthly_total_amount,
  -- 计算日环比
  ROUND((cate.total_amount - cate.pre_daily_total_amount)/NULLIF(cate.pre_daily_total_amount,0) *100,2) AS growth_rate_daily,
  ROUND((cate.total_amount - cate.pre_weekly_total_amount)/NULLIF(cate.pre_weekly_total_amount,0) *100,2) AS growth_rate_weekly,
  ROUND((cate.total_amount - cate.pre_monthly_total_amount)/NULLIF(cate.pre_monthly_total_amount,0) *100,2) AS growth_rate_monthly,
  -- 算占比
  ROUND(cate.total_amount/NULLIF(platform_total,0)*100,2) AS daily_prop
  FROM category_with_pre cate
  LEFT JOIN dws_db.dws_daily_summary ds
  ON cate.daily_date = ds.create_time
  LEFT JOIN platform_daily pd
  ON cate.daily_date = pd.create_date 
  ORDER BY cate.daily_date,cate.total_amount