project_id = "example-project"
domain     = "foobar.example.com"
name       = "foobar-mastodon"

# Kubernetes
gke_authenticator_security_group = "gke-security-groups@example.com"

# Storage
bucket_location = "europe-west1"

# SQL
cloudsql_zone = "europe-west1-b"

# These are the secrets that are used by the application.
smtp_gcp_existing_secret_name = "sf-cd-mastodon-smtp-secret"
