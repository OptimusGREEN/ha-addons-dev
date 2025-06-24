FROM gotify/server:2.4.0

# Switch to root to make modifications
USER root

# Install jq and bash
RUN if command -v apk >/dev/null 2>&1; then \
        apk add --no-cache bash jq; \
    elif command -v apt-get >/dev/null 2>&1; then \
        apt-get update && apt-get install -y bash jq && rm -rf /var/lib/apt/lists/*; \
    else \
        echo "Package manager not found"; exit 1; \
    fi

# Copy our custom run script
COPY run.sh /run.sh
RUN chmod +x /run.sh

# Find where gotify is installed in the original image
RUN find / -name "gotify" -type f 2>/dev/null || echo "Gotify binary search completed"

# Create gotify user if it doesn't exist
RUN id gotify || adduser -D -H -u 1000 gotify

# Expose port
EXPOSE 80

# Use our custom run script
CMD ["/run.sh"]