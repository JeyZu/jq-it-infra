# Odoo Dev + Infra

This repository provides:

- Local Odoo stack via Docker Compose
- GCP Terraform stack under `infra/gcp/terraform`

## Local (Docker Compose)

1) Copy and edit environment

```
cp .env.example .env
```

2) Start

```
make up      # start services
make logs    # follow logs
make ps      # list services
make down    # stop
```

3) Access

- Odoo: http://localhost:${ODOO_HTTP_PORT:-8069}
- Optional pgAdmin: add `--profile pgadmin` to compose commands.

## Infrastructure (GCP Terraform)

See `infra/gcp/terraform/README.md` for step-by-step usage.

Highlights:

- Enables required APIs, provisions Cloud SQL, GCS, MIG, and HTTPS LB
- Secrets handled via Secret Manager
- Parameterized for easy reuse across projects

For setting up this project on another machine (same GCP state), follow `docs/SETUP_ON_NEW_MACHINE.md`.
