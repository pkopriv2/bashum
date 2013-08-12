
#! /usr/bin/env bash

export bashum_home=${bashum_home:-$HOME/.bashum}
export bashum_repo=${bashum_repo:-$HOME/.bashum_repo}
export bashum_tmp_dir=${bashum_tmp_dir:-/tmp/bashum/}

require 'lib/console.sh'
require 'lib/fail.sh'
require 'lib/help.sh'
require 'lib/cache.sh'

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
	Searches the remote repository for bashums to install.

'

	bold 'OPTIONS'
	printf '%s' '
	-None 

'
}

search() {
	if help? "$@" 
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

	cache_ensure 


	local bashums=( $(cache_search $1) )
	for bashum in ${bashums[@]}
	do
		local name=$(cache_bashum_get_name $bashum)
		local version=$(cache_bashum_get_version $bashum)

		printf '%-30s[%s]\n' "$name" "$version"
	done
}
