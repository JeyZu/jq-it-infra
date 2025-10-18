module "odoo_lb_global_lb_backend" {
  source     = "github.com/terraform-google-modules/terraform-google-lb-http//modules/backend?ref=v13.2.0"
  name       = "${var.app_name}-lb-backend"
  project_id = var.project_id
  port_name  = "http"
  protocol   = "HTTP"
  groups = [{
    description = "Managed instance group"
    group       = module.odoo_app_mig.instance_group
  }]
  health_check = {
    request_path        = "/"
    port                = 8069
    check_interval_sec  = 10
    timeout_sec         = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }
  depends_on = [module.project_services]
}

resource "google_compute_managed_ssl_certificate" "odoo" {
  project = var.project_id
  name    = "${var.app_name}-managed-cert"
  managed {
    domains = [var.domain_name]
  }
  depends_on = [module.project_services]
}

module "odoo_lb_global_lb_frontend" {
  source           = "github.com/terraform-google-modules/terraform-google-lb-http//modules/frontend?ref=v13.2.0"
  name             = "${var.app_name}-lb-frontend"
  project_id       = var.project_id
  url_map_input    = module.odoo_lb_global_lb_backend.backend_service_info
  ssl              = true
  https_redirect   = true
  ssl_certificates = [google_compute_managed_ssl_certificate.odoo.id]
  depends_on       = [module.project_services, google_compute_managed_ssl_certificate.odoo, module.odoo_lb_global_lb_backend]
}

resource "google_compute_firewall" "allow_lb_healthcheck_8069" {
  project = var.project_id
  name    = "allow-lb-healthcheck-8069"
  network = "default"

  direction = "INGRESS"
  priority  = 1000

  source_ranges = [
    "35.191.0.0/16",
    "130.211.0.0/22"
  ]

  target_tags = ["${var.app_name}-web"]

  allow {
    protocol = "tcp"
    ports    = ["8069"]
  }
  depends_on = [module.project_services]
}
