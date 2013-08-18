#! /usr/bin/env bash

require 'lib/bashum/project_file.sh'
require 'lib/bashum/cli/console.sh'
require 'lib/bashum/lang/fail.sh'

export bashum_repo=${bashum_repo:-$HOME/.bashum_repo}

[[ -d $bashum_repo ]]          || mkdir -p $bashum_repo
[[ -d $bashum_repo/packages ]] || mkdir -p $bashum_repo/packages
[[ -d $bashum_repo/bin ]]      || mkdir -p $bashum_repo/bin

# usage: package_repo_get_package_root
repo_get_package_root() {
	if (( $# != 0 ))
	then
		fail 'usage: package_get_root'
	fi

	echo $bashum_repo/packages
}

# usage: package_repo_get_bin_root
repo_get_bin_root() {
	if (( $# != 0 ))
	then
		fail 'usage: package_repo_get_bin_root'
	fi

	echo $bashum_repo/bin
}

# usage: package_get_all
repo_package_get_all() {
	if (( $# != 0 ))
	then
		fail 'usage: package_get_all'
	fi

	local dirs=( $( builtin cd $bashum_repo/packages; find $(pwd) -mindepth 1 -maxdepth 1 -type d ) )
	for dir in "${dirs[@]}"
	do
		echo $(basename $dir)
	done
}

# usage: repo_package_get_home <name>
repo_package_get_home() {
	if (( $# != 1 ))
	then
		fail 'usage: repo_package_get_home <name>'
	fi

	if [[ -z $1 ]]
	then
		fail 'Must provide a project name.'
	fi

	echo "$(repo_get_package_root)/$1"
}

# usage: repo_package_get_project_file <name>
repo_package_get_project_file() {
	if (( $# != 1 ))
	then
		fail 'usage: repo_package_get_home <name>'
	fi

	echo "$(repo_package_get_home $1)/project.sh"
}

# usage: repo_package_is_installed <name> [<version>]
repo_package_is_installed() {
	if (( $# < 1 )) || (( $# > 2 ))
	then
		fail 'Usage: repo_package_is_installed <name>'
	fi
	
	local package_home=$(repo_package_get_home $1)
	if [[ ! -d $package_home ]] 
	then
		return 1
	fi

	# no version was given
	if (( $# == 1 )) 
	then
		return 0
	fi

	# determine if an acceptable version is installed.
	local project_file=$package_home/project.sh
	if [[ ! -f $project_file ]]
	then
		fail "Package [$1] is missing a project file."
	fi

	project_file_api
	local version=""
	version() {
		if (( $# != 1 ))
		then
			fail "Usage: version <version>"
		fi

		version=$1 
	}

	source $project_file 
	project_file_api_unset

	# if the version of this project is greater than what was passed in,
	# then return true. 
	[[ "$version" > "$2" ]] || [[ "$version" == "$2" ]]; return $?
}

# usage: repo_package_get_dependers <name>
repo_package_get_dependers() {
	if (( $# != 1 ))
	then
		fail 'usage: repo_package_get_dependers <name>'
	fi

	local package_home=$(repo_package_get_home $1)
	if [[ ! -d $package_home ]]
	then
		fail "Package [$1] is not installed."
	fi
	
	local project_file=$package_home/project.sh
	if [[ ! -f $project_file ]]
	then
		fail "Package [$1] is missing a project file."
	fi

	local name=$(project_file_get_name $project_file) 

	(
		# iterate over *all* other projects looking for those 
		# who depend on this. 
		declare local cur_project_file
		for cur_project_file in $(ls $bashum_repo/packages/*/project.sh 2>/dev/null)
		do
			project_file_api

			local cur_project_name=""
			name() {
				if (( $# != 1 ))  
				then
					fail "Usage: name <name>"
				fi

				cur_project_name=$1
			}

			local cur_project_dependencies=()
			depends() {
				if (( $# < 1 )) || (( $# > 2 )) 
				then
					fail "Usage: depends <project> [<version>]"
				fi

				cur_project_dependencies+=( $1 )
			}

			source $cur_project_file

			if [[ -z $name ]]
			then
				fail "Project file [$cur_project_file] must include a name." 
			fi

			declare local cur_project_dependency
			for cur_project_dependency in "${cur_project_dependencies[@]}"
			do
				if [[ $cur_project_dependency == $name ]]
				then
					echo $cur_project_name
				fi
			done

			project_file_api_unset
		done
	) || exit 1 
}

# usage: repo_package_get_executables <name>
repo_package_get_executables() {
	if [[ -z $1 ]]
	then
		fail 'Must provide a project name.'
	fi

	local package_home=$(repo_package_get_home "$1")
	if [[ ! -d $package_home ]] 
	then
		error "Package [$1] is not installed."
		exit 1
	fi

	local bin_dir=$package_home/bin
	if [[ ! -d $bin_dir ]] 
	then
		return 0 
	fi

	for executable in $(ls $bin_dir/*) 
	do
		if [[ -f $executable ]]
		then
			echo $executable
		fi
	done
}

repo_package_get_libs() {
	if [[ -z $1 ]]
	then
		fail 'Must provide a project name.'
	fi

	local package_home=$(repo_package_get_home "$1")
	if [[ ! -d $package_home ]] 
	then
		error "Package [$1] is not installed."
		exit 1
	fi

	local lib_dir=$package_home/lib
	if [[ ! -d $lib_dir ]] 
	then
		return 0 
	fi

	find $lib_dir -name '*.sh' 
}

repo_package_generate_executables() {
	if [[ -z $1 ]]
	then
		fail 'Must provide a project name'
	fi

	local name="$1"
	for executable in $(repo_package_get_executables "$name" ) 
	do
		# grab the executable name
		local base_name=$(basename $executable) 

		# update the file permissions
		chmod a+x $executable

		# determine where we're going to put the executable
		local out=$bashum_repo/bin/$base_name
		if [[ -f $out ]]
		then
			rm $out
		fi 

		# create the new executable
		cat - > $out <<-eof
			#! /usr/bin/env bash
			export bashum_home=\${bashum_home:-\$HOME/.bashum}
			export bashum_repo=\${bashum_repo:-\$HOME/.bashum_repo}
			export project_root=\$bashum_repo/packages/$name

			# source our standard 'require' funciton.
			source \$bashum_home/lib/require.sh

			# update the bashum path to include this package
			export bashum_path=\$project_root:\$bashum_path

			# go ahead and execute the original executable
			source \$project_root/bin/$base_name "\$@"
		eof

		# make it executable. bam!
		chmod a+x $out
	done
}

repo_repo_package_remove_executables() {
	if [[ -z $1 ]]
	then
		fail 'Must provide a package name'
	fi

	local name="$1"
	for executable in $(repo_package_get_executables "$name" ) 
	do
		# grab the executable package_name 
		local base_name=$(basename $executable) 

		# derive where the bashum wrapper *should* be.
		local wrapper=$bashum_repo/bin/$base_name

		# can't do much if there is not a file.
		if [[ ! -f $wrapper ]]
		then
			continue
		fi 

		# see if this is the *right* executable.  if there are conflicting
		# executables from separate packages, this should prevent us
		# from deleting the wrong one.
		if ! cat $wrapper | grep -q "source \$bashum_repo/packages/$name/bin/$base_name" 
		then
			continue		
		fi

		if ! rm $wrapper 
		then
			fail "Error deleting executable [$wrapper]"
		fi
	done
}

# usage: repo_package_remove <name>
repo_package_remove() {
	if (( $# != 1 ))
	then
		fail 'usage: repo_package_remove <name>'
	fi

	if ! repo_package_is_installed $1 
	then
		fail "Package is not installed [$1]"
	fi

	if ! repo_repo_package_remove_executables "$1"
	then
		fail "Error removing executables for package [$1]"
	fi

	local package_home=$(repo_package_get_home $1)
	if ! rm -r $package_home
	then
		fail "Error deleting package: $package_home"
	fi
}

