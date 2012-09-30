#! /usr/bin/env bash

export bashum_home=${bashum_home:-$HOME/.bashum}
export bashums_home=${bashums_home:-$bashum_home/bashums}
export bashum_bin_dir=${bashum_bin_dir:-$bashum_home/bin}

require 'lib/error.sh'
require 'lib/info.sh'
require 'lib/fail.sh'
require 'lib/project.sh'

uninstall_help() {
	echo;
}

uninstall() {
	if [[ -z "$1" ]]
	then
		error "Must provide a package name."
		exit 1
	fi

	local package_home=$(project_get_home "$1")
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

	project_remove_executables "$1"
	rm -r $package_home

	info "Successfully uninstalled: $1"
	echo
}
