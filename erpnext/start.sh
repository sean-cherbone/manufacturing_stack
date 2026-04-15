#!/bin/bash
# Starts the ERPNext manufacturing stack.
# On first run the create-site service bootstraps the site automatically.
# On subsequent runs it detects the existing site and skips creation.
set -e

PROJECT=frappe_mfg

echo "Pulling latest images..."
docker compose -p "$PROJECT" pull

echo "Starting services..."
docker compose -p "$PROJECT" up -d

echo ""
echo "Stack is starting. Services will be ready in ~60 seconds."
echo "UI: http://localhost:${HTTP_PUBLISH_PORT:-8082}"
echo "Login: Administrator / (ADMIN_PASSWORD from .env)"
echo ""
echo "To watch startup progress: docker compose -p $PROJECT logs -f"
