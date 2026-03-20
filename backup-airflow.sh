#!/bin/bash
# backup-airflow.sh
# Usage: ./backup-airflow.sh <backup_root> <postgres_container> [<rabbitmq_container>]

set -euo pipefail

BACKUP_ROOT="${1:-/backups}"       # Destination dir
POSTGRES_CONTAINER="${2:-postgres}"
RABBITMQ_CONTAINER="${3:-rabbitmq}"
DATE=$(date +%F_%H-%M)
BACKUP_DIR="$BACKUP_ROOT/$DATE"

DAGS_DIR="/opt/airflow/dags"
CONFIG_DIR="/opt/airflow"

BASE_BACKUP_DIR="$BACKUP_DIR/base"
WAL_ARCHIVE_DIR="$BACKUP_DIR/wal"

mkdir -p "$BASE_BACKUP_DIR" "$WAL_ARCHIVE_DIR"

echo "=== Airflow Backup: $DATE ==="

# 1. PostgreSQL base backup
echo "[Postgres] Creating base backup..."
docker exec -t "$POSTGRES_CONTAINER" pg_basebackup -U airflow -D /tmp/base_backup -F t -X fetch -z
docker cp "$POSTGRES_CONTAINER":/tmp/base_backup "$BASE_BACKUP_DIR"
docker exec "$POSTGRES_CONTAINER" rm -rf /tmp/base_backup
echo "[Postgres] Base backup saved at $BASE_BACKUP_DIR"

# 2. WAL archive (if mounted)
echo "[Postgres] Archiving WAL..."
docker exec -t "$POSTGRES_CONTAINER" bash -c "tar -czf /tmp/wal_archive.tar.gz -C /var/lib/postgresql/wal_archive ." || echo "No WAL files"
docker cp "$POSTGRES_CONTAINER":/tmp/wal_archive.tar.gz "$WAL_ARCHIVE_DIR/wal_archive_$DATE.tar.gz" || echo "Skipped WAL"
docker exec "$POSTGRES_CONTAINER" rm -f /tmp/wal_archive.tar.gz
echo "[Postgres] WAL archive saved at $WAL_ARCHIVE_DIR"

# 3. DAGs
echo "[DAGs] Archiving DAGs..."
tar -czf "$BACKUP_DIR/dags.tar.gz" -C "$(dirname "$DAGS_DIR")" "$(basename "$DAGS_DIR")"

# 4. Config & plugins
echo "[Config] Archiving configs/plugins..."
tar -czf "$BACKUP_DIR/config.tar.gz" -C "$CONFIG_DIR" airflow.cfg plugins .env requirements.txt || echo "Some files missing"

# 5. RabbitMQ definitions (optional)
if docker ps -q -f name="$RABBITMQ_CONTAINER" > /dev/null; then
    echo "[RabbitMQ] Exporting definitions..."
    docker exec "$RABBITMQ_CONTAINER" rabbitmqctl export_definitions /tmp/rabbitmq_def.json
    docker cp "$RABBITMQ_CONTAINER":/tmp/rabbitmq_def.json "$BACKUP_DIR/rabbitmq_definitions.json"
    docker exec "$RABBITMQ_CONTAINER" rm -f /tmp/rabbitmq_def.json
else
    echo "[RabbitMQ] Not found, skipping"
fi

echo "=== Backup Completed ==="
echo "Backup directory: $BACKUP_DIR"