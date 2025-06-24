FROM gotify/server:2.6.3

# Switch to root to make modifications
USER root

# Install jq, bash, and yq for configuration management
RUN if command -v apk >/dev/null 2>&1; then \
        apk add --no-cache bash jq su-exec && \
        wget -qO /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_$(apk --print-arch) && \
        chmod +x /usr/local/bin/yq; \
    elif command -v apt-get >/dev/null 2>&1; then \
        apt-get update && apt-get install -y bash jq gosu wget && \
        wget -qO /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_$(dpkg --print-architecture) && \
        chmod +x /usr/local/bin/yq && \
        rm -rf /var/lib/apt/lists/*; \
    else \
        echo "Package manager not found"; exit 1; \
    fi

# Copy our custom run script
COPY run.sh /run.sh
RUN chmod +x /run.sh

# Ensure the data directory structure exists and has proper permissions
RUN mkdir -p /data /data/images /data/plugins && \
    chmod 755 /data /data/images /data/plugins

# Check if gotify user exists and create if necessary
RUN if id gotify >/dev/null 2>&1; then \
        echo "User gotify already exists"; \
        chown -R gotify:gotify /data; \
    else \
        echo "Creating gotify user"; \
        if command -v adduser >/dev/null 2>&1; then \
            adduser -D -H -u 1000 gotify; \
        elif command -v useradd >/dev/null 2>&1; then \
            useradd -r -u 1000 -s /bin/false gotify; \
        else \
            echo "No user creation command found, will run as root"; \
        fi; \
        if id gotify >/dev/null 2>&1; then \
            chown -R gotify:gotify /data; \
        fi; \
    fi

# Ensure data directory is a volume mount point
VOLUME ["/data"]

# Expose port
EXPOSE 80

# Use our custom run script
CMD ["/run.sh"]