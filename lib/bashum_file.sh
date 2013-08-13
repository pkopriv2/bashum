#! /usr/bin/env bash

require 'lib/console.sh'
require 'lib/package.sh'
require 'lib/string.sh'

if ! command -v tar &> /dev/null
then
	fail "Installation requires a working version of tar." 
fi

# usage: bashum_file_extract_project_file <file>
bashum_file_extract_project_file() {
	if (( $# != 1 ))
	then
		fail 'usage: bashum_file_extract_project_file <file>'
	fi

	# locate the required <name>/project_file.sh
	local project_file=$(tar -tf $1 | grep '^[^/]*/project.sh')
	if [[ -z $project_file ]]
	then
		fail "Package [$1] is missing a project.sh file."
	fi

	# make a tmp directory
	local output_dir=$bashum_tmp_dir/$1_$(str_random)
	if ! mkdir -p $output_dir
	then
		fail "Error making output directory [$output_dir]"
	fi

	# extract the project file (to temp location)
	if ! tar -C $output_dir -xvf "$1" "$project_file" &> /dev/null
	then
		fail "That package [$1] is corrupted"
	fi

	# finally, echo the location to the file. 
	echo "$output_dir/$project_file" 
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

# usage: bashum_file_is_installable <file>
bashum_file_is_installable() {
	if (( $# != 1 ))
	then
		fail 'usage: bashum_file_is_installable <file>'
	fi

	declare local project_file
	if ! project_file=$(bashum_file_extract_project_file $1) 
	then
		return 1
	fi

	# ensure that the structure is expected.
	local name=$(project_file_get_name $project_file)
	for file in $(tar -tf $1) 
	do
		if ! echo "$file" | grep -q "^$name"
		then
			echo "That bashum [$1] is corrupted.  Unexpected file: $file" 1>&2
			return 1
		fi
	done
}
