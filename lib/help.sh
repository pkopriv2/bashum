#! /usr/bin/env bash

help_detailed?() {
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

help?() {
	case "$1" in
		-h|--help|help)
			return 0
			;;
	esac

	return 1
}
