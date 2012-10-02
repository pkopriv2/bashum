#! /usr/bin/env bash

export bashum_home=${bashum_home:-$HOME/.bashum}
export bashum_repo=${bashum_repo:-$HOME/.bashum_repo}

require 'lib/console.sh'
require 'lib/project_file.sh'
require 'lib/help.sh'

list_usage() {
	echo "$bashum_cmd list [options]"
}

list_help() {
	bold 'USAGE'
	echo
	printf "\t"; list_usage
	echo


	bold 'DESCRIPTION'
	printf '%s' '
	Lists all of the currently installed bashums.

'

	bold 'OPTIONS'
	printf '%s' '
	-d|--detailed    Prints the descriptions of the bashums.

'
} 

list() {
	if help? "$@"
	then
		shift 
		list_help "$@"
		exit $?
	fi

	local detailed=false
	while [[ $# -gt 0 ]]
	do
		arg="$1"
		shift

		case "$arg" in
			-d|--detailed)
				detailed=true
				;;
		esac
	done
	
	info "Installed Bashums: "
	echo


	for project_file in $(ls $bashum_repo/packages/*/project.sh 2>/dev/null)
	do
		project_file_load $project_file
		printf "\t- %s" "$name [$version]" 

		if [[ -n $description ]] && $detailed
		then
			echo "    - $description"
		else 
			echo
		fi
	done
		
}
