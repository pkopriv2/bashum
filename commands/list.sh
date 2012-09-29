#! /usr/bin/env bash

export bashum_home=${bashum_home:-$HOME/.bashum}
export bashums_home=${bashums_home:-$bashum_home/bashums}

require 'lib/info.sh'
require 'lib/project.sh'

list() {
	local detailed=false
	while [[ $# -gt 0 ]]
	do
		arg="$1"

		case "$arg" in
			-d|--detailed)
				detailed=true
				;;
		esac
		shift
	done
	
	info "** Currently installed bashums **"
	echo


	for project_file in $(ls $bashums_home/*/project.sh)
	do
		project_load_file $project_file
		echo -n "  - $name [$version]"

		if [[ -n $description ]] && $detailed
		then
			echo " - $description"
		else 
			echo
		fi
	done
		
}

list_help() {
	echo;
} 
