#! /usr/bin/env bash

export bashum_home=${bashum_home:-$HOME/.bashum}
export bashum_repo=${bashum_repo:-$HOME/.bashum_repo}
export bashum_path=${bashum_path:-"$bashum_home:$bashum_repo/packages"}
export bashum_project_file=${bashum_project_file:-"project.sh"}

require 'lib/error.sh'
require 'lib/font.sh'
require 'lib/help.sh'
require 'lib/project_file.sh'
require 'lib/package.sh'

run_usage() {
	echo "$bashum_cmd run [project] [options]"
}

run_help() {
	bold 'USAGE'
	echo 
	printf "\t"; run_usage
	echo


	bold 'DESCRIPTION'
	printf '%s' '
	Runs one of the executable files contained in project.  Sets up 
	the environment as if the project was assembled and installed.

'

	bold 'OPTIONS'
	printf '%s' '
	-None 

'
}

run() {
	if help? "$@" 
	then
		run_help "$@"
		exit $?
	fi


	local project_file=$bashum_project_file 
	if [[ ! -f $project_file ]]
	then
		error "Unable to locate project.sh." 
		exit 1
	fi

	if [[ -z "$1" ]]  
	then
		error "Must provide a command."
		echo 

		run_usage
		exit 1
	fi

	local cmd=$1 
	shift 

	if [[ ! -f bin/$cmd ]]
	then
		error "Invalid command.  Must be an executable in /bin"
		exit 1
	fi

	project_file_validate_dependencies $project_file

	local cwd=$(pwd)
	export PATH=$cwd/bin:$PATH
	export bashum_path=$cwd:$bashum_path

	(
		if [[ -d env ]]
		then
			for file in $(ls env/*.sh)
			do
				if [[ -f $file ]]
				then
					source $file
				fi
			done
		fi

		source $cmd "$@" 
	)
}
