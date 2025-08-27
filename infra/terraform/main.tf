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
  # โครงสร้างสำหรับสร้าง Job ยังคงเดิม
  domains = {
    users = {
      ingest_notebook_path    = "/Shared/review-best/notebooks/users/ingest"
      transform_notebook_path = "/Shared/review-best/notebooks/users/transform"
      load_notebook_path      = "/Shared/review-best/notebooks/users/load"
    },
    products = {
      ingest_notebook_path    = "/Shared/review-best/notebooks/products/ingest"
      transform_notebook_path = "/Shared/review-best/notebooks/products/transform"
      load_notebook_path      = "/Shared/review-best/notebooks/products/load"
    },
    orders = {
      ingest_notebook_path    = "/Shared/review-best/notebooks/orders/ingest"
      transform_notebook_path = "/Shared/review-best/notebooks/orders/transform"
      load_notebook_path      = "/Shared/review-best/notebooks/orders/load"
    }
  }

  # --> CHANGE 1: สร้าง Map ของ Notebook ทั้งหมดที่จะ upload
  # เราจะสร้าง map ที่มี key ที่ไม่ซ้ำกัน (เช่น "users_ingest")
  # และ value ที่มีทั้ง source file path และ target workspace path
  notebook_map = {
    for notebook in flatten([
      for domain_key, domain_value in local.domains : [
        # Go up two levels (../../) to find the src folder
        { key = "${domain_key}_ingest",    source = "${path.module}/../../src/notebooks/${domain_key}/ingest.py",    target = domain_value.ingest_notebook_path },
        { key = "${domain_key}_transform", source = "${path.module}/../../src/notebooks/${domain_key}/transform.py", target = domain_value.transform_notebook_path },
        { key = "${domain_key}_load",      source = "${path.module}/../../src/notebooks/${domain_key}/load.py",      target = domain_value.load_notebook_path }
      ]
    ]) : notebook.key => {
      source = notebook.source
      path   = notebook.target
    }
  }
}

# --> CHANGE 2: Upload Notebooks ทั้งหมดโดยใช้ for_each
# Resource นี้จะสร้าง notebook object ใน databricks workspace ตาม map ที่เราสร้างไว้ข้างบน
resource "databricks_notebook" "all" {
  for_each = local.notebook_map
  source = each.value.source
  path   = each.value.path
}

# สร้างหนึ่ง multi-task job สำหรับแต่ละ domain
resource "databricks_job" "pipeline" {
  for_each = local.domains

  name = "${each.key}_pipeline"
  
  # --> CHANGE 3: เชื่อมโยง Job กับ Notebook ที่ Upload ใหม่
  # เราจะอ้างอิง .path attribute จาก resource "databricks_notebook.all"
  # แทนการใช้ค่า hardcode จาก local.domains โดยตรง
  task {
    task_key = "ingest"
    notebook_task {
      # อ้างอิงไปยัง notebook ที่ถูกสร้างโดย Terraform จาก key ที่ตรงกัน
      notebook_path = databricks_notebook.all["${each.key}_ingest"].path
    }
    # ใส่การตั้งค่า cluster หรือ job cluster ตามต้องการ
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