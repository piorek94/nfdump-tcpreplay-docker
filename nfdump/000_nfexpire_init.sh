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
	set_env 'NFEXPIRE' 'off'
	set_env 'NFEXPIRE_TIME'
	set_env 'NFEXPIRE_SIZE'
}

main() {

	setup_env

	if [ "${NFEXPIRE}" == "off" ]; then
		# The user has explicitly requested not to setup nfexpire; exit this script
		exit 0
	fi

	if [ -z "${NFEXPIRE_TIME:-}" ] && [ -z "${NFEXPIRE_SIZE:-}" ]; then
		# Nothing to do
		exit 0
	fi

	if [ ! -z "${NFEXPIRE_TIME:-}" ]; then
		NFEXPIRE_TIME_FLAGS="-t ${NFEXPIRE_TIME}"
	fi

	if [ ! -z "${NFEXPIRE_SIZE:-}" ]; then
		NFEXPIRE_SIZE_FLAGS="-s ${NFEXPIRE_SIZE}"
	fi

	exec nfexpire -u $NFDUMP_DATA_DIR ${NFEXPIRE_TIME_FLAGS} ${NFEXPIRE_SIZE_FLAGS}
}

main
