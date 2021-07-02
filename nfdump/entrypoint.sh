#!/usr/bin/env bash

set -e

# usage: set_env VAR [DEFAULT]
#    ie: set_env 'XYZ_DB_PASSWORD' 'example'
set_env() {
	local var="$1"
	local def="${2:-}"
	local val="$def"
	if [ "${!var:-}" ]; then
		val="${!var}"
	fi
	export "$var"="$val"
}

# Loads various settings that are used elsewhere in the script
# This should be called before any other functions
setup_env() {
	set_env 'NF_VIRT_MEM_LIMIT'
}

# usage: process_init_files [file [file [...]]]
#    ie: process_init_files /scripts/*
# process initializer files, based on file extensions and permissions
process_init_files() {

	local f
	for f; do
		case "$f" in
			*.sh)
				if [ -x "$f" ]; then
					echo "$0: running $f"
					"$f"
				else
					echo "$0: sourcing $f"
					. "$f"
				fi
				;;
			*)
					echo "$0: ignoring $f"
					;;
		esac
	done

}

main() {

	setup_env

	if [ "$1" = 'nfcapd' ] || [ "$1" = 'sfcapd' ]; then
		# check dir permissions
		ls /entrypoint-init.d/ > /dev/null
		process_init_files /entrypoint-init.d/*
	fi

	if [ -z "${NF_VIRT_MEM_LIMIT:-}" ]; then
		exec "$@"
	else
		ulimit -v ${NF_VIRT_MEM_LIMIT} && exec "$@"
	fi

}

main "$@"
