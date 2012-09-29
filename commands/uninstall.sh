#! /usr/bin/env bash

export bashum_home=${bashum_home:-$HOME/.bashum}
export bashums_home=${bashums_home:-$bashum_home/bashums}
export bashum_bin_dir=${bashum_bin_dir:-$bashum_home/bin}

require 'lib/error.sh'
require 'lib/info.sh'
require 'lib/fail.sh'
require 'lib/package.sh'

uninstall_help() {
	echo;
}

uninstall() {
	if [[ -z "$1" ]]
	then
		error "Must provide a package name."
		exit 1
	fi

	local package_home="$bashums_home/$1"
	if [[ ! -d "$package_home" ]]
	then
		error "That package [$package_home] is not installed"
		exit 1
	fi

	info "Uninstalling: $1"

	read -p "Are you sure? (y|n)" answer
	if [[ "$answer" != "y" ]]
	then
		echo "Aborting."
		exit 0
	fi

	# clean out all the wrapper executables
	for executable in $(package_get_executables $1) 
	do
		# grab the executable package_name
		local base_name=$(basename $executable) 
		local wrapper=$bashum_bin_dir/$base_name
		if [[ ! -f $wrapper ]]
		then
			continue
		fi 

		echo "Removing executable: $base_name"
		rm $wrapper
	done

	# finally, delete the package directory
	echo "Removing package directory: $package_home"
	rm -r $package_home

	echo "Done."
	echo
}
