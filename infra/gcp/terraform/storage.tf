resource "random_id" "bucket_suffix" {
  byte_length = 2
}

module "odoo_app_storage" {
  source     = "github.com/terraform-google-modules/terraform-google-cloud-storage//modules/simple_bucket?ref=v12.0.0"
  project_id = var.project_id
  location   = var.region
  name       = "${var.bucket_name_prefix}-${var.project_id}-${random_id.bucket_suffix.hex}"
  iam_members = [{
    member = module.odoo_app_instance_template.service_account_info.member
    role   = "roles/storage.objectAdmin"
  }]
  storage_class = "STANDARD"
  depends_on    = [module.project_services]
}

