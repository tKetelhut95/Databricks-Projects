# Databricks-Orders-Pipeline

## Business Requirements: 
  * The leadership team needs a Dashboard that shows order amounts and customer balances broken down by region, nation, and market segment...preferably into hemisphere views for East and West
  * The orders should only contain data during or after 1995-01-01
  * The data needs to be updated automatically as new orders and customer data are transported into the s3 buckets

## Architecture:
![Databricks-Orders-Pipeline](https://github.com/tKetelhut95/Databricks-Orders-Pipeline/assets/16889892/40b0bb2b-3c86-4acd-b097-32568a584fb3)


## Notebooks: 📔 

* `dim_region_nation`: Region and Nation Streaming tables (bronze) are created and joined together as a Live table (silver)
* `fact_customers`: Customers Streaming table (bronze) ingests data. Customers Live table (silver) forms by cleaning data and joining with the dim_region_nation Live table (silver)
* `fact_orders`: Orders Streaming tables import data (bronze) and clean data (silver). orders_by_customers table (gold) joins orders (silver) with customers (silver) and groups/rounds data
* `hemisphere_views`: Eastern & Western Hemisphere tables are created by selecting data from orders_by_customers (gold) and filtering based on region

