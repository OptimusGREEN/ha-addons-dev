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

# Check if this is a fresh installation
FRESH_INSTALL=false
if [[ ! -f "/data/gotify.db" ]] && [[ ! -f "$CONFIG_PATH" ]]; then
    FRESH_INSTALL=true
    echo "[INFO] Fresh installation detected"
fi

echo "[INFO] Checking Gotify configuration..."

# Only create full configuration on fresh install, otherwise update selectively
if [[ "$FRESH_INSTALL" == "true" ]]; then
    echo "[INFO] Creating initial Gotify configuration for fresh install..."
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
    echo "[INFO] Initial configuration created successfully"
else
    echo "[INFO] Configuration file exists, preserving existing settings"
    echo "[INFO] Updating only basic server settings..."
    
    # Update only the port if it's different, preserving other settings
    if command -v yq >/dev/null 2>&1; then
        # Use yq if available for precise YAML editing
        yq eval ".server.port = ${PORT}" -i "$CONFIG_PATH"
        yq eval ".server.listenaddr = \"0.0.0.0\"" -i "$CONFIG_PATH"
        yq eval ".registration = ${ALLOW_REGISTRATION}" -i "$CONFIG_PATH"
        yq eval ".passstrength = ${PASSSTRENGTH}" -i "$CONFIG_PATH"
        echo "[INFO] Configuration updated using yq"
    else
        # Fallback: basic sed replacements (less reliable but works)
        sed -i "s/port: [0-9]*/port: ${PORT}/" "$CONFIG_PATH"
        sed -i "s/listenaddr: \".*\"/listenaddr: \"0.0.0.0\"/" "$CONFIG_PATH"
        sed -i "s/registration: .*/registration: ${ALLOW_REGISTRATION}/" "$CONFIG_PATH"
        sed -i "s/passstrength: [0-9]*/passstrength: ${PASSSTRENGTH}/" "$CONFIG_PATH"
        echo "[INFO] Configuration updated using sed"
    fi
fi

# Create necessary directories
echo "[INFO] Setting up data directories..."
mkdir -p /data/images /data/plugins

# Set permissions based on available user
if id gotify >/dev/null 2>&1; then
    echo "[INFO] Setting permissions for gotify user..."
    chown -R gotify:gotify /data 2>/dev/null || echo "[WARNING] Could not change ownership to gotify user"
    chmod -R 755 /data
else
    echo "[WARNING] Gotify user not found, using root permissions"
    chmod -R 755 /data
fi

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

# Determine the correct execution method based on available tools and user
if id gotify >/dev/null 2>&1; then
    if command -v su-exec >/dev/null 2>&1; then
        echo "[INFO] Using su-exec to run as gotify user"
        exec su-exec gotify "$GOTIFY_BIN" --config "$CONFIG_PATH"
    elif command -v gosu >/dev/null 2>&1; then
        echo "[INFO] Using gosu to run as gotify user"
        exec gosu gotify "$GOTIFY_BIN" --config "$CONFIG_PATH"
    else
        echo "[INFO] Running as gotify user with su"
        exec su gotify -s /bin/sh -c "$GOTIFY_BIN --config $CONFIG_PATH"
    fi
else
    echo "[WARNING] Gotify user not found, running as current user"
    exec "$GOTIFY_BIN" --config "$CONFIG_PATH"
fi