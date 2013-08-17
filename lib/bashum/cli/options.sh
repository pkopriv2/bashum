#! /usr/bin/env bash

options_is_detailed_help() {
	if (( $# == 0 )) 
	then
		return 1
	fi

	while (( $# > 0 )) 
	do
		local arg=$1
		shift

		case "$arg" in
			-d|--detailed)
				return 0
				;;
		esac
	done

	return 1
}

options_is_help() {
	case "$1" in
		-h|--help|help)
			return 0
			;;
	esac

	return 1
}

options_is_usage() {
	case "$1" in
		-u|--usage|usage)
			return 0
			;;
	esac

	return 1
}

options_is_version() {
	case "$1" in
		-v|--version|version)
			return 0
			;;
	esac

	return 1
}
