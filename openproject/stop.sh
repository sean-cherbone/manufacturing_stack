#!/bin/bash
# Stops all OpenProject services. Data volumes are preserved.
# Pass --volumes to also remove pgdata and opdata (destructive, loses all data).
set -e

PROJECT=openproject

docker compose -p "$PROJECT" down "$@"
