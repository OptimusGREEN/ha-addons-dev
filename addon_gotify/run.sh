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

# Check if this is a fresh installation - be more specific about what constitutes "fresh"
FRESH_INSTALL=false
DB_EXISTS=false
CONFIG_EXISTS=false

if [[ -f "/data/gotify.db" ]]; then
    DB_EXISTS=true
    echo "[INFO] Database file exists: /data/gotify.db"
fi

if [[ -f "$CONFIG_PATH" ]]; then
    CONFIG_EXISTS=true
    echo "[INFO] Configuration file exists: $CONFIG_PATH"
fi

# Only consider it fresh if BOTH database AND config are missing
if [[ "$DB_EXISTS" == "false" ]] && [[ "$CONFIG_EXISTS" == "false" ]]; then
    FRESH_INSTALL=true
    echo "[INFO] Fresh installation detected - no database or config found"
else
    echo "[INFO] Existing installation detected"
fi

echo "[INFO] Checking Gotify configuration..."

# Create necessary directories FIRST
echo "[INFO] Setting up data directories..."
mkdir -p /data/images /data/plugins

# Handle configuration based on installation state
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
    
elif [[ "$CONFIG_EXISTS" == "false" ]] && [[ "$DB_EXISTS" == "true" ]]; then
    # Database exists but config is missing - create minimal config without defaultuser
    echo "[INFO] Database exists but config missing - creating config without default user"
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

registration: ${ALLOW_REGISTRATION}
EOF
    echo "[INFO] Configuration recreated for existing database"
    
else
    echo "[INFO] Configuration file exists, updating only necessary settings..."
    
    # Backup existing config
    cp "$CONFIG_PATH" "$CONFIG_PATH.backup"
    
    # Update only the port and basic settings, preserving user data
    if command -v yq >/dev/null 2>&1; then
        # Use yq if available for precise YAML editing
        yq eval ".server.port = ${PORT}" -i "$CONFIG_PATH"
        yq eval ".server.listenaddr = \"0.0.0.0\"" -i "$CONFIG_PATH"
        yq eval ".registration = ${ALLOW_REGISTRATION}" -i "$CONFIG_PATH"
        yq eval ".passstrength = ${PASSSTRENGTH}" -i "$CONFIG_PATH"
        # Ensure database path is correct
        yq eval ".database.connection = \"/data/gotify.db\"" -i "$CONFIG_PATH"
        yq eval ".uploadedimagesdir = \"/data/images\"" -i "$CONFIG_PATH"
        yq eval ".pluginsdir = \"/data/plugins\"" -i "$CONFIG_PATH"
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

# Set proper permissions - be more careful about this
echo "[INFO] Setting file permissions..."

# First, ensure we own the files we just created
chown root:root "$CONFIG_PATH" 2>/dev/null || true

# Handle permissions based on available user, but be less aggressive
if id gotify >/dev/null 2>&1; then
    echo "[INFO] Setting permissions for gotify user..."
    # Only change ownership of files that don't exist or are owned by root
    find /data -type f \( -user root -o ! -user gotify \) -exec chown gotify:gotify {} \; 2>/dev/null || true
    find /data -type d \( -user root -o ! -user gotify \) -exec chown gotify:gotify {} \; 2>/dev/null || true
    
    # Set minimal required permissions
    chmod 644 "$CONFIG_PATH"
    chmod 755 /data /data/images /data/plugins
    
    # Database file needs special handling
    if [[ -f "/data/gotify.db" ]]; then
        chown gotify:gotify "/data/gotify.db" 2>/dev/null || true
        chmod 644 "/data/gotify.db"
    fi
else
    echo "[WARNING] Gotify user not found, using root permissions"
    chmod 644 "$CONFIG_PATH"
    chmod 755 /data /data/images /data/plugins
    if [[ -f "/data/gotify.db" ]]; then
        chmod 644 "/data/gotify.db"
    fi
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

# Final check before starting
echo "[INFO] Final pre-start checks:"
echo "  - Database exists: $([ -f "/data/gotify.db" ] && echo "YES" || echo "NO")"
echo "  - Config exists: $([ -f "$CONFIG_PATH" ] && echo "YES" || echo "NO")"
echo "  - Images dir exists: $([ -d "/data/images" ] && echo "YES" || echo "NO")"
echo "  - Plugins dir exists: $([ -d "/data/plugins" ] && echo "YES" || echo "NO")"

echo "[INFO] Starting Gotify server..."

# Set environment variables for better database handling
export GOTIFY_DATABASE_DIALECT="sqlite3"
export GOTIFY_DATABASE_CONNECTION="/data/gotify.db"

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