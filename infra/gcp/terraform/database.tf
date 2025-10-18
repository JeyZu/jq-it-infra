module "odoo_app_database_postgresql" {
  source                      = "github.com/terraform-google-modules/terraform-google-sql-db//modules/postgresql?ref=v26.2.2"
  project_id                  = var.project_id
  region                      = var.region
  name                        = var.db_instance_name
  edition                     = "ENTERPRISE"
  database_version            = var.db_version
  availability_type           = "REGIONAL"
  deletion_protection         = false
  database_flags              = [{ "name" = "cloudsql.iam_authentication", "value" = "on" }]
  data_cache_enabled          = true

  # Primary app user via module's built-in mechanism
  user_name             = var.db_user

  additional_databases        = [{ "collation" = "en_US.UTF8", "name" = var.db_name, "charset" = "UTF8" }]
  tier                        = var.db_tier
  deletion_protection_enabled = false
  disk_autoresize             = true
  backup_configuration = {
    enabled                        = true
    point_in_time_recovery_enabled = true
  }
  iam_users = [{
    email = module.odoo_app_instance_template.service_account_info.email
    id    = module.odoo_app_instance_template.service_account_info.id
    type  = "CLOUD_IAM_SERVICE_ACCOUNT"
  }]
  depends_on = [module.project_services]
}

module "odoo_app_database_secret" {
  source      = "github.com/GoogleCloudPlatform/terraform-google-secret-manager//modules/simple-secret?ref=v0.9.0"
  project_id  = var.project_id
  name        = "${var.app_name}-db-password"
  secret_data = module.odoo_app_database_postgresql.generated_user_password
  depends_on  = [module.project_services]
}
