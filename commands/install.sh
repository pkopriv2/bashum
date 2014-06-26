#! /usr/bin/env bash

require 'lib/bashum/install.sh'

require 'lib/bashum/cli/console.sh'
require 'lib/bashum/cli/options.sh'

require 'lib/bashum/lang/fail.sh'


install_usage() {
	echo "$bashum_cmd install [<package>|<file>|<url>] [option]*"
}

install_help() {
	bold 'USAGE'
	echo 
	printf "\t"; install_usage
	echo


	bold 'DESCRIPTION'
	printf '%s' '
	Installs the specified package.  The package may be a raw bashum
	file, a url to a bashum file, or the name (and optional version) 
	of a package hosted in a remote repository. 

	If this is invoked at the root of a project with no arguments, 
	the project will be built and installed. 

	Dependencies will be automatically detected and installed from
	the list of remote repositories.  

	For the complete list of repositories that will be searched, 
	use the command:
	  
	    bashum remote list

'

	bold 'OPTIONS'
	printf '%s' '
	-v|--version    The version of the package to install, if installing 
	                from a remote repository.

'
}

install() {
	usage() {
		bold 'USAGE'

		echo 
		printf "\t"; install_usage
		echo
	}

	if options_is_help "$@" 
	then
		install_help "$@"
		exit $?
	fi

	if (( $# == 0 )) 
	then
		install_from_project $(pwd)

		info "Successfully installed package from project."
		return 0
	fi

	if is_url $1
	then
		install_from_url $1

		info "Successfully installed package from url [$1]"
		return 0
	fi

	if [[ -f $1 ]]
	then
		install_from_file $1

		info "Successfully installed package from file [$1]"
		return 0
	fi

	local package=$1; shift
	while (( $# > 0 ))
	do
		case "$1" in
			--version)
				shift
				local version=$1
				;;
			-*)
				error "That option [$1] is not allowed"
				usage
				exit 1
				;;
			*)
				error "Positional arguments [$1] are not allowed after options"
				usage
				exit 1
		esac 
		shift
	done

	install_from_remote $package $version
	info "Successfully installed package from remote repo [$package${version:+:$version}]"
}

# usage: is_url <expression>
is_url() {
	if (( $# != 1 ))
	then
		fail 'usage: is_url <expression>'
	fi

	echo $1 | grep -q '^http'; return $?
}
