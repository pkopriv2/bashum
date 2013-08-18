#! commands/build.sh

export bashum_project_file=${bashum_project_file:-"project.sh"}

require 'lib/bashum/cli/console.sh'
require 'lib/bashum/cli/options.sh'
require 'lib/bashum/project_file.sh'
require 'lib/bashum/archive.sh'

build_usage() {
	echo "$bashum_cmd build [options]"
}

build_help() {
	bold 'USAGE'
	echo
	printf "\t"; build_usage
	echo


	bold 'DESCRIPTION'
	printf '%s' '
	Builds the project in the current working directory and outputs 
	the resulting bashum into target/<name>-<version>.bashum

'

	bold 'OPTIONS'
	printf '%s' '
	- None 

'

	if options_is_detailed_help "$@"
	then
		build_help_detailed
		return $?
	fi
}

build_help_detailed() {
	bold 'MORE INFO'
	printf "%s\n" '
A valid bashum project must have the following files.

	- project.sh

A project file is basically a bash-dsl for describing the contained
project. Here is a current listing of the supporting methods. 

	- name          The name of the project [required]
	- version       The version of the project [required]
	- author        The name of the author.
	- email         The email of the author. 
	- description   A short description of the project.  Should
	                fit on a single line.
	- file          A file glob denoting non-standard files that
	                should be packaged in the bashum.  The 
	                "standard" files are currently: /bin, /lib, /env,
	                project.sh.
	- depends       Another bashum and an optional version on which
	                this project depends. 

Here is an example of a project file:

name    "test-project"
version "1.0.0-SNAPSHOT"
author  "Preston Koprivica"
email   "pkopriv2@gmail.com"

file    "license.txt" 
file    "lib2/*.sh" 

depends "stdlib" 
depends "other" "1.0.0" 
' 
}

build() {
	if options_is_help "$@"
	then
		build_help "$@"
		exit $?
	fi

	# determine if we're in an actual bashum-style project.
	if [[ ! -f $bashum_project_file ]]
	then
		error "Unable to locate project file: $bashum_project_file"
		exit 1
	fi

	# package up everything.
	info "Building project: " 
	echo 

	# load the project file.
	project_file_print "$bashum_project_file" 

	# okay, build the bashum
	archive_build
}
