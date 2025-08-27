# Databricks notebook source

from pyspark.sql.functions import col, when

# Define the path to the input Delta table
input_path = "/delta/products_raw"

# Define the path to the output Delta table
output_path = "/delta/products_transformed"

# Read the raw data from the Delta table
df = spark.read.format("delta").load(input_path)

# Perform transformations
df_transformed = df.withColumn("price", col("price").cast("double")) \
    .withColumn("brand", when(col("name").contains("Awesome"), "AwesomeBrand").otherwise("GenericBrand")) \
    .select("product_id", "name", "brand", "price", "created_at")

# Write the transformed data to a new Delta table
df_transformed.write.format("delta").mode("overwrite").save(output_path)

print(f"Successfully transformed products data and saved to {output_path}")
