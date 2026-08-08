INSERT OVERWRITE TABLE ads_db.ads_user_report
WITH
  -- 每个用户的每日总数据
daily_user_total AS(
  SELECT
    user_id,
    create_date AS daily_date,
    MAX(city) AS city,
    COUNT(*) AS order_count,
    SUM(order_amount) AS total_amount,
    ROUND(SUM(order_amount) / NULLIF(COUNT(*), 0), 2) AS avg_amount
  FROM dwd_db.dwd_orders
  GROUP BY user_id, create_date
),
  
  -- 把当天的数据与前1天，前7天，前30天拼在同一条数据里
  user_with_pre AS(
  SELECT
  today.user_id,
  today.daily_date,
  today.city,
  today.order_count,
  today.total_amount,
  today.avg_amount,
  -- 日环比
  COALESCE(yesterday.total_amount,0) AS pre_daily_total_amount,
  -- 周环比
  COALESCE(week_ago.total_amount,0) AS pre_weekly_total_amount,
  -- 月环比
  COALESCE(month_ago.total_amount,0) AS pre_monthly_total_amount
  FROM daily_user_total today
  LEFT JOIN daily_user_total yesterday
  ON yesterday.user_id = today.user_id
  AND yesterday.daily_date = DATE_SUB(today.daily_date,1)
  LEFT JOIN daily_user_total week_ago
  ON week_ago.user_id = today.user_id
  AND week_ago.daily_date = DATE_SUB(today.daily_date,7)
  LEFT JOIN daily_user_total month_ago
  ON month_ago.user_id = today.user_id
  AND month_ago.daily_date = DATE_SUB(today.daily_date,30)
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
  up.user_id,
  up.daily_date,
  up.city,
  up.order_count,
  up.total_amount,
  up.avg_amount,
  up.pre_daily_total_amount,
  up.pre_weekly_total_amount,
  up.pre_monthly_total_amount,
  -- 计算日环比
  ROUND((up.total_amount - up.pre_daily_total_amount)/NULLIF(up.pre_daily_total_amount,0) *100,2) AS growth_rate_daily,
  ROUND((up.total_amount - up.pre_weekly_total_amount)/NULLIF(up.pre_weekly_total_amount,0) *100,2) AS growth_rate_weekly,
  ROUND((up.total_amount - up.pre_monthly_total_amount)/NULLIF(up.pre_monthly_total_amount,0) *100,2) AS growth_rate_monthly,
  -- 算占比
  ROUND(up.total_amount/NULLIF(pd.platform_total,0)*100,2) AS daily_prop
  FROM user_with_pre up
  LEFT JOIN platform_daily pd
  ON up.daily_date = pd.create_date
  ORDER BY up.daily_date,up.total_amount
  
  -- SELECT COUNT(*) FROM ads_db.ads_user_report;