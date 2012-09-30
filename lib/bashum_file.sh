#! /usr/bin/env bash

require 'lib/error.sh'
require 'lib/info.sh'
require 'lib/fail.sh'

# download_package <url> <target> 
bashum_file_download() {
	if (( $# < 2 ))
	then
		fail "Must provide both a url and target"
	fi

	info "Downloading bashum file: $1 to: $2"

	if command -v curl &> /dev/null
	then
		if ! curl -L $1 > $2
		then
			error "Error downloading: $1.  Either cannot download or cannot write to file: $2"
			exit 1
		fi

	elif command -v wget &> /dev/null
	then
		if ! wget -q -O $2 $1
		then
			error "Error downloading: $1.  Either cannot download or cannot write to file: $2"
			exit 1
		fi

	else
		error "This installation requires either curl or wget."
		exit 1
	fi
}

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

# Validates the contents of a pacakge.
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
			error "That package [$1] is corrupted.  Unexpected file: $file"
			exit 1
		fi
	done

	# validate the dependencies.
	project_file_validate_dependencies $project_file
}
