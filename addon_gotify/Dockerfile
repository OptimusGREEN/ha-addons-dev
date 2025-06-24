FROM golang:1.22-alpine AS builder

WORKDIR /app

# Install build dependencies
RUN apk add --no-cache git make gcc musl-dev

# Clone Gotify source
RUN git clone --depth=1 --branch v2.4.0 https://github.com/gotify/server.git .

# Build static binary
RUN CGO_ENABLED=1 GOOS=linux go build -a -ldflags '-linkmode external -extldflags "-static"' -o gotify

# Final stage
FROM alpine:3.19

# Install runtime dependencies
RUN apk add --no-cache bash jq ca-certificates su-exec

# Create gotify user
RUN adduser -D -H -u 1000 gotify

# Copy the statically built binary
COPY --from=builder /app/gotify /usr/local/bin/gotify
RUN chmod +x /usr/local/bin/gotify

# Copy run script
COPY run.sh /run.sh
RUN chmod +x /run.sh

# Expose port
EXPOSE 80

# Run script
CMD ["/run.sh"]