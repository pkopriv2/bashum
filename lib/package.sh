#! /usr/bin/env bash

require 'lib/error.sh'
require 'lib/info.sh'
require 'lib/fail.sh'

package_get_home() {
	if [[ -z $1 ]]
	then
		fail 'Must provide a project name.'
	fi

	echo "$bashums_home/$1"
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
		local out=$bashum_bin_dir/$base_name
		if [[ -f $out ]]
		then
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
		local wrapper=$bashum_bin_dir/$base_name

		# can't do much if there is not a file.
		if [[ ! -f $wrapper ]]
		then
			continue
		fi 

		# see if this is the *right* executable.  if there are conflicting
		# executables from separate packages, this should prevent us
		# from deleting the wrong one.
		if ! cat $wrapper | grep -q "source \$bashums_home/$name/bin/$base_name" 
		then
			continue		
		fi

		if ! rm $wrapper 
		then
			error "Error deleting file [$wrapper]"
			exit 1 
		fi
	done
}
