#!/bin/sh

set -eu

SQUID_CACHE_DIR="/var/cache/squid"

if [ -z "${1:-}" ]; then
  if [ ! -d "${SQUID_CACHE_DIR}/00" ]; then
    $(command -v squid) -N -f "/etc/squid/squid.conf" -z
  fi
  exec "$(command -v squid)" -f "/etc/squid/squid.conf" -NYCd 1 "${EXTRA_ARGS:-}"
else
  exec "$@"
fi