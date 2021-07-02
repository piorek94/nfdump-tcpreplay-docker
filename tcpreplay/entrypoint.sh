#!/usr/bin/env bash

set -e

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

	if [ "$1" = 'tcpreplay' ]; then
		# check dir permissions
		ls /entrypoint-init.d/ > /dev/null
		process_init_files /entrypoint-init.d/*
	fi

	exec "$@"

}

main "$@"
