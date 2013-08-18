#! /usr/bin/env bash

export bashum_home=${bashum_home:-$HOME/.bashum}
export bashum_repo=${bashum_repo:-$HOME/.bashum_repo}

require 'lib/bashum/cli/console.sh'
require 'lib/bashum/cli/options.sh'
require 'lib/bashum/repo.sh'
require 'lib/bashum/project_file.sh'

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
	-None

'
} 

list() {
	if options_is_help "$@"
	then
		shift 
		list_help "$@"
		exit $?
	fi

	info "Installed Bashums: "
	echo


	local packages=( $(repo_package_get_all) )
	for package in "${packages[@]}"
	do
		local project_file=$(repo_package_get_project_file $package)

		project_file_api 

		local name=""
		name() {
			if (( $# != 1 ))
			then
				fail "Usage: name <name>"
			fi

			name=$1
		}

		local version=""
		version() {
			if (( $# != 1 ))
			then
				fail "Usage: version <version>"
			fi

			version=$1
		}


		source $project_file
		project_file_api_unset

		printf '%-30s[%s]\n' "$name" "$version"
	done
}
