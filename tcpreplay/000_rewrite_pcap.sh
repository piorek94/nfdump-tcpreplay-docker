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
	set_env 'TCPREWRITE' 'off'
	set_env 'TCPREWRITE_IN_FILE'
	set_env 'TCPREWRITE_OUT_FILE'
	set_env 'TCPREWRITE_DMAC'
	set_env 'TCPREWRITE_SMAC'
	set_env 'TCPREWRITE_OLD_DIP'
	set_env 'TCPREWRITE_NEW_DIP'
	set_env 'TCPREWRITE_OLD_DPORT'
	set_env 'TCPREWRITE_NEW_DPORT'
}

# exits script with error message
# usage:
# 	error_exit "message"
error_exit() {
	echo "$1 Abording!" 1>&2
	exit 1
}

main() {

	setup_env

	if [ "${TCPREWRITE}" == "off" ]; then
		# The user has explicitly requested not to run tcprewrite; exit this script
		exit 0
	fi

	if [ -z "${TCPREWRITE_IN_FILE:-}" ]; then
		error_exit "TCPREWRITE_IN_FILE must be set."
	fi

	if [ -f "$TCPREPLAY_DATA_DIR/$TCPREWRITE_IN_FILE" ]; then
		TR_IN_FILE=--infile="$TCPREPLAY_DATA_DIR/${TCPREWRITE_IN_FILE}"
	else
		error_exit "'$TCPREWRITE_IN_FILE' input file must be located in '$TCPREPLAY_DATA_DIR' directory."
	fi

	if [ ! -z "${TCPREWRITE_OUT_FILE:-}" ]; then
		TR_OUT_FILE=--outfile="$TCPREPLAY_DATA_DIR/${TCPREWRITE_OUT_FILE}"
	else
		error_exit "TCPREWRITE_OUT_FILE must be set."
	fi

	if [ ! -z "${TCPREWRITE_DMAC:-}" ]; then
		TR_DMAC=--enet-dmac="${TCPREWRITE_DMAC}"
	fi

	if [ ! -z "${TCPREWRITE_SMAC:-}" ]; then
		TR_SMAC=--enet-smac="${TCPREWRITE_SMAC}"
	fi

	if [ ! -z "${TCPREWRITE_OLD_DIP:-}" ] && [ ! -z "${TCPREWRITE_NEW_DIP:-}" ]; then
		TR_DIP_MAP=--dstipmap="${TCPREWRITE_OLD_DIP}":"${TCPREWRITE_NEW_DIP}"
	fi

	if [ ! -z "${TCPREWRITE_OLD_DPORT:-}" ] && [ ! -z "${TCPREWRITE_NEW_DPORT:-}" ]; then
		TR_PORT_MAP=--portmap=${TCPREWRITE_OLD_DPORT}:${TCPREWRITE_NEW_DPORT}
	fi

	exec tcprewrite --fixcsum ${TR_IN_FILE} ${TR_OUT_FILE} ${TR_DMAC} ${TR_SMAC} ${TR_DIP_MAP} ${TR_PORT_MAP}

}

main
