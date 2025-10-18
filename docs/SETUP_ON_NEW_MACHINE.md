# Setup on a New Machine (Windows PowerShell)

Follow these steps to clone the repo, authenticate with GCP, reuse the same remote Terraform state, and run the local Docker stack.

## Prerequisites

- Git, Terraform (>= 1.5), Docker Desktop
- Google Cloud SDK (gcloud) installed and logged in
- IAM permissions on your GCP project to read/write the state bucket and manage Compute/SQL/Storage/Secret Manager

## 1) Clone and configure gcloud

```
# Clone
git clone <your-repo-url>
cd odoo

# Project and auth
$PROJECT = "<your-project-id>"
gcloud config set project $PROJECT
gcloud auth application-default login
```

## 2) Terraform: use the same remote backend

Ask the maintainer (or check your notes) for the state bucket and prefix used on first launch.

```
# Go to Terraform directory
Set-Location infra/gcp/terraform

# Use the SAME backend bucket + prefix as the original setup
$BUCKET = "<state-bucket-name>"      # e.g. your-project-id-tfstate-prod
$PREFIX = "terraform/state/prod"

terraform init -backend-config="bucket=$BUCKET" -backend-config="prefix=$PREFIX"
```

## 3) Provide inputs (match what was used originally)

Option A — terraform.tfvars

```
Copy-Item terraform.tfvars.example terraform.tfvars
notepad terraform.tfvars   # set: project_id, region, domain_name, app_name, etc.
```

Option B — environment variables

```
$env:TF_VAR_project_id  = $PROJECT
$env:TF_VAR_region      = "europe-west1"
$env:TF_VAR_domain_name = "odoo.example.com"
# Optional overrides (if different from defaults)
# $env:TF_VAR_app_name         = "odoo"
# $env:TF_VAR_db_instance_name = "odoo-db"
```

## 4) Sync state with GCP

```
terraform plan
# Apply only if you intend to change infra from this machine
terraform apply
```

## 5) Local Docker stack (independent of GCP)

```
# From repo root
Set-Location ..\..   # back to repo root (adjust if needed)
Copy-Item .env.example .env
make up
# Access Odoo at: http://localhost:8069
```

## 6) Useful outputs and secrets

```
# From infra/gcp/terraform
terraform output lb_external_ip
terraform output lb_external_ipv6

# Cloud SQL connection details
# (replace names if you customized variables)
gcloud sql instances describe odoo-db --project $PROJECT

# DB password from Secret Manager (name: <app_name>-db-password)
$APP_NAME = "odoo"
gcloud secrets versions access latest --secret "$APP_NAME-db-password" --project $PROJECT
```

## Troubleshooting

- 403 SERVICE_DISABLED during first runs
  - Enable APIs with the project services module and wait for propagation:
    - `terraform apply -target=module.project_services`
    - Wait 60–120s, then `terraform apply`
- Managed certificate stuck in PROVISIONING
  - Ensure DNS A record points to `lb_external_ip`
  - Wait 10–60 minutes; check status:
    - `gcloud compute ssl-certificates describe odoo-managed-cert --global --project $PROJECT --format "yaml(managed.status,managed.domainStatus)"`
  - Temporarily set `https_redirect = false` in `infra/gcp/terraform/network.tf` to allow HTTP while waiting, then re-apply
- Backend health
  - The MIG startup script exposes a stub on port 8069; health should be HEALTHY
  - Firewall rule `allow-lb-healthcheck-8069` targets tag `odoo-web`
- State bucket permissions
  - Ensure your account has access to the state bucket (e.g., roles/storage.objectAdmin or appropriate object-level roles)

```text
Quick checklist
- gcloud project set + ADC login
- terraform init with the SAME backend bucket/prefix
- terraform plan (apply only when intending to change infra)
- local: copy .env.example → .env, then make up
```
