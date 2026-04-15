#!/bin/bash
# Stops all services in the Frappe/ERPNext manufacturing stack.
# Data volumes are preserved. Use --volumes to also remove them (destructive).
set -e

PROJECT=frappe_mfg

docker compose -p "$PROJECT" down "$@"
