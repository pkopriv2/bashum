# commands/show.sh

require 'lib/bashum/repo.sh'
require 'lib/bashum/show.sh'
require 'lib/bashum/project_file.sh'

require 'lib/bashum/cli/console.sh'
require 'lib/bashum/cli/options.sh'

require 'lib/bashum/lang/fail.sh'

show_usage() {
	echo "$bashum_cmd show [<package>|<file>|<url>] [option]*"
}

show_help() {
	bold 'USAGE'
	echo
	printf "\t"; show_usage
	echo


	bold 'DESCRIPTION'
	printf '%s' '
	Shows a detailed view of the specified package. The package
	may be a raw bashum file, an installed bashum, or the url of
	a remote bashum file, or a bashum from a remote repository.

'

	bold 'OPTIONS'
	printf '%s' '
	-None

'
}


show() {
	usage() {
		bold 'USAGE'

		echo 
		printf "\t"; show_usage
		echo
	}

	if options_is_help "$@" 
	then
		show_help "$@"
		exit $?
	fi

	if (( $# == 0 )) 
	then
		error "Must provide a package name."
		echo 

		usage 
		exit 1
	fi

	if is_url $1
	then
		show_from_url $1
		return 0
	fi

	if [[ -f $1 ]]
	then
		show_from_file $1
		return 0
	fi

	local package=$1; shift

	local remote=false
	while (( $# > 0 ))
	do
		case "$1" in
			-v|--version)
				shift
				local version=$1
				;;
			-r|--remote)
				local remote=true
				;;
			-*)
				error "That option [$1] is not allowed"
				usage
				exit 1
				;;
			*)
				error "Positional arguments [$1] are not allowed after options"
				usage
				exit 1
		esac 
		shift
	done

	if $remote
	then
		show_from_remote $package $version
		return 0
	fi

	if repo_package_is_installed $package
	then
		if [[ -z $version ]]
		then
			show_from_repo $package
			return 0
		fi

		local installed_version=$(project_file_get_version $(repo_package_get_project_file $package))
		if [[ $installed_version == $version ]]
		then
			show_from_repo $package
			return 0
		fi
	fi

	show_from_remote $package $version
}

# usage: is_url <expression>
is_url() {
	if (( $# != 1 ))
	then
		fail 'usage: is_url <expression>'
	fi

	echo $1 | grep -q '$http'; return $?
}
