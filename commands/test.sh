#! /usr/bin/env bash

export bashum_home=${bashum_home:-$HOME/.bashum}
export bashum_repo=${bashum_repo:-$HOME/.bashum_repo}
export bashum_path=${bashum_path:-"$bashum_home:$bashum_repo/packages"}
export bashum_project_file=${bashum_project_file:-"project.sh"}

require 'lib/bashum/cli/console.sh'
require 'lib/bashum/cli/options.sh'

require 'lib/bashum/project_file.sh'
require 'lib/bashum/package.sh'
require 'lib/bashum/install.sh'

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
	if options_is_help "$@" 
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
			test_files+=( $(find test -name "$1"_test.sh"" ) )
			shift 
		done
	else
		local test_files=( $(find test -name '*_test.sh') )
	fi

	if (( ${#test_files[@]} == 0 ))
	then
		echo "No tests found."
		exit 0 
	fi

	install_dependencies $project_file

	(
		set +o errexit # turn off errexit for the test run

		# export the expected global vars
		local cwd=$(pwd)
		export PATH=$cwd/bin:$PATH
		export bashum_path=$cwd:$bashum_path
		export project_root=$cwd

		# source all the project's environment files.
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

		# remove any existing test functions.
		local existing_tests=$(get_all_test_functions)
		for t in ${existing_tests[@]} 
		do
			unset -f $t
		done

		echo "Running tests: ${test_files[@]}"
		for test_file in ${test_files[@]}
		do
			echo; echo "Running tests for: $test_file" 

			(
				source $test_file 

				local tests=$(get_all_test_functions)
				for fn in ${tests[@]}
				do
					if declare -F before &> /dev/null
					then
						before || {
							error "Error running before"
							exit 1
						}
					fi

					echo -n "Running test: $fn: "

					(
						$fn  
						echo "Passed"

					) || {
						echo "Failed"

						error "Error running test: $fn"
						exit 1
					}
				done
			) || {
				error "Error running tests for file: $test_file"
				exit 1
			}
		done
	) || { 
		error "Tests failed to execute."
		exit 1
	}
}

# usage: get_all_test_functions 
#
# Returns all the functions that start with test_ in the current 
# subshell.
get_all_test_functions() {
 	declare -F | grep ' test_.*' | sed 's|declare -f||' 
}
