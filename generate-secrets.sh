#!/bin/bash
# generate-secrets.sh — creates k8s/01-secrets.yaml from .env
set -e

if [ ! -f .env ]; then
  echo "Error: .env not found."
  echo "Run: cp .env.example .env"
  echo "Then fill in the values."
  exit 1
fi

set -a
source .env
set +a

cat > k8s/01-secrets.yaml << EOF
# Auto-generated from .env — DO NOT COMMIT
apiVersion: v1
kind: Secret
metadata:
  name: cd-db-credentials
  namespace: checkdev
type: Opaque
stringData:
  POSTGRES_USER: "${POSTGRES_USER}"
  POSTGRES_PASSWORD: "${POSTGRES_PASSWORD}"
  SPRING_DATASOURCE_USERNAME: "${POSTGRES_USER}"
  SPRING_DATASOURCE_PASSWORD: "${POSTGRES_PASSWORD}"
---
apiVersion: v1
kind: Secret
metadata:
  name: cd-app-credentials
  namespace: checkdev
type: Opaque
stringData:
  SECURITY_OAUTH2_CLIENT_CLIENT_ID: "${OAUTH2_CLIENT_ID}"
  SECURITY_OAUTH2_CLIENT_CLIENT_SECRET: "${OAUTH2_CLIENT_SECRET}"
  HH_TOKEN: "${HH_TOKEN}"
  ACCESS_KEY: "${ACCESS_KEY}"
EOF

echo "Generated k8s/01-secrets.yaml from .env"