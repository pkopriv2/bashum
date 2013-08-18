#! /usr/bin/env bash

require 'lib/bashum/cli/console.sh'
require 'lib/bashum/lang/fail.sh'
require 'lib/bashum/cli/options.sh'
require 'lib/bashum/remote.sh'

remote_remove_usage() {
	echo "$bashum_cmd remote remove <url> [options]"
}

remote_remove_help() {
	bold 'USAGE'
	echo 
	printf "\t"; remote_remove_usage
	echo


	bold 'DESCRIPTION'
	printf '%s' '
	Removes a remote repository from the list of repos to include
	when searching and installing.

'

	bold 'OPTIONS'
	printf '%s' '
	-None
'
}

remote_remove() {
	if options_is_help "$@" 
	then
		remote_remove_help "$@"
		exit $?
	fi

	if (( $# != 1 ))
	then
		error "Must provide a repo url"
		echo 

		echo -n 'USAGE: '; remote_remove_usage 
		exit 1
	fi

	info "Removing url: $1"

	read -p "Are you sure? (y|n): " answer
	if [[ "$answer" != "y" ]]
	then
		echo "Aborting."
		exit 0
	fi

	remote_repo_urls_remove $1
}
