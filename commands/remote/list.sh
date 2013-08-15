#! /usr/bin/env bash

require 'lib/console.sh'
require 'lib/fail.sh'
require 'lib/help.sh'
require 'lib/bashum/remote.sh'

remote_list_usage() {
	echo "$bashum_cmd remote list <package> [options]"
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
	if help? "$@" 
	then
		remote_list_help "$@"
		exit $?
	fi

	info "Remote Repositories:"

	local urls=( $(remote_repo_urls_get_all) ) 
	for url in ${urls[@]} 
	do
		echo "    - $url"
	done

}
