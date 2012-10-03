#! /usr/bin/env bash

export bashum_repo=${bashum_repo:-$HOME/.bashum_repo}

require 'lib/console.sh'
require 'lib/fail.sh'

package_get_home() {
	if [[ -z $1 ]]
	then
		fail 'Must provide a project name.'
	fi

	echo "$bashum_repo/packages/$1"
}

package_get_executables() {
	if [[ -z $1 ]]
	then
		fail 'Must provide a project name.'
	fi

	local package_home=$(package_get_home "$1")
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
		if [[ ! -f $executable ]]
		then
			continue
		fi

		echo $executable
	done
}

package_get_libs() {
	if [[ -z $1 ]]
	then
		fail 'Must provide a project name.'
	fi

	local package_home=$(package_get_home "$1")
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

package_generate_executables() {
	if [[ -z $1 ]]
	then
		fail 'Must provide a project name'
	fi

	local name="$1"
	for executable in $(package_get_executables "$name" ) 
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

package_remove_executables() {
	if [[ -z $1 ]]
	then
		fail 'Must provide a package name'
	fi

	local name="$1"
	for executable in $(package_get_executables "$name" ) 
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
			error "Error deleting executable [$wrapper]"
			exit 1 
		fi
	done
}
