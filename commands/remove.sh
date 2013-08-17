#! /usr/bin/env bash

export bashum_home=${bashum_home:-$HOME/.bashum}

require 'lib/bashum/cli/console.sh'
require 'lib/bashum/lang/fail.sh'
require 'lib/bashum/cli/options.sh'
require 'lib/bashum/project_file.sh'
require 'lib/bashum/package.sh'

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
	if options_is_help "$@" 
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

	if ! package_is_installed $1 
	then
		error "That package [$1] is not installed"
		exit 1
	fi

	info "Removing package: $1"

	read -p "Are you sure? (y|n): " answer
	if [[ "$answer" != "y" ]]
	then
		echo "Aborting."
		exit 0
	fi

	# TODO: Enhance to remove unneeded dependencies.

	local dependers=( $(package_get_dependers "$1") )
	if (( ${#dependers[@]} > 0 ))
	then
		error "Cannot remove package [$1]. It is depended upon by: ( ${dependers[@]} )"
		exit 1
	fi

	package_remove $1
	info "Successfully removed: $1"
}
