#! /usr/bin/env bash

require 'lib/error.sh'
require 'lib/info.sh'
require 'lib/fail.sh'

declare bashum_project_file_loaded

# loads the given project file into the current shell
# environment.
project_file_load() {
	if [[ -z "$1" ]]
	then
		fail 'Must provide a project file.'
	fi

	if [[  ! -f "$1" ]]
	then
		fail "Project file [$1] does not exist"
	fi

	if [[ "$bashum_project_file_loaded" == "$1" ]]
	then
		return 0 # already loaded
	fi

	name=""
	name() {
		name=$1
	}

	version=""
	version() {
		version=$1
	}

	author=""
	author() {
		author=$1
	}

	email=""
	email() {
		email=$1
	}

	description=""
	description() {
		description=$1
	}

	file_globs=()
	file() {
		file_globs+=( "$1" )
	}

	dependencies=()
	depends() {
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

#
#
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

project_file_validate_dependencies() {
	if [[ -z "$1" ]]
	then
		fail 'Must provide a project file.'
	fi

	# load the project file.
	project_file_load $1

	# ensure each dependency is satisfied.
	local orig_name=$name
	local orig_version=$version


	declare local dep 
	for dep in "${dependencies[@]}"
	do
		local dep_name=${dep%%:*}
		local dep_version_expected=${dep##*:}

		local dep_home=$(package_get_home "$dep_name")
		if [[ ! -d $dep_home ]]
		then
			error "Missing dependency: $dep_name${dep_version_expected:+":$dep_version_expected"}"
			exit 1
		fi

		if [[ -z $dep_version_expected ]]
		then
			continue
		fi

		local dep_project_file=$dep_home/project.sh
		(
			project_load_file "$dep_project_file"
			if [[ "$version" < "$dep_version_expected" ]]
			then
				error "Required version [$dep_version_expected] of [$dep_name] not found.  Currently, version [$version] is installed." 
				exit 1
			fi
		) || exit 1
	done

}
