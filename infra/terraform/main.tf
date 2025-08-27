terraform {
  required_providers {
    databricks = {
      source  = "databricks/databricks"
      version = "~> 1.30.0"
    }
  }
}

provider "databricks" {
  host = var.databricks_host
  // token = var.databricks_token # Using a Service Principal is recommended for CI/CD
}

locals {
  domains = {
    users = {
      ingest_notebook    = "/Shared/notebooks/users/ingest", // Use workspace paths
      transform_notebook = "/Shared/notebooks/users/transform",
      load_notebook      = "/Shared/notebooks/users/load"
    },
    products = {
      ingest_notebook    = "/Shared/notebooks/products/ingest",
      transform_notebook = "/Shared/notebooks/products/transform",
      load_notebook      = "/Shared/notebooks/products/load"
    },
    orders = {
      ingest_notebook    = "/Shared/notebooks/orders/ingest",
      transform_notebook = "/Shared/notebooks/orders/transform",
      load_notebook      = "/Shared/notebooks/orders/load"
    }
  }
}

# Create one multi-task job for each domain
resource "databricks_job" "pipeline" {
  for_each = local.domains

  name = "${each.key}_pipeline"

  # Define tasks for the job
  task {
    task_key = "ingest"
    job_cluster_key = "default_cluster" // Use the same cluster for all tasks
    notebook_task {
      notebook_path = each.value.ingest_notebook
    }
  }

  task {
    task_key = "transform"
    job_cluster_key = "default_cluster"
    notebook_task {
      notebook_path = each.value.transform_notebook
    }
    # This task depends on the 'ingest' task within the SAME job
    depends_on {
      task_key = "ingest"
    }
  }

  task {
    task_key = "load"
    job_cluster_key = "default_cluster"
    notebook_task {
      notebook_path = each.value.load_notebook
    }
    # This task depends on the 'transform' task within the SAME job
    depends_on {
      task_key = "transform"
    }
  }
  
}