provider "google" {
  project               = var.project_id
  user_project_override = true
}

provider "google-beta" {
  project               = var.project_id
  user_project_override = true
}

