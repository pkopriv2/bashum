#! /usr/bin/env bash

require 'lib/bashum/cli/console.sh'
require 'lib/bashum/cli/options.sh'
require 'lib/bashum/lang/string.sh'
require 'lib/bashum/lang/fail.sh'
require 'lib/bashum/util/download.sh'
require 'lib/bashum/util/tmp.sh'

require 'lib/bashum/archive.sh'
require 'lib/bashum/package.sh'
require 'lib/bashum/project_file.sh'

export bashum_home=${bashum_home:-$HOME/.bashum}

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
	if options_is_help "$@" 
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
		local archive=$bashum_tmp_dir/$(str_random)
		download "$arg" "$archive"
		local arg=$archive
		echo 
	fi

	# see if the input is a local file (ie a .bashum)
	if [[ -f "$arg" ]]
	then
		local project_file=$(archive_extract_project_file "$arg")
		local executables=( $(archive_get_executables "$arg") )
		local libs=( $(archive_get_libs "$arg") )

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
}
