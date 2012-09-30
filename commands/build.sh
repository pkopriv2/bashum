#! /usr/bin/env bash

export bashum_project_file=${bashum_project_file:-"project.sh"}
export bashum_project_files=${bashum_project_files:-"bin:lib:env:project.sh"}

require 'lib/project.sh'

build_help() {
	echo;
}

build() {
	# determine if we're in an actual bashum-style project.
	if [[ ! -f $bashum_project_file ]]
	then
		error "Unable to locate project file: $bashum_project_file"
		exit 1
	fi

	# load the project file.
	project_load_file $bashum_project_file

	# package up everything.
	info "Building project: [$name-$version]" 

	# if the /target directory doesn't exist, create it.
	if [[ ! -d target ]] 
	then
		mkdir -p target
	fi

	# if there is already the same package, remove it.
	out=target/$name-$version.bashum
	if [[ -f $out ]] 
	then
		rm -f $out
	fi

	(
		IFS=":"
		for file in $bashum_project_files
		do
			if [[ ! -f $file && ! -d $file ]]
			then
				continue
			fi

			griswold -o $out  \
					 -b $name \
					 $file                      
		done
	)
}
