#! /usr/bin/env bash

require 'lib/bashum/cli/console.sh'
require 'lib/bashum/lang/fail.sh'
require 'lib/bashum/cli/options.sh'
require 'lib/bashum/remote.sh'

remote_list_usage() {
	echo "$bashum_cmd remote list [options]"
}

remote_list_help() {
	bold 'USAGE'
	echo 
	printf "\t"; remote_list_usage
	echo


	bold 'DESCRIPTION'
	printf '%s' '
	lists a remote repository from the list of repos to include
	when searching and installing.

'

	bold 'OPTIONS'
	printf '%s' '
	-None
'
}

remote_list() {
	if options_is_help "$@" 
	then
		remote_list_help "$@"
		exit $?
	fi

	info "Remote Repositories:"
	echo 

	local urls=( $(remote_repo_urls_get_all) ) 
	for url in ${urls[@]} 
	do
		echo "    - $url"
	done

}
