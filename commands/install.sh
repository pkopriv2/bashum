#! /usr/bin/env bash

export bashum_home=${bashum_home:-$HOME/.bashum}
export bashums_home=${bashums_home:-$bashum_home/bashums}
export bashum_bin_dir=${bashum_bin_dir:-$bashum_home/bin}
export bashum_tmp_dir=${bashum_tmp_dir:-/tmp/bashum/}

require 'lib/error.sh'
require 'lib/string.sh'
require 'lib/info.sh'
require 'lib/fail.sh'
require 'lib/package.sh'
require 'lib/project.sh'

if [[ -d $bashum_tmp_dir ]] 
then
	rm -r $bashum_tmp_dir
fi
mkdir -p $bashum_tmp_dir

on_exit() {
	rm -r $bashum_tmp_dir
}; trap "on_exit" INT EXIT

install_help() {
	echo;
}


# Usage: install <package>
#
# Installs or updates a package
#
install() {
	if ! command -v tar &> /dev/null
	then
		error "Installation requires a working version of tar." 
		exit 1
	fi

	if [[ -z "$1" ]]
	then
		error "Must provide either a package name or url."
		exit 1
	fi

	local file="$1"
	if ! is_local? "$file" 
	then
		local file=$bashum_tmp_dir/$(str_random) 
		package_download "$1" "$file"
	fi

	if [[ ! -f "$file" ]]
	then
		error "That package [$file] doesn't exist."
		exit 1
	fi

	package_validate "$file"
	info "Installing package: $name"

	#local project_home=$(project_get_home "$name")
	#if [[ -d $project_home ]] 
	#then
		#rm -r $project_home
	#fi

	tar -xf "$file" -C $bashums_home

	project_generate_executables "$name"
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
