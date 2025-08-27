
terraform {
  required_providers {
    databricks = {
      source  = "databricks/databricks"
      version = "~> 1.30.0"
    }
  }
}

provider "databricks" {
  host  = var.databricks_host
  token = var.databricks_token
}



locals {
  domains = {
    users = {
      ingest_notebook = "${path.root}/../../src/notebooks/users/ingest.py",
      transform_notebook = "${path.root}/../../src/notebooks/users/transform.py",
      load_notebook = "${path.root}/../../src/notebooks/users/load.py"
    },
    products = {
      ingest_notebook = "${path.root}/../../src/notebooks/products/ingest.py",
      transform_notebook = "${path.root}/../../src/notebooks/products/transform.py",
      load_notebook = "${path.root}/../../src/notebooks/products/load.py"
    },
    orders = {
      ingest_notebook = "${path.root}/../../src/notebooks/orders/ingest.py",
      transform_notebook = "${path.root}/../../src/notebooks/orders/transform.py",
      load_notebook = "${path.root}/../../src/notebooks/orders/load.py"
    }
  }
}

resource "databricks_job" "ingest" {
  for_each = local.domains

  name = "ingest_${each.key}"

  job_cluster {
    job_cluster_key   = "ingest_cluster"
    new_cluster {
      spark_version = "13.3.x-scala2.12"
      node_type_id = "i3.xlarge"
      autoscale {
        min_workers = 1
        max_workers = 2
      }
    }
  }

  notebook_task {
    notebook_path = each.value.ingest_notebook
  }
}

resource "databricks_job" "transform" {
  for_each = local.domains

  name = "transform_${each.key}"

  job_cluster {
    job_cluster_key   = "transform_cluster"
    new_cluster {
      spark_version = "13.3.x-scala2.12"
      node_type_id = "i3.xlarge"
      autoscale {
        min_workers = 1
        max_workers = 2
      }
    }
  }

  notebook_task {
    notebook_path = each.value.transform_notebook
  }

  depends_on = [databricks_job.ingest[each.key]]
}

resource "databricks_job" "load" {
  for_each = local.domains

  name = "load_${each.key}"

  job_cluster {
    job_cluster_key   = "load_cluster"
    new_cluster {
      spark_version = "13.3.x-scala2.12"
      node_type_id = "i3.xlarge"
      autoscale {
        min_workers = 1
        max_workers = 2
      }
    }
  }

  notebook_task {
    notebook_path = each.value.load_notebook
  }

  depends_on = [databricks_job.transform[each.key]]
}
