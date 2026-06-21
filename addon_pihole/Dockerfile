FROM lscr.io/linuxserver/pihole:latest

RUN apt-get update && \
    apt-get install -y --no-install-recommends jq && \
    rm -rf /var/lib/apt/lists/*

# Redirect linuxserver's persistent path to the Supervisor's auto-mounted /data
RUN rm -rf /config && ln -s /data /config

# Hook our options-loader into the image's documented init system
COPY run.sh /custom-cont-init.d/99-ha-options.sh
RUN chmod +x /custom-cont-init.d/99-ha-options.sh