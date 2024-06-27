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

## Directed Acyclic Graphs (DAGs):

Orders-DLT-Pipeline: Initial Run
![image](https://github.com/tKetelhut95/Databricks-Orders-Pipeline/assets/16889892/609ebd23-912c-4a52-a599-46c709b25c59)
   * s3 bucket contains 1 folder for each dataset (region, nation, customer, and orders)
   * Pipeline run is successful. Rows in green are successfully transitioned to tables and rows in grey are filtered out due to constraints

Orders-DLT-Pipeline: 2nd Run
![image](https://github.com/tKetelhut95/Databricks-Orders-Pipeline/assets/16889892/61d5b937-30fa-483d-915e-661c3ed2e37a)
   * s3 bucket has 1 new customers .csv file and 1 new orders .csv file added to their respective folders
   * Customer and Orders Streaming tables pull in new records and add them to Live tables if they pass constraints
