module "project_services" {
  source                      = "github.com/terraform-google-modules/terraform-google-project-factory//modules/project_services?ref=v17.1.0"
  project_id                  = var.project_id
  disable_services_on_destroy = false
  activate_apis = [
    "iam.googleapis.com",
    "compute.googleapis.com",
    "sqladmin.googleapis.com",
    "storage.googleapis.com",
    "secretmanager.googleapis.com",
    "servicenetworking.googleapis.com",
    "cloudresourcemanager.googleapis.com"
  ]
}

