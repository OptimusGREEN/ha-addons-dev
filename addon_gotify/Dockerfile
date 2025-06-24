FROM alpine:3.19

# Install required packages
RUN apk add --no-cache bash jq ca-certificates curl su-exec file

# Create gotify user
RUN adduser -D -H -u 1000 gotify

# Download Gotify binary for amd64 (Intel NUC)
RUN echo "Downloading gotify-linux-amd64 for Intel NUC" && \
    curl -L "https://github.com/gotify/server/releases/download/v2.4.0/gotify-linux-amd64" -o /usr/local/bin/gotify && \
    chmod +x /usr/local/bin/gotify && \
    file /usr/local/bin/gotify && \
    /usr/local/bin/gotify --version || echo "Binary test completed"

# Copy the run script
COPY run.sh /run.sh
RUN chmod +x /run.sh

# Keep as root user for now (we'll drop privileges in the script)
# USER gotify

# Expose port
EXPOSE 80

# Run our custom script
CMD [ "/run.sh" ]