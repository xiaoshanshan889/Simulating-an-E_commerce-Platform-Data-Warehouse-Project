 INSERT INTO ads_db.ads_city_report
  WITH
  -- 每个城市的每日总数据
  daily_city_total AS(
  SELECT
  cs.city,
  ds.create_time AS daily_date,
  ds.order_count,
  cs.total_amount,
  ROUND(cs.total_amount/NULLIF(cs.order_count,0),2) AS avg_amount
  FROM dws_db.dws_daily_summary ds
  CROSS JOIN dws_db.dws_city_summary cs
  ),
  
  -- 把当天的数据与前1天，前7天，前30天拼在同一条数据里
  city_with_pre AS(
  SELECT
  today.city,
  today.daily_date,
  today.order_count,
  today.total_amount,
  today.avg_amount,
  -- 日环比
  COALESCE(yesterday.total_amount,0) AS pre_daily_total_amount,
  -- 周环比
  COALESCE(week_ago.total_amount,0) AS pre_weekly_total_amount,
  -- 月环比
  COALESCE(month_ago.total_amount,0) AS pre_monthly_total_amount
  FROM daily_city_total today
  LEFT JOIN daily_city_total yesterday
  ON yesterday.city = today.city
  AND yesterday.daily_date = DATE_SUB(today.daily_date,INTERVAL 1 DAY)
  LEFT JOIN daily_city_total week_ago
  ON week_ago.city = today.city
  AND week_ago.daily_date = DATE_SUB(today.daily_date,INTERVAL 7 DAY)
  LEFT JOIN daily_city_total month_ago
  ON month_ago.city = today.city
  AND month_ago.daily_date = DATE_SUB(today.daily_date,INTERVAL 30 DAY)
  ),
  
  
  -- 每日平台全天销售额
  platform_daily AS(
  SELECT 
  create_date,
  SUM(order_amount) AS platform_total
  FROM dwd_db.dwd_orders
  GROUP BY create_date
)
  
  -- 计算环比
  SELECT
  cp.city,
  cp.daily_date,
  cp.order_count,
  cp.total_amount,
  cp.avg_amount,
  cp.pre_daily_total_amount,
  cp.pre_weekly_total_amount,
  cp.pre_monthly_total_amount,
  -- 计算日环比
  ROUND((cp.total_amount - cp.pre_daily_total_amount)/NULLIF(cp.pre_daily_total_amount,0) *100,2) AS growth_rate_daily,
  ROUND((cp.total_amount - cp.pre_weekly_total_amount)/NULLIF(cp.pre_weekly_total_amount,0) *100,2) AS growth_rate_weekly,
  ROUND((cp.total_amount - cp.pre_monthly_total_amount)/NULLIF(cp.pre_monthly_total_amount,0) *100,2) AS growth_rate_monthly,
  -- 算占比
  ROUND(cp.total_amount/NULLIF(pd.platform_total,0)*100,2) AS daily_prop
  FROM city_with_pre cp
  LEFT JOIN platform_daily pd
  ON cp.daily_date = pd.create_date
  ORDER BY cp.daily_date,cp.total_amount