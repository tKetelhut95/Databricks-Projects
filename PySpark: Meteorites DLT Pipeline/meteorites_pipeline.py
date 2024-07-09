# Databricks notebook source
# MAGIC %md
# MAGIC ### Meteorites: Bronze Table

# COMMAND ----------

import dlt
import pyspark.sql.functions as F

@dlt.table(
  comment = "Pull Meteorite data and metadata from s3 Bucket",
  table_properties = {"quality": "bronze"}
)
def meteorites_bronze():
    return (
      spark.readStream
      .format("cloudFiles")
      .option("cloudFiles.format", "json")
      .option("multiline", True)
      .option("cloudFiles.inferColumnTypes", True)
      .load("s3://elt-bucket-practice/meteorite_findings/meteorite_raw_data/")
      .selectExpr("*", "_metadata as source_metadata")
      .withColumn("processing_time", F.current_timestamp())
  )

# COMMAND ----------

# MAGIC %md
# MAGIC ### Meteorites: Silver Table

# COMMAND ----------

@dlt.table(
  comment = "Clean and validate Meteorite data",
  table_properties = {"quality": "silver"}
)
@dlt.expect_or_drop("valid_date", "year IS NOT NULL")
@dlt.expect_or_drop("valid_size", "mass >= 100")
def meteorites_silver():
    return (
        dlt.read_stream("meteorites_bronze")
        .select(
            "processing_time",
            F.col("year").cast("date").alias("year"),
            "id",
            "name",
            "recclass",
            F.col("mass").cast("double"),
            "geolocation"
        )
    )


# COMMAND ----------

# MAGIC %md
# MAGIC ### Meteorites: Gold Table

# COMMAND ----------

@dlt.table(
  comment = "Display each record of Meteorite data with the required fields",
  table_properties = {"quality": "gold"}
)
def meteorites_gold():
    return (
        dlt.read("meteorites_silver")
        .select(
            "processing_time",
            F.year(F.col("year")).alias("year"),
            "id",
            "name",
            "recclass",
            "mass",
            F.col("geolocation.coordinates")[0].alias("longitude"),
            F.col("geolocation.coordinates")[1].alias("latitude")
        )
    )
