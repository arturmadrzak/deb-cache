FROM alpine:3.14

LABEL maintainer="Artur Mądrzak <artur@madrzak.eu>"

ENV SQUID_VERSION=5.0.6-r0

RUN apk add --no-cache squid=${SQUID_VERSION}

COPY squid.conf.template /etc/squid/squid.conf.template
COPY entrypoint.sh /sbin/entrypoint.sh
RUN chmod 755 /sbin/entrypoint.sh

EXPOSE 3128/tcp

ENTRYPOINT ["/sbin/entrypoint.sh"]
