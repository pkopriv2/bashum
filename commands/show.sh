#! /usr/bin/env bash

export bashum_home=${bashum_home:-$HOME/.bashum}
export bashum_tmp_dir=${bashum_tmp_dir:-/tmp/bashum/}

require 'lib/error.sh'
require 'lib/string.sh'
require 'lib/info.sh'
require 'lib/font.sh'
require 'lib/fail.sh'
require 'lib/help.sh'
require 'lib/package.sh'
require 'lib/project_file.sh'
require 'lib/bashum_file.sh'

show_usage() {
	echo "$bashum_cmd show <package> [options]"
}

show_help() {
	bold 'USAGE'
	echo
	printf "\t"; show_usage
	echo


	bold 'DESCRIPTION'
	printf '%s' '
	Shows a detailed view of the specified package. The package
	may be a raw bashum file, an installed bashum, or the url of
	a remote bashum file.

'

	bold 'OPTIONS'
	printf '%s' '
	-None

'
}


# Usage: install <package>
#
# Installs or updates a package
#
show() {
	if help? "$@" 
	then
		show_help "$@"
		exit $?
	fi

	if ! command -v tar &> /dev/null
	then
		error "Installation requires a working version of tar." 
		exit 1
	fi

	if [[ -z "$1" ]]
	then
		error "Must provide a package name."
		echo 

		echo -n 'USAGE: '; show_usage 
		exit 1
	fi

	local arg=$1

	# see if the input is a local file (ie a .bashum)
	if [[ -f "$arg" ]]
	then
		local project_file=$(bashum_file_extract_project_file $arg)
		project_file_print "$project_file"
		exit 0
	fi

	# see if the input is a package name
	local package_home=$(package_get_home "$arg")
	if [[ -d $package_home ]] 
	then
		local project_file=$package_home/project.sh
		project_file_print "$project_file"
		exit 0
	fi

	# okay, see if it's a url
	if ! echo $arg | grep -q '^http' 
	then
		error "Invalid input.  Must be either a .bashum file, a package name, or the remote url of a bashum file. "
		echo 

		echo -n 'USAGE: '; show_usage 
		exit 1
	fi

	local bashum_file=$bashum_tmp_dir/$(str_random)
	bashum_file_download "$arg" "$bashum_file" &> /dev/null 
	
	local project_file=$(bashum_file_extract_project_file "$bashum_file")
	project_file_print "$project_file"
}

is_local?() {
	if [[ -f "$1" ]]
	then
		return 0
	fi

	if echo $1 | grep -q '^http'
	then
		return 1
	fi

	error "Package [$1] is not a local package and is not a url."
	exit 1
}
