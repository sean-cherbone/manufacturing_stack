# Manufacturing Tools Stack

A collection of self-hosted, open-source services for manufacturing operations, deployed locally via Docker Compose. Each service runs as an independent, fully isolated Docker Compose project.

## Services

| Service | Port | Purpose |
| ------- | ---- | ------- |
| [n8n](https://n8n.io) | [5678](http://localhost:5678) | Workflow automation — integrates all services |
| [BookStack](https://www.bookstackapp.com) | [6875](http://localhost:6875) | Documentation and knowledge base |
| [FreeScout](https://freescout.net) | [8095](http://localhost:8095) | Help desk and shared inbox |
| [Invoice Ninja](https://invoiceninja.com) | [8092](http://localhost:8092) | Accounting and invoicing |
| [InvenTree](https://inventree.org) | [8096](http://localhost:8096) | Inventory and parts management |
| [Plane](https://plane.so) | [8100](http://localhost:8100) | Project management and work tracking |

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

cd n8n && ./start.sh
cd n8n && ./stop.sh

cd freescout && ./start.sh
cd freescout && ./stop.sh

cd invoiceninja && ./start.sh
cd invoiceninja && ./stop.sh

cd inventree && ./start.sh
cd inventree && ./stop.sh

cd plane && ./start.sh
cd plane && ./stop.sh
```

## Configuration

Each service has a `.env` file containing default values. **Review and update passwords before first run.**

| Service | Config file | Key variables |
| ------- | ----------- | ------------- |
| BookStack | `bookstack/.env` | `DB_PASSWORD`, `MYSQL_ROOT_PASSWORD` |
| n8n | `n8n/.env` | `POSTGRES_PASSWORD`, `POSTGRES_NON_ROOT_PASSWORD` |
| FreeScout | `freescout/.env` | `DB_PASSWORD`, `ADMIN_EMAIL`, `ADMIN_PASS` |
| Invoice Ninja | `invoiceninja/.env` | `DB_PASSWORD`, `DB_ROOT_PASSWORD`, `IN_USER_EMAIL`, `IN_PASSWORD` |
| InvenTree | `inventree/.env` | `INVENTREE_DB_PASSWORD`, `INVENTREE_ADMIN_PASSWORD` |
| Plane | `plane/.env` | `POSTGRES_PASSWORD`, `SECRET_KEY`, `RABBITMQ_PASSWORD` |

`.env` files are git-ignored and will not be committed. Each file is created with working defaults so the stack runs out of the box.

## First Run Notes

### BookStack

- `APP_KEY` is auto-generated and saved to `bookstack/.env` on first start
- Default login: `admin@admin.com` / `password` — change immediately

### n8n

- `N8N_ENCRYPTION_KEY` and `RUNNERS_AUTH_TOKEN` are auto-generated and saved to `n8n/.env` on first start
- Create your owner account on first visit to `http://localhost:5678`
- **Keep `n8n/.env` backed up** — losing `N8N_ENCRYPTION_KEY` means losing access to all stored credentials

### FreeScout

- Database schema and admin account are created automatically on first start (~2–5 minutes)
- Set `ADMIN_EMAIL` and `ADMIN_PASS` in `freescout/.env` before first run — these cannot be changed via `.env` after the database is initialised
- Default login: values of `ADMIN_EMAIL` / `ADMIN_PASS` in `freescout/.env`

### Invoice Ninja

- `APP_KEY`, `DB_PASSWORD`, `DB_ROOT_PASSWORD`, and `IN_PASSWORD` are auto-generated and saved to `invoiceninja/.env` on first start
- Set `IN_USER_EMAIL` in `invoiceninja/.env` before first run to set the admin email
- **Do not change `APP_KEY` after first run** — it encrypts stored credentials and tokens
- Default login: value of `IN_USER_EMAIL` / `IN_PASSWORD` in `invoiceninja/.env`

### InvenTree

- `INVENTREE_DB_PASSWORD` and `INVENTREE_ADMIN_PASSWORD` are auto-generated and saved to `inventree/.env` on first start
- `secret_key.txt` is auto-generated inside the data volume on first start — **back it up and never delete it**, as it encrypts stored credentials
- Database migrations run automatically on startup (`INVENTREE_AUTO_UPDATE=True`)
- Default login: `admin` / value of `INVENTREE_ADMIN_PASSWORD` in `inventree/.env`

### Plane

- `SECRET_KEY`, `LIVE_SERVER_SECRET_KEY`, `POSTGRES_PASSWORD`, `RABBITMQ_PASSWORD`, `AWS_ACCESS_KEY_ID`, and `AWS_SECRET_ACCESS_KEY` are auto-generated and saved to `plane/.env` on first start
- Create your workspace and owner account on first visit to `http://localhost:8100`
- **Do not change `SECRET_KEY` after first run** — it invalidates all active sessions

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
| n8n | `n8n` | PostgreSQL 17 |
| FreeScout | `freescout` | MariaDB 11 |
| Invoice Ninja | `invoiceninja` | MySQL 8 |
| InvenTree | `inventree` | PostgreSQL 17 |
| Plane | `plane` | PostgreSQL 15 |
