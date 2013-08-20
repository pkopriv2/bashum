#! /usr/bin/env bash

require 'lib/bashum/lang/fail.sh'
require 'lib/bashum/project_file.sh'

export bashum_repo=${bashum_repo:-$HOME/.bashum_repo}
export bashum_remote_home=${bashum_remote_home:-$bashum_repo/cache}
export bashum_remote_urls_file=${bashum_remote_urls_file:-$bashum_remote_home/.repos}

[[ -d $bashum_remote_home ]] || mkdir -p $bashum_remote_home

if ! [[ -f $bashum_remote_urls_file ]] 
then
	echo "http://github.com/pkopriv2/bashum-main.git" >> $bashum_remote_urls_file
fi

# ensure that 'git' is installed 
if ! command -v git &> /dev/null
then
	fail "git is required."
fi

# usage: remote_repo_urls_get_all
remote_repo_urls_get_all() {
	if (( $# != 0 ))
	then
		fail 'usage: remote_repo_urls_get_all'
	fi

	cat $bashum_remote_urls_file
}

# usage: remote_repo_urls_is_installed <url>
remote_repo_urls_is_installed() {
	if (( $# != 1 ))
	then
		fail 'usage: remote_repo_urls_is_installed <url>'
	fi

	local urls=( $(remote_repo_urls_get_all) ) 
	for url in ${urls[@]} 
	do
		if [[ $1 == $url ]]
		then
			return 0
		fi
	done

	return 1 
}

# usage: remote_repo_urls_add <url>
remote_repo_urls_add() {
	if (( $# != 1 ))
	then
		fail 'usage: remote_repo_urls_add <url>'
	fi

	if remote_repo_urls_is_installed $1
	then
		return 0
	fi

	echo "$1" >> $bashum_remote_urls_file
}

# usage: remote_repo_urls_remove <url>
remote_repo_urls_remove() {
	if (( $# != 1 ))
	then
		fail 'usage: remote_repo_urls_remove <url>'
	fi

	if ! remote_repo_urls_is_installed $1
	then
		return 0
	fi

	local urls=( $(remote_repo_urls_get_all) ) 

	echo > $bashum_remote_urls_file
	for url in ${urls[@]} 
	do
		if [[ $1 != $url ]]
		then
			echo "$url" >> $bashum_remote_urls_file
		fi
	done
}

# usage: remote_repo_get_home <url>
remote_repo_get_home() {
	if (( $# != 1 )) 
	then
		fail "usage: remote_repo_get_home <url>"
	fi

	echo "$bashum_remote_home/$(basename $1)@$(basename $(dirname $1))"
}

# usage: remote_repo_is_installed <url>
remote_repo_is_installed() {
	if (( $# != 1 )) 
	then
		fail "usage: remote_repo_is_installed <url>"
	fi

	[[ -d "$(remote_repo_get_home $1)" ]]; return $?;
}

# usage: remote_repo_install <url>
remote_repo_install() {
	if (( $# != 1 )) 
	then
		fail "usage: remote_repo_install <url>"
	fi

	if remote_repo_is_installed $1
	then
		fail "That repo [$1] has already been installed."
	fi

	local target_dir="$(remote_repo_get_home $1)"
	( 
		git clone $1 $target_dir || 
			fail "Failed to clone bashum cache repo [$1]"
	) || exit 1
}

# usage: remote_repo_remove <url> 
remote_repo_remove() {
	if (( $# != 1 )) 
	then
		fail "usage: remote_repo_remove <url>"
	fi

	if ! remote_repo_is_installed $1
	then
		return 0
	fi

	local target_dir="$(remote_repo_get_home $1)"
	if ! rm -rf $target_dir 
	then
		fail "Failed to remove remote repo [$1]"
	fi
}


# usage: remote_repo_sync <dir>
remote_repo_sync() {
	if (( $# != 1 )) 
	then
		fail "usage: remote_repo_sync <url>"
	fi

	if [[ ! -d $1 ]]
	then
		fail "Repo [$1] does not exist"
	fi

	if [[ ! -d $1/.git ]]
	then
		fail "Repo [$1] is not a git repo."
	fi

	( 
		cd $1
		git checkout -f master && git fetch origin && git reset --hard origin/master ||
			fail "Failed to sync repo [$1]"
	) || exit 1
}

# usage: remote_repos_get_all
remote_repos_get_all() {
	local urls=( $(remote_repo_urls_get_all) )
	for url in ${urls[@]}
	do
		echo $(remote_repo_get_home $url)
	done
}

# usage: remote_repos_sync_all
remote_repos_sync_all() {
	local repos=( $(remote_repos_get_all) )
	for repo in ${repos[@]} 
	do
		remote_repo_sync $repo 
	done
}

# usage: remote_repos_install_all
remote_repos_install_all() {
	local urls=( $(remote_repo_urls_get_all) )
	for url in ${urls[@]}
	do
		if ! remote_repo_is_installed $url
		then
			remote_repo_install $url 
		fi
	done
}

# usage: remote_repos_ensure_all
remote_repos_ensure_all() {
	remote_repos_install_all 
	remote_repos_sync_all
}

# usage: remote_bashums_get_all
remote_bashums_get_all() {
	local dirs=( $(remote_repos_get_all) )
	for dir in ${dirs[@]}
	do
		(
			cd $dir; find $(pwd) -maxdepth 2 -type f -name '*.bashum' 
		)
	done
}

# usage: remote_bashums_search <expression>
remote_bashums_search() {
	if (( $# != 1 ))
	then
		fail 'usage: remote_bashums_search <expression>'
	fi

	local bashums=( $(remote_bashums_get_all) )
	for bashum in ${bashums[@]}
	do
		declare local name

		name=$(remote_bashum_get_name $bashum) || name=$(basename $bashum)
		if echo $name | grep -q $1 
		then
			echo $bashum
		fi
	done
}

# usage: remote_bashum_is_valid_file <file>
remote_bashum_is_valid_file() {
	if (( $# != 1 ))
	then
		fail 'usage: remote_bashum_is_valid_file <file>'
	fi

	echo $(basename $1) | grep -q '^.*-[0-9].*\.bashum$'; return $?
}

# usage: remote_bashum_get_name <file>
remote_bashum_get_name() {
	if (( $# != 1 ))
	then
		fail 'usage: remote_bashum_get_name <file>'
	fi

	if ! remote_bashum_is_valid_file $1 
	then
		fail "Bashum is improperly named: $1"
	fi

	echo $(basename $1) | sed 's|^\(.*\)-[0-9].*$|\1|'
}

# usage: remote_bashum_get_version <file>
remote_bashum_get_version() {
	if (( $# != 1 ))
	then
		fail 'usage: remote_bashum_get_version <file>'
	fi

	if ! remote_bashum_is_valid_file $1 
	then
		fail "Bashum is improperly named: $1"
	fi

	echo $(basename $1) | sed 's|^\(.*\)-\([0-9].*\)\.bashum$|\2|'
}


# usage: remote_bashum_from_name <name> [<version>]
remote_bashum_from_name() {
	if (( $# != 1 )) && (( $# != 2 ))
	then
		fail 'usage: remote_bashum_from_name <name> [<version>]'
	fi

	# find everything that matches the input
	local matches=()
	for match in $bashum_remote_home/*/$1-${2:-*}.bashum
	do
		if [[ -f $match ]]
		then
			matches+=( $match )
		fi
	done

	# find the lexicographically greatest version (preferring non-snapshots)
	local max=${matches[0]}
	for match in ${matches[@]} 
	do
		local version_match=$(remote_bashum_get_version $match)
		local version_max=$(remote_bashum_get_version $max)

		if (( "$(project_file_version_compare $version_max $version_match)" > 0 ))
		then
			max=$match
		fi
	done

	echo $max
}

