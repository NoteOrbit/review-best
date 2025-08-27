
import os
import csv
from faker import Faker

# Initialize Faker
fake = Faker()

# Define the data domains
domains = {
    "users": {
        "fields": ["user_id", "name", "email", "address", "created_at"],
        "generator": lambda: [fake.uuid4(), fake.name(), fake.email(), fake.address(), fake.iso8601()]
    },
    "products": {
        "fields": ["product_id", "name", "description", "price", "created_at"],
        "generator": lambda: [fake.uuid4(), fake.word(), fake.sentence(), fake.random_number(digits=2), fake.iso8601()]
    },
    "orders": {
        "fields": ["order_id", "user_id", "product_id", "quantity", "order_date"],
        "generator": lambda: [fake.uuid4(), fake.uuid4(), fake.uuid4(), fake.random_int(min=1, max=10), fake.iso8601()]
    }
}

# Create the data directory if it doesn't exist
data_dir = "data"
if not os.path.exists(data_dir):
    os.makedirs(data_dir)

# Generate and save the data for each domain
for domain, config in domains.items():
    file_path = os.path.join(data_dir, f"{domain}.csv")
    with open(file_path, "w", newline="") as csvfile:
        writer = csv.writer(csvfile)
        # Write the header
        writer.writerow(config["fields"])
        # Write the data
        for _ in range(100):  # Generate 100 records for each domain
            writer.writerow(config["generator"]())

print("Data generation complete.")

