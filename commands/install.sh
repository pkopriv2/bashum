#! /usr/bin/env bash

export bashum_home=${bashum_home:-$HOME/.bashum}
export bashum_repo=${bashum_repo:-$HOME/.bashum_repo}
export bashum_tmp_dir=${bashum_tmp_dir:-/tmp/bashum/}

require 'lib/console.sh'
require 'lib/string.sh'
require 'lib/fail.sh'
require 'lib/help.sh'
require 'lib/package.sh'
require 'lib/project_file.sh'
require 'lib/bashum_file.sh'
require 'lib/download.sh'
require 'lib/cache.sh'

if ! command -v git &> /dev/null
then
	fail "git cannot be found."
fi

install_usage() {
	echo "$bashum_cmd install <package> [options]"
}

install_help() {
	bold 'USAGE'
	echo 
	printf "\t"; install_usage
	echo


	bold 'DESCRIPTION'
	printf '%s' '
	Validates and installs the the specified bashum file to the local
	bashum repo ($bashum_repo).  In order to pass validation,
	the bashum file must have the proper strucutre as described by
	its project.sh file and all the dependencies must be satisfied.

	Note: <package> can be a local file or a url.  

'

	bold 'OPTIONS'
	printf '%s' '
	-None 

'
}

install() {
	usage() {
		bold 'USAGE'

		echo 
		printf "\t"; install_usage
		echo
	}

	if help? "$@" 
	then
		install_help "$@"
		exit $?
	fi

	if (( $# < 1 )) 
	then
		error "Incorrect number of arguments"
		usage
		exit 1
	fi

	if is_url $1
	then
		install_from_url $1
		return $?
	fi

	if [[ -f $1 ]]
	then
		install_from_file $1
		return $?
	fi

	local expression=$1; shift
	while (( $# > 0 ))
	do
		case "$1" in
			--version)
				shift
				local version=$1
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

	install_from_name $expression $version 
	return $?
}

# usage: is_url <expression>
is_url() {
	if (( $# != 1 ))
	then
		fail 'usage: is_url <expression>'
	fi

	echo $1 | grep -q '$http'; return $?
}


# usage: install_from_name <name> [<version>]
install_from_name() {
	if (( $# != 1 )) && (( $# != 2 ))
	then
		fail 'usage: install_from_name <name> [<version>]'
	fi

	if package_is_installed $1 $2
	then
		error "Package [$1] is already installed with version [>= ${2:-any}]"
		exit 1
	fi

	cache_ensure

	local file=$(cache_bashum_from_name $1 $2)
	if [[ -z $file ]] || [[ ! -f $file ]]
	then
		error "Unable to locate bashum with that name [$1] and version [${2:-any}]"
		exit 1
	fi

	if ! install_from_file $file 
	then
		fail "Error installing bashum [$file]"
	fi
}

# usage: install_from_url <url>
install_from_url() {
	if (( $# != 1 ))
	then
		fail 'usage: install_from_url <url>'
	fi

	local target_file=$bashum_tmp_dir/$(str_random) 
	if ! download "$1" "$target_file"
	then
		fail "Error downloading bashum [$1] to [$target_file]"
	fi

	if ! install_from_file $target_file 
	then
		fail "Error installing bashum [$target_file]"
	fi
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

	if ! bashum_file_is_installable "$1"
	then
		error "Error validating bashum [$1]"
		exit 1
	fi

	local project_file=$(bashum_file_extract_project_file "$1")
	if ! install_dependencies $project_file
	then
		error "Error installing dependencies"
		exit 1
	fi

	local name=$(project_file_get_name $project_file)
	echo "Installing bashum [$name]"

	if package_is_installed $name 
	then
		if ! package_remove $name
		then
			error "Error removing previously installed package."
			exit 1
		fi
	fi

	tar -xf "$1" -C $bashum_repo/packages 
	if ! package_generate_executables "$name"
	then
		error "Error generating package executables: $name"
		exit 1
	fi

	info "Successfully installed package: $name" 
	echo "Please re-source your environment (open a new terminal session)." 
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

		if ! package_is_installed $dep_name $dep_version
		then
			if ! install $dep_name --version $dep_version
			then
				echo "Missing dependency: [$dep_name${dep_version:+:$dep_version}]"
				return 1
			fi
		fi
	done
}
