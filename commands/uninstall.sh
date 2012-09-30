#! /usr/bin/env bash

export bashum_home=${bashum_home:-$HOME/.bashum}
export bashums_home=${bashums_home:-$bashum_home/bashums}
export bashum_bin_dir=${bashum_bin_dir:-$bashum_home/bin}

require 'lib/error.sh'
require 'lib/font.sh'
require 'lib/info.sh'
require 'lib/fail.sh'
require 'lib/help.sh'
require 'lib/project_file.sh'
require 'lib/package.sh'

uninstall_usage() {
	echo "$bashum_cmd uninstall <package> [options]"
}

uninstall_help() {
	bold 'USAGE'
	echo 
	printf "\t"; uninstall_usage
	echo


	bold 'DESCRIPTION'
	printf '%s' '
	Uninstalls the specified bashum package from the local repo.

	This may require resourcing the environment if the specfied
	package contained 'sourced' environment files.

'

	bold 'OPTIONS'
	printf '%s' '
	-None 

'
}

uninstall() {
	if help? "$@" 
	then
		uninstall_help "$@"
		exit $?
	fi

	if [[ -z "$1" ]]
	then
		error "Must provide a package name."
		echo 

		echo -n 'USAGE: '; uninstall_usage 
		exit 1
	fi

	local package_home=$(package_get_home "$1")
	if [[ ! -d "$package_home" ]]
	then
		error "That package [$package_home] is not installed"
		exit 1
	fi

	info "Uninstalling: $1"

	read -p "Are you sure? (y|n): " answer
	if [[ "$answer" != "y" ]]
	then
		echo "Aborting."
		exit 0
	fi

	package_remove_executables "$1"
	rm -r $package_home

	info "Successfully uninstalled: $1"
	echo
}
