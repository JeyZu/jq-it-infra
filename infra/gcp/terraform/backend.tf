terraform {
  backend "gcs" {
    # Recommended: pass values during init to avoid hardcoding
    # Example:
    #   terraform init \
    #     -backend-config="bucket=<STATE_BUCKET>" \
    #     -backend-config="prefix=terraform/state"
  }
}

