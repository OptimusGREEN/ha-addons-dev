FROM pihole/pihole:latest

RUN apk add --no-cache jq

COPY run.sh /
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
