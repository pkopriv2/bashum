#! /usr/bin/env bash

require 'lib/console.sh'
require 'lib/fail.sh'

declare bashum_project_file_loaded

project_file_api() {
	name() {
		:
	}

	version() {
		:
	}

	author() {
		:
	}

	email() {
		:
	}

	description() {
		:
	}

	file() {
		:
	}

	depends() {
		:
	}
}

project_file_api_unset() {
	unset -f name
	unset -f version
	unset -f author 
	unset -f email 
	unset -f description
	unset -f file
	unset -f depends
}

# loads the given project file into the current shell
# environment.
project_file_load() {
	if [[ -z "$1" ]]
	then
		fail 'Must provide a project file.'
	fi

	if [[  ! -f "$1" ]]
	then
		fail "Input [$1] is not a file."
	fi

	if [[ "$bashum_project_file_loaded" == "$1" ]]
	then
		return 0 # already loaded
	fi

	name=""
	name() {
		if (( $# != 1 ))
		then
			fail "Usage: name <name>"
		fi

		name=$1
	}

	version=""
	version() {
		if (( $# != 1 ))
		then
			fail "Usage: version <version>"
		fi

		version=$1
	}

	author=""
	author() {
		if (( $# != 1 ))
		then
			fail "Usage: author <author>"
		fi

		author=$1
	}

	email=""
	email() {
		if (( $# != 1 ))
		then
			fail "Usage: email <email>"
		fi

		email=$1
	}

	description=""
	description() {
		if (( $# != 1 ))
		then
			fail "Usage: description <description>"
		fi

		description=$1
	}

	file_globs=()
	file() {
		if (( $# != 1 ))
		then
			fail "Usage: file <glob>"
		fi

		file_globs+=( "$1" )
	}

	dependencies=()
	depends() {
		if (( $# < 1 )) || (( $# > 2 )) 
		then
			fail "Usage: depends <project> [<version>]"
		fi

		if [[ -z $1 ]]
		then
			fail "Must provide at least a name"

		fi
		
		dependencies+=( "$1:$2" )
	}

	source $1
	bashum_project_file_loaded=$1 

	# ensure that everything was set appropriately
	if [[ -z "$name" ]]
	then
		error "Project file [$1] must provide a valid project name."
		exit 1
	fi

	if [[ -z "$version" ]]
	then
		error "Project file [$1] must provide a valid project version."
		exit 1
	fi

	unset -f name
	unset -f version
	unset -f author 
	unset -f email 
	unset -f description
	unset -f file
	unset -f depends
}

project_file_print() {
	if [[ -z "$1" ]]
	then
		fail 'Must provide a project file.'
	fi

	if [[  ! -f "$1" ]]
	then
		fail "Project file [$1] does not exist"
	fi

	project_file_load "$1"

	info "Name:"
	echo "    - $name" 
	echo

	info "Version:" 
	echo "    - $version"
	echo

	if [[ ! -z $author ]]
	then
		info "Author:"
		echo "    - $author"
		echo
	fi

	if [[ ! -z $email ]]
	then
		info "Email:"
		echo "    - $email"
		echo
	fi

	if [[ ! -z $description ]]
	then
		info "Description:"
		echo "    - $description"
		echo
	fi

	if (( "${#file_globs}" > 0 ))
	then
		info "Files:"
		declare local glob
		for glob in "${file_globs[@]}"
		do
			echo "    - $glob"
		done
		echo
	fi

	if (( "${#dependencies}" > 0 ))
	then
		info "Dependencies:"
		declare local dep
		for dep in "${dependencies[@]}"
		do
			local dep_name=${dep%%:*}
			local dep_version=${dep##*:}
			echo "    - $dep_name${dep_version:+":$dep_version"}"
		done
	fi
}
