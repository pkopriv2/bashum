#! /usr/bin/env bash

export bashum_home=${bashum_home:-$HOME/.bashum}
export bashum_repo=${bashum_repo:-$HOME/.bashum_repo}
export bashum_path=${bashum_path:-"$bashum_home:$bashum_repo/packages"}
export bashum_project_file=${bashum_project_file:-"project.sh"}

require 'lib/console.sh'
require 'lib/help.sh'
require 'lib/project_file.sh'
require 'lib/package.sh'

test_usage() {
	echo "$bashum_cmd test [<expression>]"
}

test_help() {
	bold 'USAGE'
	echo 
	printf "\t"; test_usage
	echo


	bold 'DESCRIPTION'
	printf '%s' '
	Runs all tests that match the given expression, or all tests.

'

	bold 'OPTIONS'
	printf '%s' '
	-None 

'
}

test() {
	if help? "$@" 
	then
		test_help "$@"
		exit $?
	fi


	local project_file=$bashum_project_file 
	if [[ ! -f $project_file ]]
	then
		error "Unable to locate project.sh." 
		exit 1
	fi



	if [[ -n $1 ]]
	then
		local test_files=()
		while (( $# > 0 ))
		do
			test_files+=( $(find test/ -name "$1"_test.sh"" ) )
			shift 
		done
	else
		local test_files=( $(find test/ -name '*_test.sh') )
	fi

	if (( ${#test_files[@]} == 0 ))
	then
		echo "No tests found."
		exit 0 
	fi


	project_file_load $project_file

	declare local dependency
	for dependency in "${dependencies[@]}"
	do 
		local dep_name=${dependency%%:*}
		local dep_version=${dependency##*:}

		if ! package_is_installed $dep_name $dep_version
		then
			error "Missing dependency: [$dep_name${dep_version:+:$dep_version}]"
			exit 1
		fi
	done

	local cwd=$(pwd)
	export PATH=$cwd/bin:$PATH
	export bashum_path=$cwd:$bashum_path
	export project_root=$cwd

	(
		set +o errexit # turn off errexit for the test run

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

		for test_file in ${test_files[@]}
		do
			echo "Running tests for: $test_file" 

			source $test_file 
		done
	)
}
