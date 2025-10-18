module "odoo_app_instance_template" {
  source         = "github.com/terraform-google-modules/terraform-google-vm//modules/instance_template?ref=v13.5.0"
  project_id     = var.project_id
  region         = var.region
  name_prefix    = "${var.app_name}-vm-template"
  machine_type   = var.mig_machine_type
  disk_size_gb   = "20"
  network        = "default"
  # Use Container-Optimized OS for immediate Docker availability
  source_image_family  = "cos-stable"
  source_image_project = "cos-cloud"
  startup_script = <<-EOT
    #!/bin/bash
    set -euo pipefail

    # Start a simple HTTP responder on port 8069 for LB health checks.
    # Prefer Docker (works on Container-Optimized OS), otherwise fall back to Python or nc.

    started=false
    if command -v docker >/dev/null 2>&1; then
      # Wait up to 60s for Docker to be ready on COS
      for i in $(seq 1 30); do
        if docker info >/dev/null 2>&1; then
          docker rm -f hc-stub >/dev/null 2>&1 || true
          if docker run -d --name hc-stub \
               -p 8069:5678 \
               --restart=always \
               hashicorp/http-echo -text="healthy"; then
            started=true
            break
          fi
        fi
        sleep 2
      done
    fi

    if [ "$started" != true ] && command -v python3 >/dev/null 2>&1; then
      pkill -f "python3 -m http.server 8069" >/dev/null 2>&1 || true
      nohup python3 -m http.server 8069 --bind 0.0.0.0 \
        > /var/log/hc-stub.log 2>&1 &
      started=true
    fi

    if [ "$started" != true ] && command -v nc >/dev/null 2>&1; then
      # Very simple nc loop; compatible with many nc variants
      nohup bash -c 'while true; do { echo -ne "HTTP/1.1 200 OK\r\nContent-Length: 7\r\n\r\nhealthy"; } | nc -l -p 8069 -q 1; done' \
        > /var/log/hc-stub.log 2>&1 &
      started=true
    fi

    if [ "$started" != true ]; then
      # Last resort: busybox httpd if available
      if command -v busybox >/dev/null 2>&1; then
        nohup busybox httpd -f -p 0.0.0.0:8069 \
          > /var/log/hc-stub.log 2>&1 &
      fi
    fi

    # TODO: Replace with real Odoo deployment and remove this stub.
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
  update_policy = [{
    type                  = "PROACTIVE"     # roll automatically
    minimal_action        = "REPLACE"       # recreate to pick up template
    max_surge_fixed       = 3                # regional MIG: >= number of zones (europe-west1 has 3)
    max_unavailable_fixed = 0                # keep capacity during rollout
  }]
  named_ports = [{
    name = "http"
    port = 8069
  }]
  depends_on = [module.project_services]
}
