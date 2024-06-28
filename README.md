# Databricks-Orders-Pipeline

## Business Requirements: 
  * The Leadership team needs a Dashboard that shows order amounts and customer account balances broken down by region, nation, and market segment...preferably into hemisphere views for East and West
  * The orders should only contain data on or after 1995-01-01
  * The data needs to be updated automatically as new orders and customer data are transported into the s3 buckets

## Architecture:
![Databricks-Orders-Pipeline](https://github.com/tKetelhut95/Databricks-Orders-Pipeline/assets/16889892/40b0bb2b-3c86-4acd-b097-32568a584fb3)


## Notebooks: 📔 

* `dim_region_nation`: Region and Nation Streaming tables (bronze) pull data. region_nation Live table (silver) join them together
* `fact_customers`: Customers Streaming table (bronze) ingests data. Customers Live table (silver) forms by cleaning data and joining with the region_nation Live table (silver)
* `fact_orders`: Orders Streaming tables import data (bronze) and clean data (silver). orders_by_customers Live table (gold) joins orders (silver) with customers (silver) and groups/rounds data
* `hemisphere_views`: Eastern & Western Hemisphere Live tables select data from orders_by_customers (gold) and filter based on region

## Directed Acyclic Graphs (DAGs):

`Orders-DLT-Pipeline: Initial Run`

![image](https://github.com/tKetelhut95/Databricks-Orders-Pipeline/assets/16889892/609ebd23-912c-4a52-a599-46c709b25c59)
   * s3 bucket contains 1 folder for each dataset (region, nation, customer, and orders)
   * Pipeline run is successful. Rows in green are successfully transitioned to tables and rows in grey are filtered out due to constraints

`Orders-DLT-Pipeline: Job Triggered Run`

![image](https://github.com/tKetelhut95/Databricks-Orders-Pipeline/assets/16889892/65bed1d4-76cc-44f9-87dd-b4b41ee37225)

![image](https://github.com/tKetelhut95/Databricks-Orders-Pipeline/assets/16889892/8dcfad10-a0d6-4191-a182-1b26abfc1244)

   * s3 bucket has 1 new customers .csv file and 1 new orders .csv file added to their respective folders
   * Orders Pipeline Job: File Arrival Trigger identifies the above files have arrived and automatically runs a pipeline refresh
   * Customer and Orders Streaming tables pull in only new records and add them to Live tables if they pass constraints

## Power BI Dashboard:
   * Import Databricks Eastern and Western Hemisphere Live tables and leverage Power Query and DAX SWITCH equations to perform data transformations
   * Create a dashboard for Western and Eastern views with a color-coded map for total order amount ranks for each nation and matrix table displaying orders data at a more granular level
   
   `Western Hemisphere`:

![image](https://github.com/tKetelhut95/Databricks-Orders-Pipeline/assets/16889892/9c679051-9931-4fae-be21-a4c25304f1e8)


   `Eastern Hemisphere`:
   
![image](https://github.com/tKetelhut95/Databricks-Orders-Pipeline/assets/16889892/9746424f-8ead-42ba-ab9c-c470132ca5b4)


## Setup & Resources:

Databricks Setup:
   * Databricks via Amazon Web Services 
   * Databricks Runtime 14.3 LTS
   * Language(s) - SQL & Markdown

Resources:
   * Datasets - Databricks `Samples` Catalog > `tpch` Database
   * Storage - Amazon Web Services s3 buckets
   * Data Visualization - Microsoft Power BI
   
   

