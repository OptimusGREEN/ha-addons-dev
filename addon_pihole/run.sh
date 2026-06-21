#!/bin/bash
set -e

OPTIONS_FILE=/data/options.json

export FTLCONF_webserver_api_password=$(jq -r '.webpassword // ""' "$OPTIONS_FILE")
export TZ=$(jq -r '.timezone // "UTC"' "$OPTIONS_FILE")
export FTLCONF_dns_listeningMode=$(jq -r '.dns_listening_mode // "all"' "$OPTIONS_FILE")

WEB_PORT=$(jq -r '.web_port // 80' "$OPTIONS_FILE")
WEB_HTTPS_PORT=$(jq -r '.web_https_port // 443' "$OPTIONS_FILE")
export FTLCONF_webserver_port="${WEB_PORT},${WEB_HTTPS_PORT}s"

# Hand off to Pi-hole's real startup — do not replace this with anything else
exec /init