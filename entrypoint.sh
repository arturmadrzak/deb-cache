#!/bin/sh

set -eu

# Squid configuration entries that can be overwritten by this script
CONFIG_KEYS="cache_dir cache_dir_size_mb maximum_object_size_mb"

# Default values for known configuration keys
# Squid cache dir inside a container (cache_dir)
DEF_CACHE_DIR="/var/cache/squid"
# Maximum cache size on a disk (cache_dir)
# shellcheck disable=SC2034
DEF_CACHE_DIR_SIZE_MB="2048"
# Maximum size of single object (maximum_object_size)
# shellcheck disable=SC2034
DEF_MAXIMUM_OBJECT_SIZE_MB="2048"

set_default() {
	_key=${1:?Missing key name}
	_def_var_name="DEF_$(echo "${_key}" | tr '[:lower:]' '[:upper:]')"
	eval "echo \$${_def_var_name}"
}

generate_config()
{
	_template="/etc/squid/squid.conf.template"

	for _key in ${CONFIG_KEYS}; do
		_env_var_name="SQUID_$(echo "${_key}" | tr '[:lower:]' '[:upper:]')"
		_env_var_value="$(eval "echo \${${_env_var_name}:-}")"
		if [ -n "${_env_var_value}" ]; then
			_value="${_env_var_value}"
		else
			_value=$(set_default "${_key}")
		fi
		echo "Set: <${_key}> to '${_value}'"
		sed -i "s:<${_key}>:${_value}:g" "${_template}"
	done

	mv "${_template}" "/etc/squid/squid.conf"
}

start()
{
	if [ -z "${1:-}" ]; then
	  chgrp squid "${DEF_CACHE_DIR}"
	  chmod g+w "${DEF_CACHE_DIR}"
	  if [ ! -d "${DEF_CACHE_DIR}/00" ]; then
		$(command -v squid) -N -f "/etc/squid/squid.conf" -z
	  fi
	  exec "$(command -v squid)" -f "/etc/squid/squid.conf" -NYCd 1 "${EXTRA_ARGS:-}"
	else
	  exec "$@"
	fi
}

main()
{
	generate_config
	start "${@}"
}

main "${@}"

exit 0
