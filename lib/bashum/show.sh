require 'lib/bashum/repo.sh'
require 'lib/bashum/archive.sh'
require 'lib/bashum/project_file.sh'
require 'lib/bashum/remote.sh'

require 'lib/bashum/cli/console.sh'
require 'lib/bashum/util/download.sh'

# usage: remote_bashum_show <name> [<version>]
show_from_remote() {
	if (( $# > 2 )) 
	then
		fail 'usage: remote_bashum_show <name> [<version>]'
	fi

	remote_repos_ensure_all 

	local file=$(remote_bashum_from_name $1 $2)
	if [[ -z $file ]] || [[ ! -f $file ]]
	then
		fail "Unable to locate bashum with that name [$1] and version [${2:-any}]"
	fi

	info "Remote bashum:"
	echo

	show_from_file $file
}

# usage: show_from_url <url>
show_from_url() {
	if (( $# != 1 ))
	then
		fail 'usage: show_from_url <url>'
	fi

	local target_file=$bashum_tmp_dir/$(str_random).bashum
	if ! download "$1" "$target_file"
	then
		fail "Error downloading bashum [$1] to [$target_file]"
	fi

	show_from_file $target_file
}

# usage: show_from_repo <package>
show_from_repo() {
	if (( $# != 1 ))
	then
		fail 'usage: show_from_repo <repo>'
	fi

	if ! repo_package_is_installed $1 
	then
		fail "That package [$1] is not installed." 
	fi

	info "Local repo"
	echo 

	local project_file=$(repo_package_get_project_file "$1")
	project_file_print $project_file

	local executables=( $(repo_package_get_executables "$1") )
	if (( ${#executables[@]} > 0 ))
	then
		info "Executables: " 
		declare local file
		for file in "${executables[@]}" 
		do
			echo "    - $(basename $file)"
		done
		echo 
	fi

	local libs=( $(repo_package_get_libs "$1") )
	if (( ${#libs[@]} > 0 ))
	then
		info "Libraries: " 
		declare local file
		for file in "${libs[@]}" 
		do
			echo "    - ${file#*$1}"
		done
		echo 
	fi
}


# usage: show_from_project [<project_root>]
#show_from_project() {
	#if (( $# > 1 ))
	#then
		#fail 'usage: show_from_project [<project_root>]'
	#fi

	#(
		#if [[ ! -z $1 ]]
		#then
			#builtin cd $1 
		#fi

		#local target_file=$bashum_tmp_dir/$(str_random).bashum
		#archive_build $(pwd) $target_file

		#show_from_file $target_file
	#) || exit 1
#}

# usage: show_from_file <file>
show_from_file() {
	if (( $# != 1 ))
	then
		fail 'usage: show_from_file <file> '
	fi

	if [[ ! -f $1 ]]
	then
		fail "That file [$1] does not exist"
	fi

	if ! archive_is_installable "$1"
	then
		fail "Error validating bashum [$1]"
	fi

	local project_file=$(archive_extract_project_file "$1")
	project_file_print $project_file

	# print the executables
	local executables=( $(archive_get_executables "$1") )
	if (( ${#executables[@]} > 0 ))
	then
		info "Executables: " 
		declare local file
		for file in "${executables[@]}" 
		do
			echo "    - $(basename $file)"
		done
		echo 
	fi

	# print the library files
	local name=$(project_file_get_name $project_file)
	local libs=( $(archive_get_libs "$1") )
	if (( ${#libs[@]} > 0 ))
	then
		info "Libraries: " 
		declare local file
		for file in "${libs[@]}" 
		do
			echo "    - ${file#*$name}"
		done
		echo 
	fi
}
