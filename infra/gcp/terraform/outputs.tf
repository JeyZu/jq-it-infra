output "lb_external_ip" {
  description = "External IPv4 of the global forwarding rule"
  value       = module.odoo_lb_global_lb_frontend.external_ip
}

output "lb_external_ipv6" {
  description = "External IPv6 of the global forwarding rule"
  value       = module.odoo_lb_global_lb_frontend.external_ipv6_address
}

