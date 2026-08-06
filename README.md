 # 电商数仓项目
- 从 MySQL 到分布式数仓的完整实践项目，模拟电商平台数据的日常工作。

## 项目背景
本项目从零搭建了一套电商数据仓库，覆盖 ODS → DWD → DWS → ADS 四层建模，并完成了 SQL 性能优化。
目标是能够快速看到：
- 每日/每周/每月的 GMV 和订单量
- 各城市、各品类的销售排行
- 核心用户画像和购买行为

---
## 实施计划：
- v1.0：基于 MySQL 的基础数仓 ✅  
- v2.0：基于 Docker + Hive + Spark SQL 的分布式数仓（进行中）  
- v3.0：基于Kafka + Flink 实时流统计（计划）  

---
## 技术栈：
| 版本 | 技术栈 |
|------|--------|
| v1.0 | MySQL 8.0, SQL, Navicat |
| v2.0 | Docker, Hive, Spark SQL, PySpark |
| v3.0（计划） | Kafka, Flink, Redis |

---
### 数仓分层架构

**ODS（操作数据存储层）**  
↓ 数据清洗（去空值、去异常、格式转换）  
**DWD（数据明细层）**  
↓ 关联维表生成宽表  
**DWS（数据汇总层）**  
↓ 按日/周/月/城市/品类/用户汇总  
**ADS（应用数据层）**  
↓ 生成最终报表  
运营方可获取

---

### 各层说明

| 层级 | 表名 | 说明 |
| --- | --- | --- |
| ODS | ods_orders | 原始订单数据，从业务库同步 |
| DWD | dwd_orders_base | 清洗后的订单明细 |
| DWD | dwd_orders_wide | 宽表（关联用户/商品维表） |
| DWS | dws_daily_summary | 日汇总（GMV、订单量） |
| DWS | dws_weekly_summary | 周汇总 |
| DWS | dws_monthly_summary | 月汇总 |
| DWS | dws_city_summary | 城市维度汇总 |
| DWS | dws_category_summary | 品类维度汇总 |
| DWS | dws_user_summary | 用户维度汇总 |
| ADS | ads_city_report | 城市报表（最终展示） |
| ADS | ads_user_report | 用户报表（最终展示） |
| ADS | ads_category_report | 品类报表（最终展示） |

---
# 性能优化成果：  
针对 DWD 宽表的慢查询问题，通过 EXPLAIN 分析执行计划，建立组合索引进行优化：   

 ## 性能优化前后对比：
| 指标 | 优化前 | 优化后 |
|------|--------|--------|
| 执行计划 type | ALL（全表扫描） | range（范围扫描） |
| 扫描行数 | 47,392 行 | 23,696 行 |
| 使用索引 | 无 | idx_date_user |
| Extra | Using temporary; Using filesort | Using index condition |

**优化效果：扫描行数减少 50%**  
 优化原理：利用 B+Tree 索引的最左前缀原则，将查询条件 create_date 放在组合索引首位，实现快速过滤。 
