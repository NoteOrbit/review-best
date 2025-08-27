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

  # The 'source' attribute is simpler than 'content_base64'
  # This path assumes your 'notebooks' folder is one level above your terraform files.
  source = "${path.module}/../notebooks/${each.value}"
  
  # The path where the notebook will be created in the Databricks workspace
  path     = "/Shared/notebooks/${each.value}"
}