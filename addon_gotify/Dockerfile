FROM golang:1.22-alpine as builder

WORKDIR /app

# Install dependencies
RUN apk add --no-cache git ca-certificates

# Clone the latest stable Gotify release
RUN git clone --depth=1 --branch v2.4.0 https://github.com/gotify/server.git .

# Build the binary
RUN go build -o gotify

# --- Final stage image ---
FROM alpine:3.19

# Install bash and jq for the run script
RUN apk add --no-cache bash jq

# Create non-root user
RUN adduser -D -H -u 1000 gotify

# Copy binary and script
COPY --from=builder /app/gotify /usr/local/bin/gotify
COPY run.sh /run.sh

# Make script executable before switching user
RUN chmod +x /run.sh

# Use non-root user
USER gotify

# Expose port
EXPOSE 80

# Run the script
CMD [ "/run.sh" ]