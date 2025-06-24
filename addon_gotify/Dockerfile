FROM alpine:3.19

# Install required packages
RUN apk add --no-cache bash jq ca-certificates curl

# Create gotify user
RUN adduser -D -H -u 1000 gotify

# Download Gotify binary based on architecture
RUN ARCH=$(uname -m) && \
    case "${ARCH}" in \
      x86_64) GOTIFY_ARCH="amd64" ;; \
      aarch64) GOTIFY_ARCH="arm64" ;; \
      armv7l) GOTIFY_ARCH="arm-7" ;; \
      *) echo "Unsupported architecture: ${ARCH}" && exit 1 ;; \
    esac && \
    echo "Downloading gotify for architecture: ${GOTIFY_ARCH}" && \
    curl -L "https://github.com/gotify/server/releases/download/v2.4.0/gotify-linux-${GOTIFY_ARCH}" -o /usr/local/bin/gotify && \
    chmod +x /usr/local/bin/gotify

# Copy the run script
COPY run.sh /run.sh
RUN chmod +x /run.sh

# Switch to gotify user
USER gotify

# Expose port
EXPOSE 80

# Run our custom script
CMD [ "/run.sh" ]