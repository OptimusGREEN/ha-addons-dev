#!/usr/bin/with-contenv bash

OPTIONS_FILE=/data/options.json

WEBPASSWORD=$(jq -r '.webpassword // ""' "$OPTIONS_FILE")
TIMEZONE=$(jq -r '.timezone // "UTC"' "$OPTIONS_FILE")
DNS_MODE=$(jq -r '.dns_listening_mode // "all"' "$OPTIONS_FILE")
WEB_PORT=$(jq -r '.web_port // 80' "$OPTIONS_FILE")
WEB_HTTPS_PORT=$(jq -r '.web_https_port // 443' "$OPTIONS_FILE")

mkdir -p /var/run/s6/container_environment
echo -n "$WEBPASSWORD"                    > /var/run/s6/container_environment/FTLCONF_webserver_api_password
echo -n "$TIMEZONE"                       > /var/run/s6/container_environment/TZ
echo -n "$DNS_MODE"                       > /var/run/s6/container_environment/FTLCONF_dns_listeningMode
echo -n "${WEB_PORT},${WEB_HTTPS_PORT}s"  > /var/run/s6/container_environment/FTLCONF_webserver_port
echo -n "1000"                            > /var/run/s6/container_environment/PUID
echo -n "1000"                            > /var/run/s6/container_environment/PGID