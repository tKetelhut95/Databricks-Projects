-- Databricks notebook source
-- MAGIC %md
-- MAGIC ### Fact Table: Customers - Bronze

-- COMMAND ----------

CREATE OR REFRESH STREAMING LIVE TABLE fact_customers_bronze
AS SELECT current_timestamp() processing_time, *
FROM cloud_files("s3://elt-bucket-practice/orders/orders-raw-data/fact-customer/", "csv", map("cloudFiles.inferColumnTypes", "true"))

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ### Fact Table: Customers - Silver

-- COMMAND ----------

CREATE OR REFRESH LIVE TABLE fact_customers_silver (
CONSTRAINT valid_customer_key EXPECT (customer_key IS NOT NULL) ON VIOLATION DROP ROW
)
COMMENT "Clean Customers data with valid_customer_key and Join Region-Nation data"
TBLPROPERTIES ("quality" = "silver")
AS SELECT c_custkey AS customer_key, region, nation, c_mktsegment AS market_segment, c_acctbal AS customer_account_balance
FROM LIVE.fact_customers_bronze c
LEFT JOIN LIVE.dim_region_nation rn
  ON c.c_nationkey = rn.n_nationkey
