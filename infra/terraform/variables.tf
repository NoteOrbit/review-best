

variable "databricks_host" {
  description = "The Databricks host URL."
  type        = string
}

variable "databricks_token" {
  description = "The Databricks access token."
  type        = string
  sensitive   = true
}