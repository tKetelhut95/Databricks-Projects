-- Databricks notebook source
-- MAGIC %md
-- MAGIC ### View: Eastern Hemisphere

-- COMMAND ----------

CREATE OR REFRESH LIVE TABLE eastern_hemisphere
COMMENT "Asia, Middle East, and Africa data"
TBLPROPERTIES ("quality" = "view")
AS
SELECT region, nation, market_segment, total_price, customer_account_balance
FROM LIVE.orders_by_customers_gold
WHERE region = 'ASIA' OR region = 'MIDDLE EAST' OR region = 'AFRICA'

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ### View: Western Hemisphere

-- COMMAND ----------

CREATE OR REFRESH LIVE TABLE western_hemisphere
COMMENT "America and Europe data"
TBLPROPERTIES ("quality" = "view")
AS
SELECT region, nation, market_segment, total_price, customer_account_balance
FROM LIVE.orders_by_customers_gold
WHERE region = 'AMERICA' OR region = 'EUROPE'
