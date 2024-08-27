# AWS-Glue: DC Transactions 

## Business Requirements: 
  * You have identified a new data source that releases transactions executed by the DC government on a monthly basis
  * The Leadership Team wants you to build a Data Pipeline that pulls this data starting May 2024 and all future data after that
  * Every time a new file is uploaded to the S3 Bucket, the Data Pipeline needs to run automatically and send output data to a Postgres database where Business Intelligence Engineer and Analyst teams can work with the data
  * Maximize cost savings on compute and storage by only pulling in the absolutely necessary fields and grouping the data to minimize the row count

## Architecture:

![image](https://github.com/tKetelhut95/DEV/blob/main/Images/AWS-Glue-DC%20Transactions.png?raw=true)


## Data Source: Open Data DC 

* Dataset originates from Open Data DC: https://opendata.dc.gov/datasets/DCGIS::purchase-card-transactions/about
* Leverage Excel to create a sample dataset for intial testing and then use the original raw export for May 2024 data for a full Data Pipeline Job Run

## Data Storage: AWS S3 Bucket
* Amazon Web Services S3 Bucket to store the datasets
* Datasets are in CSV format and stored in the aws-glue-dc-transactions folder
  
![image](https://github.com/tKetelhut95/DEV/blob/main/Images/AWS-Glue%20S3%20Bucket%20.png?raw=true)

## AWS-Glue: AWS RDS Postgres and Connection

`Stand up a Postgres database using AWS RDS`:
   * AWS RDS > Create database > Select PostgreSQL
   * Configuration - Engine: PostgreSQL 16.3 > Templates: "Free Tier" > Database Name: "database-1" > Self-Managed: Username and Password > Instance configuration: db.t3.micro > Storage: General Purpose SSD (gp2) and allocated storage of 20 > Connectivity: Select VPC, DB subnet group, Public Access to "Yes", and choose VPC security group > Database authentication: "Password authentication" > Click "Create database"

`Create Postgres Database and Table Schema`:
* Database - Open Postgres > Right-click Server and select create --> database 
* Table - Open Psotgres > Click Query Tool icon > `Table_dc_transactions.sql` leverages SQL to create a table with 7 columns  

`Create Connection`: 
   * AWS Glue > Connections > Create Connection

`Step 1: Choose data source`:
   * Select PostgreSQL

`Step 2: Configure connection`:
   * Database Instance (database-1) and Database Name (dctransactions)
   * Username and Password
   * Network options (optional)

`Step 3: Set properties`:
   * Name (Postgresql connection)
   * Description & Tags (optional)

`Step 4: Review and Create`:
   * Review Connection details and click "Create Connection"

`Test Connection`:
   * AWS Glue > Connections > Select "Postgresql connection" > Actions dropdown menu and click "Test connection"

![image](https://github.com/tKetelhut95/DEV/blob/main/Images/AWS-Glue%20Postgres%20Test%20Connection.png?raw=true)

## AWS-Glue: Create and Run Crawler

`Create a Database`: 
   * AWS Glue > Databases > Add Database: "dc_database"
   * The Crawler will use this database as an output target for the newly uploaded data

`Create a Crawler`: 
   * AWS Glue > Crawlers > Create Crawler

`Step 1: Set crawler properties`:
   * Name - postgres_dctransactions
   * Description & Tags - optional

`Step 2: Choose data sources and classifiers`:
   * Is your data already mapped to Glue tables? - Not yet
   * Add a data source - Data source: "JDBC" > Connection: "Postgresql Connection" > Include path: "dc_database/public/dc_transactions" > Additional metadata: optional
   * Custom classifiers - optional

`Step 3: Configure security settings`:
   * IAM role - AWSGlueServiceRole (contains admin permissions)
   * Security configuration - optional

`Step 4: Set output and scheduling`:
   * Target database - "dc_database" (from the `Create a Database` step earlier)
   * Table name - optional
   * Crawler schedule - On demand

`Step 5: Review and create`:
   * Review Crawler details and click "Create crawler"

`Run Crawler`:
   * Successful output below

![image](https://github.com/tKetelhut95/DEV/blob/main/Images/AWS-Glue%20Crawler%20Run.png?raw=true)

## AWS-Glue: PostgreSQL Connection and Crawler Troubleshooting

`Problem`: 
   * Originally, I set up the PostgreSQL connection with the default settings AWS provides, but these did not work and resulted in a failed "Test Connection"
   * To make matters worse the CloudWatch log files did not provide helpful information to solve the issue...only the issue names of "Failed Status" and "Network Failure" with little to no description
   * In order to solve this issues additiional troubleshooting was required

`Troubleshooting`: Identified these variables as potential solutions 
   * Credentials - updated to using Username and Password from the default Secrets Manager
   * Publicly Accessible - changed the status of the RDS to "Publicly Accessible"
   * Password Encryption - created a parameter group, switched password encryption from "scram-sha-256" to "md5", and attached parameter group to the RDS
   * User Profile - after the "password encryption" step, created a new User Profile and granted it admin privileges to then run the "Test Connection" in AWS Glue
      * Credit: bansalakhil - https://repost.aws/questions/QUpkrhcfkYQtS2adbjpQ7quQ/cannot-connect-from-glue-to-rds-postgres#AN2SxYJ-3pT425XOS0GhUmQg
   * Custom Driver - downloaded the newest custom driver .jar file from postgres website (https://jdbc.postgresql.org/download/), uploaded it to the S3 bucket, and pasted ARN into the Connection configuration
      * Credit: Hongbo Miao - https://stackoverflow.com/questions/76901396/failed-to-connect-amazon-rds-in-aws-glue-data-catalogs-connection
   * Network - established a NAT Gateway, configured a route table to have an associated subnet that connects to the NAT Gateway, and ensured the RDS and Connection details in AWS Glue are connected to the NAT Gateway
      * Credit: blink - https://www.youtube.com/watch?v=AOQ73bD2Hls
   
`Solution`: The following combination of the variable changes resulted in a successful PostgreSQL "Test Connection" and Crawler Run
   * Credentials
   * Publicly Accessible
   * Password Encryption

## AWS-Glue: S3 Bucket Lambda Function

`Create the Lambda Function`:
   * Create a new Lambda Function from Scratch using Python 3.9
   * Establish a new IAM role with the correct permissions to use S3, Lambda Functions, and Glue

`Add a Trigger`:
   * Develop a trigger that runs when a file is uploaded to the aws-glue-dc-transaction S3 Bucket 
   * Event types of "PUT" only becuase we only want it to trigger when files are uploaded to the bucket
   * Pre-fix of dc-transactions-raw-data to specify the sub-folder in the bucket where the data will be uploaded

![image](https://github.com/tKetelhut95/DEV/blob/main/Images/AWS-Glue%20Lambda%20Function.png?raw=true)

`Lambda Function Code`:
   * `lambda_function.py` - creates a python function that runs the DC-Transactions-Pipeline job in Glue and prints either the status of that job if successful or the error message if unsuccessful
   * Create a test event to ensure that the code runs successfully before deploying (image below)

![image](https://github.com/tKetelhut95/DEV/blob/main/Images/AWS-Glue%20Lambda%20Function%20Log.png?raw=true)
   
## AWS-Glue: DC-Transactions Pipeline

`AWS-Glue Pipeline Nodes`:
   * Data Source - S3 Bucket: Connect to S3 Bucket using S3 URL
   * Transform - Change Schema: Update Data Types and drop column 'dcs_last_mod_dttm'
   * Transform - Regex Extractor: Extract Date from transaction_date field using '(\d\d\d\d\D\d\d\D\d\d)'
   * Transform - Data Prep Recipe: Replace Text "/" with "-" in transaction_date and change transaction_date format to Date ('yyyy-mm-dd')
   * Transform - Change Schema: Update Data Type of transaction_date to Date format
   * Data Target - PostgreSQL: Leverage Postgres Connection to connect and AWS Data Catalog to select Database and Table schemas

![image](https://github.com/tKetelhut95/DEV/blob/main/Images/AWS-Glue%20Pipeline.png?raw=true)

`DC-Transactions Pipeline: Sample Dataset Run`

![image](https://github.com/tKetelhut95/DEV/blob/main/Images/AWS-Glue%20Pipeline%20Initial%20Run.png?raw=true)
   * Test Pipeline run is successful and the data is located in the Postgres data table "dc_transactions". Start up time: 14 seconds & Duration: 1 minute 1 second 

`DC-Transactions Pipeline: Full Dataset Run`

![image](https://github.com/tKetelhut95/DEV/blob/main/Images/AWS-Glue%20Pipeline%20Full%20Run.png?raw=true)
   * Valid_size constraint removes 98 rows that aren't greater than or equal to a mass of 100
   * Valid_date rule deletes 1 row that doesn't contain a date value

## Postgres: DC Transactions Table & Materialized Views 

`dc_transactions table`
   * AWS-Glue: DC-Transactions-Pipeline successfully sends data to Postgres via image below

![image](https://github.com/tKetelhut95/DEV/blob/main/Images/Postgres%20dc_transactions%20table.png?raw=true)

`Materialized Views`:
   * Develop Materialzied Views using data from the dc_transactions table so that users can get the data tables they are looking for by quering them
   * Include Refresh Concurrently statements to ensure that even if one user is refreshing the Materialized View, others will still be able to query the data wihtout being blocked 
   * Need a Unique Index for each Materialized View to ensure Refresh Concurrently statements can function

`MaterializedView_agency_transactions_rank.sql`:
   * Leverages SQL to rank the different agencies based on total transaction amounts

![image](https://github.com/tKetelhut95/DEV/blob/main/Images/Postgres%20agency_transactions_rank.png?raw=true)

`MaterializedView_agency_transactions_monthly_rank.sql`:
   * Use SQL to rank agencies based on total transaction amounts for each month
   * Months are separated by year as well...e.g. agencies will have new rankings in May 2024 that will not be affected by rankings in May 2023
   * Dataset only contains May data, but runs correctly for newly added monthly data

![image](https://github.com/tKetelhut95/DEV/blob/main/Images/Postgres%20agency_transactions_monthly_rank.png?raw=true)

## Setup & Other Resources:

AWS RDS Postgres Setup:
   * Language(s) - SQL
   * Credentials - Username & Password
   * Password Encryption - md5
   * Publicly Accessible - True

AWS Lambda Function Setup:
   * Language(s) - Python 3.9
   * Connections - S3 & AWS Glue
   * IAM Role - permissions to access S3, Lambda Functions, and Glue

AWS Glue Setup:
   * Connections - PostgreSQL
   * Crawler - capture schema data from Postgres dc_database 
   * IAM Role - permissions to access S3 Bucket and AWS Glue

Other Resources:
   * Cloud Logs - Amazon Web Services CloudWatch Logs
   * Storage - Amazon Web Services S3 Bucket
   * Dataset - (https://opendata.dc.gov/datasets/DCGIS::purchase-card-transactions/about)...identified data source thanks to data.world > @dcopendata > Purchase Card Transactions https://data.world/dcopendata/92842dceac234b9ca1a8266fcfd57de7-50
   