#! /usr/bin/env bash

export bashum_home=${bashum_home:-$HOME/.bashum}

require 'lib/console.sh'
require 'lib/fail.sh'
require 'lib/help.sh'
require 'lib/project_file.sh'
require 'lib/package.sh'

remove_usage() {
	echo "$bashum_cmd remove <package> [options]"
}

remove_help() {
	bold 'USAGE'
	echo 
	printf "\t"; remove_usage
	echo


	bold 'DESCRIPTION'
	printf '%s' '
	Removes the specified bashum package from the local repo.

	This may require resourcing the environment if the specfied
	package contained 'sourced' environment files.

'

	bold 'OPTIONS'
	printf '%s' '
	-None 

'
}

remove() {
	if help? "$@" 
	then
		remove_help "$@"
		exit $?
	fi

	if [[ -z "$1" ]]
	then
		error "Must provide a package name."
		echo 

		echo -n 'USAGE: '; remove_usage 
		exit 1
	fi

	local package_home=$(package_get_home "$1")
	if [[ ! -d "$package_home" ]]
	then
		error "That package [$package_home] is not installed"
		exit 1
	fi

	info "Removing package: $1"

	read -p "Are you sure? (y|n): " answer
	if [[ "$answer" != "y" ]]
	then
		echo "Aborting."
		exit 0
	fi

	package_remove_executables "$1"
	if ! rm -r $package_home
	then
		error "Error deleting package: $package_home"
		exit 1
	fi

	info "Successfully removed: $1"
	echo
}
