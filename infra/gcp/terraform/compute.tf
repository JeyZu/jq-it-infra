module "odoo_app_instance_template" {
  source         = "github.com/terraform-google-modules/terraform-google-vm//modules/instance_template?ref=v13.5.0"
  project_id     = var.project_id
  region         = var.region
  name_prefix    = "${var.app_name}-vm-template"
  machine_type   = var.mig_machine_type
  disk_size_gb   = "20"
  network        = "default"
  startup_script = <<-EOT
    #!/bin/bash
    set -euo pipefail

    apt-get update -y
    apt-get install -y docker.io docker-compose
    systemctl enable docker
    systemctl start docker

    # Healthcheck stub on 8069 (200 OK)
    docker rm -f hc-stub || true
    docker run -d --name hc-stub \
      -p 8069:5678 \
      --restart=always \
      hashicorp/http-echo -text="healthy"

    # TODO: Replace with real Odoo deployment (container/compose) and remove stub.
  EOT
  metadata = {
    CLOUD_SQL_DATABASE_CONNECTION_NAME = module.odoo_app_database_postgresql.instance_connection_name
    CLOUD_SQL_DATABASE_HOST            = module.odoo_app_database_postgresql.instance_first_ip_address
    CLOUD_SQL_DATABASE_NAME            = module.odoo_app_database_postgresql.env_vars.CLOUD_SQL_DATABASE_NAME
  }
  tags = ["${var.app_name}-web", "http-server"]
  service_account_project_roles = ["roles/cloudsql.instanceUser", "roles/cloudsql.client"]
  access_config                 = [{ "network_tier" = "PREMIUM", "nat_ip" = null }]
  depends_on                    = [module.project_services]
}

module "odoo_app_mig" {
  source            = "github.com/terraform-google-modules/terraform-google-vm//modules/mig?ref=v13.6.1"
  project_id        = var.project_id
  region            = var.region
  mig_name          = "${var.app_name}-mig"
  target_size       = 1
  instance_template = module.odoo_app_instance_template.self_link
  named_ports = [{
    name = "http"
    port = 8069
  }]
  depends_on = [module.project_services]
}

