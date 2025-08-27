
# Databricks notebook source

from pyspark.sql.functions import col, to_timestamp, datediff, current_date, lit
from pyspark.sql.types import StringType

# Define the path to the input Delta table
input_path = "/delta/users_raw"

# Define the path to the output Delta table
output_path = "/delta/users_transformed"

# Read the raw data from the Delta table
df = spark.read.format("delta").load(input_path)

# Perform transformations
df_transformed = df.withColumn("created_at_ts", to_timestamp(col("created_at")))
    .withColumn("birth_date", (current_date() - (col("user_id").cast(StringType())[0:4].cast("int") % 50 + 18) * 365).cast("date"))
    .withColumn("age", (datediff(current_date(), col("birth_date")) / 365).cast("int"))
    .select("user_id", "name", "email", "age", "created_at_ts")

# Write the transformed data to a new Delta table
df_transformed.write.format("delta").mode("overwrite").save(output_path)

print(f"Successfully transformed users data and saved to {output_path}")
