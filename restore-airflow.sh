#!/bin/bash
# restore-airflow.sh
# Usage: ./restore-airflow.sh <backup_dir> <postgres_container> [<rabbitmq_container>]

set -euo pipefail

BACKUP_DIR="${1:?Backup directory required}"
POSTGRES_CONTAINER="${2:-postgres}"
RABBITMQ_CONTAINER="${3:-rabbitmq}"

DAGS_DIR="/opt/airflow/dags"
CONFIG_DIR="/opt/airflow"

echo "=== Restoring Airflow from $BACKUP_DIR ==="

# 1. Restore PostgreSQL base backup
echo "[Postgres] Restoring base backup..."
docker exec -i "$POSTGRES_CONTAINER" bash -c "rm -rf /var/lib/postgresql/data/*"
docker cp "$BACKUP_DIR/base/base_backup.tar" "$POSTGRES_CONTAINER":/tmp/base_backup.tar
docker exec -i "$POSTGRES_CONTAINER" bash -c "tar -xzf /tmp/base_backup.tar -C /var/lib/postgresql/data && rm -f /tmp/base_backup.tar"
echo "[Postgres] Base restored."

# 2. Restore WAL (optional, if available)
if [ -f "$BACKUP_DIR/wal/wal_archive_*.tar.gz" ]; then
    echo "[Postgres] Restoring WAL archive..."
    docker cp "$BACKUP_DIR/wal/wal_archive_*.tar.gz" "$POSTGRES_CONTAINER":/tmp/wal_archive.tar.gz
    docker exec -i "$POSTGRES_CONTAINER" bash -c "tar -xzf /tmp/wal_archive.tar.gz -C /var/lib/postgresql/wal_archive && rm -f /tmp/wal_archive.tar.gz"
    echo "[Postgres] WAL restored."
fi

# 3. Restore DAGs
echo "[DAGs] Restoring DAGs..."
tar -xzf "$BACKUP_DIR/dags.tar.gz" -C "$(dirname "$DAGS_DIR")"

# 4. Restore configs/plugins
echo "[Config] Restoring config/plugins..."
tar -xzf "$BACKUP_DIR/config.tar.gz" -C "$CONFIG_DIR"

# 5. Restore RabbitMQ definitions (optional)
if [ -f "$BACKUP_DIR/rabbitmq_definitions.json" ] && docker ps -q -f name="$RABBITMQ_CONTAINER" > /dev/null; then
    echo "[RabbitMQ] Restoring definitions..."
    docker cp "$BACKUP_DIR/rabbitmq_definitions.json" "$RABBITMQ_CONTAINER":/tmp/rabbitmq_def.json
    docker exec "$RABBITMQ_CONTAINER" rabbitmqctl import_definitions /tmp/rabbitmq_def.json
    docker exec "$RABBITMQ_CONTAINER" rm -f /tmp/rabbitmq_def.json
fi

echo "=== Restore Completed ==="