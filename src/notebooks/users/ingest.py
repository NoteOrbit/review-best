
# Databricks notebook source

# Define the path to the input CSV file
input_path = "/FileStore/data/users.csv"

# Define the path to the output Delta table
output_path = "/delta/users_raw"

# Read the CSV file
df = spark.read.format("csv").option("header", "true").load(input_path)

# Write the data to a Delta table
df.write.format("delta").mode("overwrite").save(output_path)

print(f"Successfully ingested users data to {output_path}")
