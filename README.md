# Manufacturing Tools Stack

A collection of self-hosted, open-source services for manufacturing operations, deployed locally via Docker Compose. Each service runs as an independent, fully isolated Docker Compose project.

## Services

| Service | Port | Purpose |
| ------- | ---- | ------- |
| [n8n](https://n8n.io) | [5678](http://localhost:5678) | Workflow automation — integrates all services |
| [BookStack](https://www.bookstackapp.com) | [6875](http://localhost:6875) | Documentation and knowledge base |
| [ERPNext](https://erpnext.com) | [8082](http://localhost:8082) | Manufacturing ERP (inventory, BOM, production orders) |
| [OpenProject](https://www.openproject.org) | [8090](http://localhost:8090) | Project management and work tracking |
| [FreeScout](https://freescout.net) | [8095](http://localhost:8095) | Help desk and shared inbox |

## Prerequisites

- [Docker Engine 24+](https://docs.docker.com/engine/install/)
- [Docker Compose v2.20+](https://docs.docker.com/compose/install/)
- `openssl` — for automatic secret generation on first start

## Quick Start

```bash
# Start all services
./start-all.sh

# Stop all services
./stop-all.sh
```

Individual service control:

```bash
cd bookstack && ./start.sh
cd bookstack && ./stop.sh

cd erpnext && ./start.sh
cd erpnext && ./stop.sh

cd n8n && ./start.sh
cd n8n && ./stop.sh

cd openproject && ./start.sh
cd openproject && ./stop.sh

cd freescout && ./start.sh
cd freescout && ./stop.sh
```

## Configuration

Each service has a `.env` file containing default values. **Review and update passwords before first run.**

| Service | Config file | Key variables |
| ------- | ----------- | ------------- |
| BookStack | `bookstack/.env` | `DB_PASSWORD`, `MYSQL_ROOT_PASSWORD` |
| ERPNext | `erpnext/.env` | `DB_PASSWORD`, `ADMIN_PASSWORD` |
| n8n | `n8n/.env` | `POSTGRES_PASSWORD`, `POSTGRES_NON_ROOT_PASSWORD` |
| OpenProject | `openproject/.env` | `POSTGRES_PASSWORD`, `SECRET_KEY_BASE` |
| FreeScout | `freescout/.env` | `DB_PASSWORD`, `ADMIN_EMAIL`, `ADMIN_PASS` |

`.env` files are git-ignored and will not be committed. Each file is created with working defaults so the stack runs out of the box.

## First Run Notes

### BookStack

- `APP_KEY` is auto-generated and saved to `bookstack/.env` on first start
- Default login: `admin@admin.com` / `password` — change immediately

### ERPNext

- Site is created automatically on first start (~2–3 minutes)
- Default login: `Administrator` / value of `ADMIN_PASSWORD` in `erpnext/.env`

### n8n

- `N8N_ENCRYPTION_KEY` and `RUNNERS_AUTH_TOKEN` are auto-generated and saved to `n8n/.env` on first start
- Create your owner account on first visit to `http://localhost:5678`
- **Keep `n8n/.env` backed up** — losing `N8N_ENCRYPTION_KEY` means losing access to all stored credentials

### OpenProject

- `SECRET_KEY_BASE` and `COLLABORATIVE_SERVER_SECRET` are auto-generated and saved to `openproject/.env` on first start
- The `seeder` service runs database migrations on first start (~2–3 minutes) before the UI becomes available
- Default login: `admin` / `admin` — change immediately

### FreeScout

- Database schema and admin account are created automatically on first start (~2–5 minutes)
- Set `ADMIN_EMAIL` and `ADMIN_PASS` in `freescout/.env` before first run — these cannot be changed via `.env` after the database is initialised
- Default login: values of `ADMIN_EMAIL` / `ADMIN_PASS` in `freescout/.env`

## Service Integration

n8n connects to ERPNext via its REST API:

- Base URL: `http://localhost:8082/api/`
- Auth: token-based — generate an API key in ERPNext under **Settings → My Account → API Access**
- Format: `Authorization: Token <api_key>:<api_secret>`

## Data Persistence

All service data is stored in Docker named volumes scoped to each project. Stopping services preserves all data.

To remove a service's data volumes (destructive — cannot be undone):

```bash
cd <service> && ./stop.sh --volumes
```

To remove all data across all services:

```bash
./stop-all.sh --volumes
```

## Architecture Notes

Each service is a separate Docker Compose project with its own network, volumes, and container namespace. They share only the host network interface (via distinct ports) and have no cross-service Docker networking by default.

| Service | Docker project | Database |
| ------- | ------------- | -------- |
| BookStack | `bookstack` | MariaDB 11 |
| ERPNext | `frappe_mfg` | MariaDB 11 |
| n8n | `n8n` | PostgreSQL 17 |
| OpenProject | `openproject` | PostgreSQL 17 |
| FreeScout | `freescout` | MariaDB 11 |
