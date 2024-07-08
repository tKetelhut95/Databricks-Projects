-- Databricks notebook source
-- MAGIC %md
-- MAGIC ### Dimension Region Table - Bronze

-- COMMAND ----------

CREATE OR REFRESH STREAMING LIVE TABLE dim_region_bronze
AS SELECT current_timestamp() processing_time, *
FROM cloud_files("s3://elt-bucket-practice/orders/orders-raw-data/dim-region/", "csv", map("cloudFiles.inferColumnTypes", "true"))

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ### Dimension Nation Table - Bronze

-- COMMAND ----------

CREATE OR REFRESH STREAMING LIVE TABLE dim_nation_bronze
AS SELECT current_timestamp() processing_time, *
FROM cloud_files("s3://elt-bucket-practice/orders/orders-raw-data/dim-nation/", "csv", map("cloudFiles.inferColumnTypes", "true"))

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ### Join Tables: Region & Nation

-- COMMAND ----------

CREATE OR REFRESH LIVE TABLE dim_region_nation
COMMENT "Join Region and Nation tables"
TBLPROPERTIES ("quality" = "silver")
AS SELECT n_nationkey, r_name AS region, n_name AS nation
FROM LIVE.dim_nation_bronze n
LEFT JOIN LIVE.dim_region_bronze r
  ON n.n_regionkey = r.r_regionkey
