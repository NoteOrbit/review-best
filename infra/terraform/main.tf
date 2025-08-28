terraform {
  required_providers {
    databricks = {
      source  = "databricks/databricks"
      version = "~> 1.30.0"
    }
  }
}

provider "databricks" {
  host      = var.databricks_host
  token     = var.databricks_token
  auth_type = "pat"
}

locals {
domains = {
    users = {
      ingest_notebook_path    = "/Shared/review-best/notebooks/users/ingest.ipynb"
      transform_notebook_path = "/Shared/review-best/notebooks/users/transform.ipynb"
      load_notebook_path      = "/Shared/review-best/notebooks/users/load.ipynb"
    },
    products = {
      ingest_notebook_path    = "/Shared/review-best/notebooks/products/ingest.ipynb"
      transform_notebook_path = "/Shared/review-best/notebooks/products/transform.ipynb"
      load_notebook_path      = "/Shared/review-best/notebooks/products/load.ipynb"
    },
    orders = {
      ingest_notebook_path    = "/Shared/review-best/notebooks/orders/ingest.ipynb"
      transform_notebook_path = "/Shared/review-best/notebooks/orders/transform.ipynb"
      load_notebook_path      = "/Shared/review-best/notebooks/orders/load.ipynb"
    }
  }

  notebook_map = {
    for notebook in flatten([
      for domain_key, domain_value in local.domains : [
        
        { key = "${domain_key}_ingest",    source = "${path.module}/../../src/notebooks/${domain_key}/ingest.ipynb",    target = domain_value.ingest_notebook_path },
        { key = "${domain_key}_transform", source = "${path.module}/../../src/notebooks/${domain_key}/transform.ipynb", target = domain_value.transform_notebook_path },
        { key = "${domain_key}_load",      source = "${path.module}/../../src/notebooks/${domain_key}/load.ipynb",      target = domain_value.load_notebook_path }
      ]
    ]) : notebook.key => {
      source = notebook.source
      path   = notebook.target
    }
  }
}

resource "databricks_notebook" "all" {
  for_each = local.notebook_map
  source = each.value.source
  path   = each.value.path
}

resource "databricks_job" "pipeline" {
  for_each = local.domains

  name = "${each.key}_pipeline"
  
  task {
    task_key = "ingest"
    notebook_task {
      
      notebook_path = databricks_notebook.all["${each.key}_ingest"].path
    }
    
  }

  task {
    task_key = "transform"
    notebook_task {
      notebook_path = databricks_notebook.all["${each.key}_transform"].path
    }
    depends_on {
      task_key = "ingest"
    }
    
  }

  task {
    task_key = "load"
    notebook_task {
      notebook_path = databricks_notebook.all["${each.key}_load"].path
    }
    depends_on {
      task_key = "transform"
    }
  }
}