#! /usr/bin/env bash

export bashum_home=${bashum_home:-$HOME/.bashum}
export bashum_repo=${bashum_repo:-$HOME/.bashum_repo}
export bashum_tmp_dir=${bashum_tmp_dir:-/tmp/bashum/}

require 'lib/console.sh'
require 'lib/string.sh'
require 'lib/fail.sh'
require 'lib/help.sh'
require 'lib/package.sh'
require 'lib/project_file.sh'
require 'lib/bashum_file.sh'
require 'lib/download.sh'

if ! command -v git &> /dev/null
then
	fail "git cannot be found."
fi

install_usage() {
	echo "$bashum_cmd install <package> [options]"
}

install_help() {
	bold 'USAGE'
	echo 
	printf "\t"; install_usage
	echo


	bold 'DESCRIPTION'
	printf '%s' '
	Validates and installs the the specified bashum file to the local
	bashum repo ($bashum_repo).  In order to pass validation,
	the bashum file must have the proper strucutre as described by
	its project.sh file and all the dependencies must be satisfied.

	Note: <package> can be a local file or a url.  

'

	bold 'OPTIONS'
	printf '%s' '
	-None 

'
}

install() {
	if help? "$@" 
	then
		install_help "$@"
		exit $?
	fi

	if ! command -v tar &> /dev/null
	then
		error "Installation requires a working version of tar." 
		exit 1
	fi

	if [[ -z "$1" ]]
	then
		error "Must provide either a package name or url."
		echo 

		echo -n 'USAGE: '; install_usage 
		exit 1
	fi

	local bashum_file="$1"
	if ! is_local? "$bashum_file" 
	then
		local bashum_file=$bashum_tmp_dir/$(str_random) 
		download "$1" "$bashum_file"
	fi

	if [[ ! -f "$bashum_file" ]]
	then
		error "That package [$bashum_file] doesn't exist."
		exit 1
	else
		git clone ... $bashum_repo
	fi

	info "Installing bashum file: $bashum_file"
	echo 

	local project_file=$(bashum_file_extract_project_file "$bashum_file")
	project_file_print "$project_file"
	echo

	echo -n "Validating bashum file. "
	bashum_file_validate "$bashum_file"
	echo "Done."

	local package_home=$(package_get_home "$name")
	if [[ -d $package_home ]]
	then
		echo -n "Removing old executables. "
		package_remove_executables "$name"
		echo "Done."

		echo -n "Removing old package. "
		if ! rm -r $package_home 
		then
			error "Error removing old package: $package_home"
			exit 1
		fi
		echo "Done."
	fi

	echo -n "Unpacking bashum file. "
	tar -xf "$bashum_file" -C $bashum_repo/packages 
	echo "Done."

	echo -n "Generating executables. " 
	package_generate_executables "$name"
	echo "Done."
	echo

	info "Successfully installed package: $name" 
	info "Please re-source your environment (open a new terminal session)." 
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
