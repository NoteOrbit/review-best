
# Databricks notebook source

# Define the path to the input Delta table
input_path = "/delta/users_transformed"

# Define the name of the final table
table_name = "users"

# Read the transformed data from the Delta table
df = spark.read.format("delta").load(input_path)

# Create a table in the Hive metastore
df.write.format("delta").mode("overwrite").saveAsTable(table_name)

print(f"Successfully loaded users data into table {table_name}")
