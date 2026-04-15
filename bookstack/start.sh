#!/bin/bash
set -e

# Auto-generate APP_KEY on first run and persist it to .env
if grep -q "^APP_KEY=$" .env 2>/dev/null; then
    echo "Generating APP_KEY..."
    APP_KEY="base64:$(openssl rand -base64 32)"
    sed -i "s|^APP_KEY=$|APP_KEY=${APP_KEY}|" .env
    echo "APP_KEY saved to .env"
fi

docker compose pull
docker compose up -d
