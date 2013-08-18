#! /usr/bin/env bash

require 'lib/bashum/cli/options.sh'
require 'lib/bashum/cli/console.sh'
require 'lib/bashum/lang/fail.sh'
require 'lib/bashum/remote.sh'

search_usage() {
	echo "$bashum_cmd search <package> [options]"
}

search_help() {
	bold 'USAGE'
	echo 
	printf "\t"; search_usage
	echo


	bold 'DESCRIPTION'
	printf '%s' '
	Searches the remote repository for bashums matching the given expressions.  
	Search expressions should be in a form compatible with grep. 

	For a list of the repositories that will be searched, use the command: 
	
	    bashum remote list 

'

	bold 'OPTIONS'
	printf '%s' '
	-None 

'
}

search() {
	if options_is_help "$@" 
	then
		search_help "$@"
		exit $?
	fi

	if ! command -v git &> /dev/null
	then
		fail "git is required for searching the remote repo."
	fi

	if [[ -z "$1" ]]
	then
		error "Must provide a search expression."
		echo 

		echo -n 'USAGE: '; search_usage 
		exit 1
	fi

	remote_repos_ensure_all 

	info "Matched bashums:"
	echo 

	# TODO: think about displaying them differently: [name]     [version1, version2, ...]
	local bashums=( $(remote_bashums_search $1) )
	for bashum in ${bashums[@]}
	do
		declare local name
		declare local version

		name=$(remote_bashum_get_name $bashum) || 
			name=$bashum

		version=$(remote_bashum_get_version $bashum) || 
			version=""

		printf '%-30s[%s]\n' "$name" "$version"
	done
}
