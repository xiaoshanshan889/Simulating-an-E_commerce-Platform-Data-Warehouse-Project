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
- v2.0：基于 Docker + Hive + Spark SQL 的分布式数仓✅
- v3.0：基于Kafka + Flink 实时流统计（进行中）  

---
## 技术栈：
| 版本 | 技术栈 |
|------|--------|
| v1.0 | MySQL 8.0, SQL, Navicat |
| v2.0 | Docker,JDBC, Spark SQL, PySpark |
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


 # 补充v2.0：
在 v1.0 MySQL 单机数仓的基础上，将计算引擎升级为 Spark SQL，通过 Docker Compose 搭建分布式数仓环境，完成 ODS → DWD → DWS → ADS 四层 ETL。  
核心目标：验证大数据量下 Spark 对比 MySQL 的性能优势。  

| | v1.0 | v2.0 |
|---|---|---|
| 计算引擎 | MySQL | Spark SQL (3.5.4) |
| 数据量 | 4.7 万 | 5000 万 |
| 存储 | MySQL InnoDB | Parquet (列式存储) |
| 环境 | 单机 MySQL | Docker Compose (Spark + Metastore) |
| 持久化 | 天然持久化 | Docker Volume |
| 分区 | 无 | DWS 6 张表按维度分区 |

---
# 结论
- Spark 在 5000 万行数据量下，聚合查询仅需 7.2s
- 数据量增长 10 倍，查询时间仅增长 **2.2 倍**，验证近线性扩展
- MySQL 单机环境下，同等数据量写入和查询性能严重退化
 
 ## 聚合查询
 | 数据量 | MySQL | Spark | 差距 |
|---|---|---|---|
| 500 万 | 4.7s | 3.3s | 0.7s——Spark比MySQL快**30%** |
| 5000 万 | 21.4s（2500万） | 7.2s | 14.2s——Spark比MySQL快**66.4%** |

## 扩展性
| 指标 | 数值 |
|---|---|
| 数据量增长 | 10 倍（500万 → 5000万） |
| Spark 耗时增长 | 2.2 倍（3.3s → 7.2s） |
| MySQL 5000万写入 | 膨胀耗时约**16分钟**锁表溢出（Spark 仅需约**48.4秒**） |

***最终MySQL以4.2分钟写入2500万数据以作比较，spark数据量比MySQL多一半的条件下，查询速度比MySQL快三倍。***

---
# 踩坑记录
Hive容器Windows下不稳定 → 放弃 Hive，使用Spark内嵌Metastore

Spark SQL 不支持中文字段名 → 全部改为英文

JDBC 驱动容器重启丢失 → 挂载到宿主机jars目录

数据未持久化 → Volume 挂载到Spark warehouse路径

INSERT OVERWRITE 读写冲突 → 中间表+改名方案

分区列冲突 → PARTITIONED BY 独立定义，INSERT放最后

DECIMAL(10,2) 溢出 → 改为DECIMAL(18,2)
 
 
