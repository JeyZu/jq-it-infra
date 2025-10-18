# Odoo on GCP (Terraform)

This stack provisions a minimal, production-ready GCP infrastructure skeleton for Odoo:

- Cloud SQL for PostgreSQL (user/password generated and stored in Secret Manager)
- Managed Instance Group (currently returns HTTP 200 on port 8069 as a stub)
- Global HTTPS Load Balancer with managed certificate
- GCS bucket for persistent storage or artifacts
- Required APIs enabled via project services

Note: The MIG startup script uses a simple health stub. Replace it with a real Odoo deployment (Docker container or compose) when ready.

## Prerequisites

- Terraform >= 1.5
- gcloud SDK installed and authenticated (Application Default Credentials):
  - `gcloud auth application-default login`
- A GCS bucket for Terraform state (recommended)

## Quick Start

1) Initialize backend (recommended but optional)

```
terraform init \
  -backend-config="bucket=<STATE_BUCKET>" \
  -backend-config="prefix=terraform/state"
```

2) Configure inputs

Create `terraform.tfvars` or use an env file in `envs/`.

Examples:

```
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values
```

3) Plan and apply

```
terraform init   # if not yet initialized
terraform plan   # review
terraform apply  # confirm to create resources
```

## Inputs

See `variables.tf` for all variables. Minimal required:

- `project_id` (string)
- `domain_name` (string, e.g., odoo.example.com)

## Outputs

- `lb_external_ip`   – IPv4 of the Global HTTPS LB
- `lb_external_ipv6` – IPv6 of the Global HTTPS LB

## Next Steps

- Replace the MIG startup stub with an Odoo deployment (Docker run or compose) and remove the stub container.
- Optionally restrict Cloud SQL access further and connect via Cloud SQL Auth Proxy.

