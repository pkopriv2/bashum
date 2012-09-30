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

package_help() {
	echo
}


package_uninstall() {
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

# Lists all the currently installed packages.
#
#
package_list() {
	local detailed=false
	while [[ $# -gt 0 ]]
	do
		arg="$1"

		case "$arg" in
			-d|--detailed)
				detailed=true
				;;
		esac
		shift
	done
	
	info "** Currently installed bashums **"
	echo


	for project_file in $(ls $bashums_home/*/project.sh)
	do
		project_load_file $project_file
		echo -n "  - $name [$version]"

		if [[ -n $description ]] && $detailed
		then
			echo " - $description"
		else 
			echo
		fi
	done
}

package_info() {
	echo
}

# Installs either a local or remote package.
#
#
package_install() {
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
	if ! _is_local? "$file" 
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

_is_local?() {
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

package() {
	args=( "${@}" )
	action="${args[0]}"
	unset args[0]

	case "$action" in
		list|install|uninstall|info)
			package_$action "${args[@]}"
			;;
		*)
			package_help
			exit 1
			;;
	esac
}

