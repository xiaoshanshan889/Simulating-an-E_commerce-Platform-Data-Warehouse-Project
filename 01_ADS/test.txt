-- 以用户表为例


-- 主键唯一性验证（最重要）
SELECT
user_id,
daily_date,
COUNT(*) AS test
FROM ads_db.ads_user_report
GROUP BY user_id,daily_date
HAVING COUNT(*)>1

-- 空值/异常值校验

-- 校验主键是否为空
SELECT
*
FROM ads_db.ads_user_report
WHERE user_id IS NULL or daily_date IS NULL
-- 校验订单是否存在≤0
SELECT
*
FROM ads_db.ads_user_report
WHERE order_count<=0
-- 校验总金额是否存在≤0
SELECT
*
FROM ads_db.ads_user_report
WHERE total_amount<=0 OR total_amount IS NULL
-- 校验客单价是否为空为0
SELECT 
* 
FROM ads_db.ads_user_report 
WHERE avg_amount<=0 OR avg_amount IS NULL




-- 校验占比合计100%【±0.5波动】
SELECT 
    daily_date,
    ROUND(SUM(daily_prop), 2) AS total_prop
FROM ads_db.ads_user_report
WHERE daily_date = '2024-8-18'
GROUP BY daily_date;

-- 与DWD对账
SELECT 
    'ADS' AS source,
    SUM(total_amount) AS total_amt
FROM ads_db.ads_user_report
WHERE daily_date = '2024-8-18'
UNION ALL
SELECT 
    'DWD' AS source,
    SUM(order_amount) AS total_amt
FROM dwd_db.dwd_orders
WHERE create_date = '2024-8-18'