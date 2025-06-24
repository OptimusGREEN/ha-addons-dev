FROM gotify/server:2.4.0

# Switch to root to install dependencies
USER root

# Install bash and jq for the run script
RUN apk add --no-cache bash jq

# Copy the run script
COPY run.sh /run.sh
RUN chmod +x /run.sh

# Create gotify user with same UID as addon expects
RUN adduser -D -H -u 1000 gotify || true

# Switch back to gotify user
USER gotify

# Expose port
EXPOSE 80

# Run our custom script
CMD [ "/run.sh" ]