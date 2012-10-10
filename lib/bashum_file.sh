#! /usr/bin/env bash

require 'lib/console.sh'
require 'lib/package.sh'

bashum_file_extract_project_file() {
	# locate the required <name>/project_file.sh
	local project_file=$(tar -tf $1 | grep '^[^/]*/project.sh')
	if [[ -z $project_file ]]
	then
		error "Package [$1] is missing a project.sh file."
		exit 1
	fi

	# extract the project file (to temp location)
	if ! tar -C $bashum_tmp_dir -xvf "$1" "$project_file" &> /dev/null
	then
		error "That package [$1] is corrupted"
		exit 1
	fi

	# finally, echo the location to the file. 
	echo "$bashum_tmp_dir/$project_file" 
}

bashum_file_get_executables() {
	if [[ -z $1 ]]
	then
		error 'Must provide a bashum file'
		exit 1
	fi

	local bashum_file=$1
	if [[ ! -f $bashum_file ]] 
	then
		error "That bashum file [$bashum_file] doesn't exist"
		exit 1
	fi
	
	tar -tf $bashum_file | grep '^[^/]*/bin/[^/]\+$' 
}

bashum_file_get_libs() {
	if [[ -z $1 ]]
	then
		error 'Must provide a bashum file'
		exit 1
	fi

	local bashum_file=$1
	if [[ ! -f "$bashum_file" ]] 
	then
		error "That bashum file [$bashum_file] doesn't exist"
		exit 1
	fi
	
	tar -tf $bashum_file | grep '^[^/]*/lib/.' 
}

bashum_file_validate() {
	# package_info
	local project_file=$(bashum_file_extract_project_file $1) 

	# load the project file.
	project_file_load $project_file

	# ensure that the structure is expected.
	declare local file
	for file in $(tar -tf $1) 
	do
		if ! echo "$file" | grep -q "^$name"
		then
			error "That bashum [$1] is corrupted.  Unexpected file: $file"
			exit 1
		fi
	done

	# validate the dependencies
	declare local dependency
	for dependency in "${dependencies[@]}"
	do 
		local dep_name=${dependency%%:*}
		local dep_version=${dependency##*:}

		if ! package_is_installed $dep_name $dep_version
		then
			error "Missing dependency: [$dep_name${dep_version:+:$dep_version}]"
			exit 1
		fi
	done
}
