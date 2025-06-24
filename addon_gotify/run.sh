#!/usr/bin/env bash
set -e

# Read Home Assistant addon options
OPTIONS_FILE="/data/options.json"
CONFIG_PATH="/data/config.yml"

echo "[INFO] Starting Gotify Server Add-on..."

# Check if options file exists and is readable
if [[ ! -f "$OPTIONS_FILE" ]]; then
    echo "[ERROR] Options file not found: $OPTIONS_FILE"
    exit 1
fi

echo "[INFO] Reading addon configuration..."

# Extract options using jq with proper error handling
PORT=$(jq -r '.port // 80' "$OPTIONS_FILE" 2>/dev/null || echo "80")
USERNAME=$(jq -r '.username // "admin"' "$OPTIONS_FILE" 2>/dev/null || echo "admin")
PASSWORD=$(jq -r '.password // "admin"' "$OPTIONS_FILE" 2>/dev/null || echo "admin")
ALLOW_REGISTRATION=$(jq -r '.allow_registration // false' "$OPTIONS_FILE" 2>/dev/null || echo "false")
PASSSTRENGTH=$(jq -r '.passstrength // 10' "$OPTIONS_FILE" 2>/dev/null || echo "10")

echo "[INFO] Configuration:"
echo "  - Port: ${PORT}"
echo "  - Username: ${USERNAME}"
echo "  - Registration allowed: ${ALLOW_REGISTRATION}"
echo "  - Password strength: ${PASSSTRENGTH}"

echo "[INFO] Generating Gotify configuration..."

# Create Gotify configuration file
cat > "$CONFIG_PATH" <<EOF
server:
  listenaddr: "0.0.0.0"
  port: ${PORT}
  ssl:
    enabled: false
    redirecttohttps: false
  responseheaders:
    X-Custom-Header: ""
  cors:
    alloworigins:
      - "*"
    allowmethods:
      - "GET"
      - "POST"
      - "DELETE"
    allowheaders:
      - "*"

database:
  dialect: "sqlite3"
  connection: "/data/gotify.db"

passstrength: ${PASSSTRENGTH}

uploadedimagesdir: "/data/images"

pluginsdir: "/data/plugins"

defaultuser:
  name: "${USERNAME}"
  pass: "${PASSWORD}"

registration: ${ALLOW_REGISTRATION}
EOF

# Create necessary directories
echo "[INFO] Setting up data directories..."
mkdir -p /data/images /data/plugins
chown -R gotify:gotify /data
chmod -R 755 /data

# Find the gotify binary
echo "[INFO] Locating Gotify binary..."
GOTIFY_BIN=""
for path in /usr/local/bin/gotify /usr/bin/gotify /app/gotify /gotify; do
    if [[ -x "$path" ]]; then
        GOTIFY_BIN="$path"
        echo "[INFO] Found Gotify binary at: $GOTIFY_BIN"
        break
    fi
done

if [[ -z "$GOTIFY_BIN" ]]; then
    echo "[ERROR] Could not find Gotify binary"
    exit 1
fi

echo "[INFO] Starting Gotify server..."

# Determine the correct user switching command based on available tools
if command -v su-exec >/dev/null 2>&1; then
    exec su-exec gotify "$GOTIFY_BIN" --config "$CONFIG_PATH"
elif command -v gosu >/dev/null 2>&1; then
    exec gosu gotify "$GOTIFY_BIN" --config "$CONFIG_PATH"
else
    echo "[WARNING] Neither su-exec nor gosu found, running as root"
    exec "$GOTIFY_BIN" --config "$CONFIG_PATH"
fi