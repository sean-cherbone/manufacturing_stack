#!/bin/bash
# Starts the OpenProject stack.
# On first run, auto-generates SECRET_KEY_BASE and COLLABORATIVE_SERVER_SECRET,
# builds the Caddy proxy image, and lets the seeder initialise the database.
# On subsequent runs the seeder detects existing data and exits quickly.
set -e

PROJECT=openproject

# ── Auto-generate secrets on first run ────────────────────────────────────────
if grep -q "^SECRET_KEY_BASE=OVERWRITE_ME" .env 2>/dev/null; then
    echo "Generating SECRET_KEY_BASE..."
    SECRET=$(openssl rand -hex 64)
    sed -i "s|^SECRET_KEY_BASE=OVERWRITE_ME|SECRET_KEY_BASE=${SECRET}|" .env
    echo "SECRET_KEY_BASE saved to .env"
fi

if grep -q "^COLLABORATIVE_SERVER_SECRET=OVERWRITE_ME" .env 2>/dev/null; then
    echo "Generating COLLABORATIVE_SERVER_SECRET..."
    COLLAB_SECRET=$(openssl rand -base64 32 | tr -dc 'A-Za-z0-9' | head -c 32)
    sed -i "s|^COLLABORATIVE_SERVER_SECRET=OVERWRITE_ME|COLLABORATIVE_SERVER_SECRET=${COLLAB_SECRET}|" .env
    echo "COLLABORATIVE_SERVER_SECRET saved to .env"
fi

# ── Pull images and build local proxy ─────────────────────────────────────────
echo "Pulling images..."
docker compose -p "$PROJECT" pull --ignore-buildable

echo "Building proxy..."
docker compose -p "$PROJECT" build proxy

# ── Start ─────────────────────────────────────────────────────────────────────
echo "Starting services..."
docker compose -p "$PROJECT" up -d

echo ""
echo "OpenProject is starting. The seeder runs database migrations first;"
echo "the web UI will be ready in ~2-3 minutes."
echo ""
echo "UI:       http://localhost:${PORT:-8090}"
echo "Login:    admin / admin  (change immediately after first login)"
echo ""
echo "To watch startup: docker compose -p $PROJECT logs -f seeder web"
