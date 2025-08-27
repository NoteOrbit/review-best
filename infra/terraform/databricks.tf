locals {
  # Define all your notebooks in one place
  notebooks = {
    ingest    = "ingest.py",
    transform = "transform.py",
    load      = "load.py"
  }
}

resource "databricks_notebook" "pipeline_notebooks" {
  for_each = local.notebooks

  source = "${path.module}/../notebooks/${each.value}"
  
  path     = "/Shared/notebooks/${each.value}"
}