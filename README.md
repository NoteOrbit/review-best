# Terraform Databricks Pipeline

This project demonstrates how to build and deploy a serverless data pipeline on Databricks using Terraform and GitHub Actions.

The pipeline consists of three stages: ingest, transform, and load. It processes data from three different domains: users, products, and orders. The data is generated using the Faker library in Python.

## Project Structure

```
.github/
  workflows/
    main.yml
data/
  users.csv
  products.csv
  orders.csv
infra/
  terraform/
    main.tf
    variables.tf
src/
  notebooks/
    users/
      ingest.py
      transform.py
      load.py
    products/
      ingest.py
      transform.py
      load.py
    orders/
      ingest.py
      transform.py
      load.py
  scripts/
    generate_data.py
requirements.txt
README.md
```

## Prerequisites

*   A Databricks workspace
*   A Databricks personal access token
*   A GitHub account

## Setup

1.  **Clone the repository:**

    ```
    git clone https://github.com/<your-username>/review-best.git
    cd review-best
    ```

2.  **Install the required Python libraries:**

    ```
    pip install -r requirements.txt
    ```

3.  **Generate the sample data:**

    ```
    python src/scripts/generate_data.py
    ```

4.  **Upload the data to Databricks:**

    Upload the `data` directory to `/FileStore/data` in your Databricks workspace.



6.  **Configure GitHub Secrets:**

    In your GitHub repository, create the following secrets:

    *   `DATABRICKS_HOST`: Your Databricks workspace URL (e.g., `https://dbc-a1b2345c-d6e7.cloud.databricks.com`)
    *   `DATABRICKS_TOKEN`: Your Databricks personal access token

## Deployment

The pipeline is deployed automatically using GitHub Actions. When you push a change to the `main` branch, the workflow will be triggered.

## Usage

Once the pipeline is deployed, you can run the jobs in Databricks to process the data. The jobs are chained together, so you only need to run the `ingest` jobs. The `transform` and `load` jobs will be triggered automatically.