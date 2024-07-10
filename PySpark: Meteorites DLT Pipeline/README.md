# Databricks-PySpark: Meteorites DLT Pipeline

## Business Requirements: 
  * The NASA Meteorites Environment Office needs a Data Pipeline that ingests and cleans both historical and ongoing data for all meteorites that have landed on Earth as well as a Dashboard that visualizes this data
  * Meteorite data should only contain records with a valid date and a mass greater than or equal to 100
  * The data needs to be updated automatically as new files are transported into an AWS S3 Bucket


## Architecture:

![Databricks-Meteorite-Pipeline](https://github.com/tKetelhut95/DEV/assets/16889892/627ac76e-2d8c-456b-a289-a169137fda16)


## Data Source: GitHub & Visual Studio Code

* Dataset originates from GitHub: [jdorfman/awesome-json-datasets](https://github.com/jdorfman/awesome-json-datasets)
* Leverage Microsoft Visual Studio Code to create a python script "Meteorites_dataset_split.py"
* `Meteorites_dataset_split.py`: Splits the dataset into 2 separate JSON files based on date (before_2000 & after_2000) to test an initial Databricks Pipeline run and a Job Trigger Run described below


## Data Storage: AWS S3 Bucket
* Amazon Web Services S3 Bucket to store the datasets
* Datasets are in JSON format and stored in the meteorite_raw_data folder
  
![image](https://github.com/tKetelhut95/DEV/assets/16889892/a06d7e74-ece4-4c59-ae8d-4c4a89aeadc4)


## Databricks: Notebooks 📔 

* `meteorites`: creates a pipeline with bronze, silver, and gold tables to pull, clean, and transform the meteorite data using PySpark
* Imports include the dlt module to use Python functions and pyspark.sql.functions to leverage SQL functions within PySpark code
* Bronze (Streaming table) - Autoloader loads the data from S3 Bucket via the "cloud.files" format and specifies additional options for how to deal with the data...file metadata is also pulled using the "_metadata as source_metadata" expression
* Silver (Streaming table) - Establishes constraints valid_data and valid_size that will drop rows that do not meet expectations and changes data types of the "year" and "mass" fields
* Gold (Live table) - Creates a Live table that modifies the "year" column to display a year format and extracts the longitude and latitude values from the "geolocation" object


## Databricks: DLT Pipeline DAGs & Job

`Meteorites DLT Pipeline: Initial Run`

![image](https://github.com/tKetelhut95/DEV/assets/16889892/ba7bdd57-116a-4276-937d-4f249fb02f72)
   * Pipeline run is successful. Bronze table pulls in 1,000 rows, Silver table drops 99 rows that don't pass the constraints, and Gold table materializes the remaining 901 rows

![image](https://github.com/tKetelhut95/DEV/assets/16889892/d87cccb6-b54a-45d3-ba9a-c2e83de9df7f)
   * Valid_size constraint removes 98 rows that aren't greater than or equal to a mass of 100
   * Valid_date rule deletes 1 row that doesn't contain a date value


`Meteorites DLT Pipeline: Job Triggered Run`

![image](https://github.com/tKetelhut95/DEV/assets/16889892/f5f9083e-c61e-4a9c-9ce2-800024676241)

![image](https://github.com/tKetelhut95/DEV/assets/16889892/2acb030b-30df-4897-a302-5558e6ccea19)
   * S3 bucket has 1 new meteorites .json file added to the meteorite_raw_data folder
   * Meteorites Pipeline Job: File Arrival Trigger identifies the above file has arrived and automatically runs a pipeline refresh
   * The Bronze Streaming table only pulls in the new records (70), the Silver Streaming table cleans (64) and drops (6) these new items, and the Gold Live table adds the valid rows (64) to the initial run rows (901) for a total (965)

## Power BI: Dashboard
   * Establish connection to Databricks and import the Meteorites Live table
   * Leverage Power Query to perform data transformations and DAX SWITCH equation to create the "Mass Rank" calculated column 
   * Visualize meteorite landings with an aerial view map with Mass Ranks based on meteorite mass and a table displaying descriptive meteorite data
   
   `Earth Meteorite Landings`:

![image](https://github.com/tKetelhut95/DEV/assets/16889892/360832cd-925d-45df-bc12-3708ec3dbf36)


## Setup & Resources:

Visual Studio Code Setup:
   * Language(s) - Python
   * Libraries - json

Databricks Setup:
   * Databricks via Amazon Web Services
   * Databricks Runtime 14.3 LTS
   * Language(s) - PySpark & Markdown

Resources:
   * Dataset - GitHub: `jdorfman` > `awesome-json-datasets` > `NASA section` > `Earth Meteorite Landings` (https://github.com/jdorfman/awesome-json-datasets)
   * Storage - Amazon Web Services S3 Bucket
   * Data Visualization - Microsoft Power BI
