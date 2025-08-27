# Databricks notebook source

from pyspark.sql.functions import col, to_timestamp

# Define the paths to the input Delta tables
orders_input_path = "/delta/orders_raw"
users_input_path = "/delta/users_transformed"
products_input_path = "/delta/products_transformed"

# Define the path to the output Delta table
output_path = "/delta/orders_transformed"

# Read the raw data from the Delta tables
df_orders = spark.read.format("delta").load(orders_input_path)
df_users = spark.read.format("delta").load(users_input_path)
df_products = spark.read.format("delta").load(products_input_path)

# Perform transformations
df_transformed = df_orders \
    .withColumn("quantity", col("quantity").cast("int")) \
    .withColumn("order_date", to_timestamp(col("order_date"))) \
    .join(df_users, "user_id", "left") \
    .join(df_products, "product_id", "left") \
    .select("order_id", "user_id", "product_id", "quantity", "order_date", "name", "brand", "price")

# Write the transformed data to a new Delta table
df_transformed.write.format("delta").mode("overwrite").save(output_path)

print(f"Successfully transformed orders data and saved to {output_path}")
