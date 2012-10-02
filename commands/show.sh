#! /usr/bin/env bash

export bashum_home=${bashum_home:-$HOME/.bashum}
export bashum_tmp_dir=${bashum_tmp_dir:-/tmp/bashum/}

require 'lib/console.sh'
require 'lib/download.sh'
require 'lib/string.sh'
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

	# see if the input is a url
	if echo $arg | grep -q '^http' 
	then
		local bashum_file=$bashum_tmp_dir/$(str_random)
		download "$arg" "$bashum_file"
		local arg=$bashum_file
		echo 
	fi

	# see if the input is a local file (ie a .bashum)
	if [[ -f "$arg" ]]
	then
		local project_file=$(bashum_file_extract_project_file "$arg")
		local executables=( $(bashum_file_get_executables "$arg") )
		local libs=( $(bashum_file_get_libs "$arg") )

	# see if the input is an installed package
	elif [[ -d "$bashum_repo/packages/$arg" ]]
	then
		local project_file=$bashum_repo/packages/"$arg"/project.sh
		local executables=( $(package_get_executables "$arg") )
		local libs=( $(package_get_libs "$arg") )
	
	# welp, nothing we can do. 
	else
		error "Invalid input.  Must be either a .bashum file, a package name, or the remote url of a bashum file. "
		echo 

		echo -n 'USAGE: '; show_usage 
		exit 1
	fi

	# print the project file.
	project_file_print "$project_file"
	echo 

	# print the executables
	if (( ${#executables[@]} > 0 ))
	then
		info "Executables: " 
		declare local file
		for file in "${executables[@]}" 
		do
			echo "    - $(basename $file)"
		done
		echo 
	fi

	# print the library files
	if (( ${#libs[@]} > 0 ))
	then
		info "Libraries: " 
		declare local file
		for file in "${libs[@]}" 
		do
			echo "    - lib/$(basename $file)"
		done
		echo 
	fi
}
