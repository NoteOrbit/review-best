
resource "databricks_notebook" "ingest_notebook" {
  path      = "/Shared/notebooks/ingest.py"
  language  = "PYTHON"
  content_base64 = filebase64("${path.module}/../notebooks/ingest.py")
}

resource "databricks_notebook" "transform_notebook" {
  path      = "/Shared/notebooks/transform.py"
  language  = "PYTHON"
  content_base64 = filebase64("${path.module}/../notebooks/transform.py")
}

resource "databricks_notebook" "load_notebook" {
  path      = "/Shared/notebooks/load.py"
  language  = "PYTHON"
  content_base64 = filebase64("${path.module}/../notebooks/load.py")
}
