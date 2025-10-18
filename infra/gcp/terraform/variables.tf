variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP region for resources"
  type        = string
  default     = "europe-west1"
}

variable "app_name" {
  description = "Application name prefix"
  type        = string
  default     = "odoo"
}

variable "domain_name" {
  description = "Domain for HTTPS certificate (e.g., odoo.example.com)"
  type        = string
}

variable "mig_machine_type" {
  description = "Machine type for instance template"
  type        = string
  default     = "e2-micro"
}

variable "db_instance_name" {
  description = "Cloud SQL instance name"
  type        = string
  default     = "odoo-db"
}

variable "db_version" {
  description = "Cloud SQL Postgres version"
  type        = string
  default     = "POSTGRES_15"
}

variable "db_tier" {
  description = "Cloud SQL machine tier"
  type        = string
  default     = "db-f1-micro"
}

variable "db_name" {
  description = "Primary database name"
  type        = string
  default     = "odoo"
}

variable "db_user" {
  description = "Application DB username"
  type        = string
  default     = "odoo_user"
}

variable "bucket_name_prefix" {
  description = "Base name for GCS bucket"
  type        = string
  default     = "odoo-persistent-storage"
}

