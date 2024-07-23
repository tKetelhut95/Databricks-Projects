-- Databricks notebook source
-- MAGIC %md
-- MAGIC ### Fact Table: Orders - Bronze

-- COMMAND ----------

CREATE OR REFRESH STREAMING LIVE TABLE fact_orders_bronze
AS SELECT current_timestamp() processing_time, *
FROM cloud_files("s3://elt-bucket-practice/orders/orders-raw-data/fact-orders/", "csv", map("cloudFiles.inferColumnTypes", "true"))

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ### Fact Table: Orders - Silver

-- COMMAND ----------

CREATE OR REFRESH STREAMING LIVE TABLE fact_orders_silver (
CONSTRAINT valid_order_key EXPECT (order_key IS NOT NULL) ON VIOLATION DROP ROW, 
CONSTRAINT valid_order_date EXPECT (order_date >= '1995-01-01') ON VIOLATION DROP ROW)
COMMENT "Cleaned Orders data with valid_order_key and Orders during or after 1995-01-01"
TBLPROPERTIES ("quality" = "silver")
AS SELECT o_orderkey AS order_key, o_custkey, o_totalprice AS total_price, o_orderdate AS order_date
FROM STREAM(LIVE.fact_orders_bronze)

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ### Join Tables: Orders & Customers

-- COMMAND ----------

CREATE OR REFRESH LIVE TABLE orders_by_customers_gold
COMMENT "Join Orders and Customers tables, Group data, and Round Numeric fields"
TBLPROPERTIES ("quality" = "gold")
AS SELECT region, nation, market_segment,  ROUND(SUM(total_price),0) AS total_price, ROUND(SUM(customer_account_balance),0) AS customer_account_balance
FROM LIVE.fact_orders_silver o
LEFT JOIN LIVE.fact_customers_silver c
  ON o.o_custkey = c.customer_key
GROUP BY region, nation, market_segment
