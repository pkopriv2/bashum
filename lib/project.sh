#! /usr/bin/env bash

require 'lib/error.sh'
require 'lib/info.sh'
require 'lib/fail.sh'

# loads the given project file into the current shell
# environment.
project_load_file() {
	if [[ -z "$1" ]]
	then
		fail 'Must provide a project file.'
	fi

	if [[  ! -f "$1" ]]
	then
		fail "Project file [$1] does not exist"
	fi

	name=""
	name() {
		name=$1
	}

	version=""
	version() {
		version=$1
	}

	description=""
	description() {
		description=$1
	}

	source $1

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
	unset -f description
}

project_get_home() {
	echo "$bashums_home/$1"
}

project_get_executables() {
	if [[ -z $1 ]]
	then
		fail 'Must provide a package.'
	fi

	local project_home=$(project_get_home "$1")
	if [[ ! -d $project_home ]] 
	then
		error "Package [$1] is not installed."
		exit 1
	fi

	local bin_dir=$project_home/bin
	if [[ ! -d $bin_dir ]] 
	then
		return 0 
	fi

	for executable in $(ls $bin_dir/*) 
	do
		if [[ ! -f $executable ]]
		then
			continue
		fi

		echo $executable
	done
}

project_generate_executables() {
	if [[ -z $1 ]]
	then
		fail 'Must provide a package name'
	fi

	local name="$1"
	for executable in $(project_get_executables "$name" ) 
	do
		# grab the executable name
		local base_name=$(basename $executable) 
		echo "creating bashum executable: $base_name"

		# update the file permissions
		chmod a+x $executable

		# determine where we're going to put the executable
		local out=$bashum_bin_dir/$base_name
		if [[ -f $out ]]
		then
			echo "executable [$out] already exists.  removing."
			rm $out
		fi 

		# create the new executable
		cat - > $out <<-eof
			#! /usr/bin/env bash
			export bashum_home=\${bashum_home:-\$HOME/.bashum}
			export bashums_home=\${bashums_home:-\$bashum_home/bashums}

			# source our standard 'require' funciton.
			source \$bashum_home/lib/require.sh

			# update the bashums path to include the /lib folder of this bashum
			export bashums_path=\$bashums_home/$name:\$bashums_path

			# go ahead and execute the original executable
			source \$bashums_home/$name/bin/$base_name
		eof

		# make it executable. bam!
		chmod a+x $out
	done
}
