#!/usr/bin/env bash
set -e

# Read Home Assistant addon options
OPTIONS_FILE="/data/options.json"
CONFIG_PATH="/data/config.yml"

# Extract options using jq (Home Assistant provides this)
PORT=$(jq -r '.port // 80' "$OPTIONS_FILE")
USERNAME=$(jq -r '.username // "admin"' "$OPTIONS_FILE")
PASSWORD=$(jq -r '.password // "admin"' "$OPTIONS_FILE")
ALLOW_REGISTRATION=$(jq -r '.allow_registration // false' "$OPTIONS_FILE")

echo "[INFO] Generating Gotify config at $CONFIG_PATH..."

cat > "$CONFIG_PATH" <<EOF
server:
  listenaddr: "0.0.0.0"
  port: ${PORT}
  ssl:
    enabled: false

database:
  dialect: "sqlite3"
  connection: "data/gotify.db"

passstrength: 10

defaultuser:
  name: "${USERNAME}"
  pass: "${PASSWORD}"

registration: ${ALLOW_REGISTRATION}
EOF

# Create data directory if it doesn't exist
mkdir -p /data/data

echo "[INFO] Starting Gotify..."
exec gotify --config "$CONFIG_PATH"