FROM gotify/server:2.6.3

# Switch to root to make modifications
USER root

# Install jq and bash
RUN if command -v apk >/dev/null 2>&1; then \
        apk add --no-cache bash jq su-exec; \
    elif command -v apt-get >/dev/null 2>&1; then \
        apt-get update && apt-get install -y bash jq gosu && rm -rf /var/lib/apt/lists/*; \
    else \
        echo "Package manager not found"; exit 1; \
    fi

# Copy our custom run script
COPY run.sh /run.sh
RUN chmod +x /run.sh

# Create gotify user if it doesn't exist (with consistent UID across architectures)
RUN id gotify 2>/dev/null || adduser -D -H -u 1000 gotify

# Create data directory with proper permissions
RUN mkdir -p /data && chown gotify:gotify /data

# Expose port
EXPOSE 80

# Use our custom run script
CMD ["/run.sh"]