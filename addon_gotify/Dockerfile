FROM alpine:3.19 as downloader

# Install curl to download binaries
RUN apk add --no-cache curl

# Set architecture-specific variables
ARG TARGETARCH
RUN case "${TARGETARCH}" in \
      amd64) GOTIFY_ARCH="amd64" ;; \
      arm64) GOTIFY_ARCH="arm64" ;; \
      arm) GOTIFY_ARCH="arm-7" ;; \
      *) echo "Unsupported architecture: ${TARGETARCH}" && exit 1 ;; \
    esac && \
    curl -L "https://github.com/gotify/server/releases/download/v2.4.0/gotify-linux-${GOTIFY_ARCH}" -o /gotify && \
    chmod +x /gotify

# Final image
FROM alpine:3.19

# Install required packages
RUN apk add --no-cache bash jq ca-certificates

# Create gotify user
RUN adduser -D -H -u 1000 gotify

# Copy gotify binary from downloader stage
COPY --from=downloader /gotify /usr/local/bin/gotify

# Copy the run script
COPY run.sh /run.sh
RUN chmod +x /run.sh

# Switch to gotify user
USER gotify

# Expose port
EXPOSE 80

# Run our custom script
CMD [ "/run.sh" ]