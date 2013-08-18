require 'lib/bashum/repo.sh'
require 'lib/bashum/archive.sh'
require 'lib/bashum/project_file.sh'
require 'lib/bashum/remote.sh'

require 'lib/bashum/util/download.sh'

# usage: remote_bashum_install <name> [<version>]
install_from_remote() {
	if (( $# > 2 )) 
	then
		fail 'usage: remote_bashum_install <name> [<version>]'
	fi

	if repo_package_is_installed $1 $2
	then
		fail "Package [$1] is already installed with version [>= ${2:-any}]"
	fi

	remote_repos_ensure_all 

	local file=$(remote_bashum_from_name $1 $2)
	if [[ -z $file ]] || [[ ! -f $file ]]
	then
		fail "Unable to locate bashum with that name [$1] and version [${2:-any}]"
	fi

	install_from_file $file
}

# usage: install_from_url <url>
install_from_url() {
	if (( $# != 1 ))
	then
		fail 'usage: install_from_url <url>'
	fi

	local target_file=$bashum_tmp_dir/$(str_random).bashum
	if ! download "$1" "$target_file"
	then
		fail "Error downloading bashum [$1] to [$target_file]"
	fi

	install_from_file $target_file
}


# usage: install_from_project [<project_root>]
install_from_project() {
	if (( $# > 1 ))
	then
		fail 'usage: install_from_project [<project_root>]'
	fi

	(
		if [[ ! -z $1 ]]
		then
			builtin cd $1 
		fi

		local target_file=$bashum_tmp_dir/$(str_random).bashum
		archive_build $(pwd) $target_file

		install_from_file $target_file
	) || exit 1
}

# usage: install_from_file <file>
install_from_file() {
	if (( $# != 1 ))
	then
		fail 'usage: install_from_file <file> '
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
	install_dependencies $project_file

	archive_install $1
}

# usage: install_dependencies <project_file>
install_dependencies() {
	if (( $# != 1 ))
	then
		fail 'usage: install_dependencies <project_file>'
	fi

	# validate the dependencies (try to install them if they're not already installed)
	local dependencies=( $(project_file_get_dependencies $1) )

	for dependency in "${dependencies[@]}"
	do 
		local dep_name=${dependency%%:*}
		local dep_version=${dependency##*:}

		if repo_package_is_installed $dep_name $dep_version
		then
			continue
		fi

		if ! install_from_remote $dep_name $dep_version
		then
			fail "Missing dependency: [$dep_name${dep_version:+:$dep_version}]"
		fi
	done
}
