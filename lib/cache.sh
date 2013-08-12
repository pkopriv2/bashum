#! /usr/bin/env bash


export bashum_repo=${bashum_repo:-$HOME/.bashum_repo}
export bashum_cache_home=${bashum_cache_home:-$bashum_repo/cache}
export bashum_cache_urls=${bashum_cache_urls:-"https://github.com/pkopriv2/bashum_repo.git"}

require 'lib/fail.sh'

# ensure that the cache home exists.
[[ -d $bashum_cache_home ]] || mkdir -p $bashum_cache_home

# ensure that 'git' is installed 
if ! command -v git &> /dev/null
then
	fail "git is required."
fi

# usage: cache_repo_get_home <url>
cache_repo_get_home() {
	if (( $# != 1 )) 
	then
		fail "usage: cache_repo_get_home <url>"
	fi

	echo "$bashum_cache_home/$(basename $1)@$(basename $(dirname $1))"
}

# usage: cache_repo_is_installed <url>
cache_repo_is_installed() {
	if (( $# != 1 )) 
	then
		fail "usage: cache_repo_is_installed <url>"
	fi

	[[ -d "$(cache_repo_get_home $1)" ]]; return $?;
}

# usage: cache_repo_install <url>
cache_repo_install() {
	if (( $# != 1 )) 
	then
		fail "usage: cache_repo_install <url>"
	fi

	if cache_repo_is_installed $1
	then
		fail "That repo [$1] has already been installed."
	fi

	local target_dir="$(cache_repo_get_home $1)"
	( 
		git clone $1 $target_dir || 
			fail "Failed to clone bashum cache repo [$1]"
	) || exit 1
}

# usage: cache_repo_sync <dir>
cache_repo_sync() {
	if (( $# != 1 )) 
	then
		fail "usage: cache_repo_sync <url>"
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

# usage: cache_repos_get_all
cache_repos_get_all() {
	_IFS=$IFS; IFS=$'\n'

	local dirs=( $(cd $bashum_cache_home; find $(pwd) -mindepth 1 -maxdepth 1 -type d) )
	for dir in ${dirs[@]}
	do
		if [[ -d $dir/.git ]]
		then
			echo $dir
		fi
	done

	IFS=$_IFS
}

# usage: cache_sync_all
cache_sync_all() {
	local repos=( $(cache_repos_get_all) )
	for repo in ${repos[@]} 
	do
		cache_repo_sync $repo 
	done
}

# usage: cache_install_all
cache_install_all() {
	_IFS=$IFS; IFS="|"

	for url in $bashum_cache_urls
	do
		if ! cache_repo_is_installed $url
		then
			cache_repo_install $url 
		fi
	done

	IFS=$_IFS
}

# usage: cache_ensure
cache_ensure() {
	cache_install_all 
	cache_sync_all
}

# usage: cache_bashums_get_all
cache_bashums_get_all() {
	(
		cd $bashum_cache_home; find $(pwd) -maxdepth 2 -type f -name '*.bashum' 
	)
}

# usage: cache_search <expression>
cache_search() {
	if (( $# != 1 ))
	then
		fail 'usage: cache_search <expression>'
	fi

	local bashums=( $(cache_bashums_get_all) )
	for bashum in ${bashums[@]}
	do
		local base_name=$(basename $bashum)
		if echo $base_name | grep -q $1 
		then
			echo $bashum
		fi
	done
}

# usage: cache_bashum_is_valid_file <file>
cache_bashum_is_valid_file() {
	if (( $# != 1 ))
	then
		fail 'usage: cache_bashum_is_valid_file <file>'
	fi

	echo $(basename $1) | grep -q '^.*-[0-9].*\.bashum$'; return $?
}

# usage: cache_bashum_get_name <file>
cache_bashum_get_name() {
	if (( $# != 1 ))
	then
		fail 'usage: cache_bashum_get_name <file>'
	fi

	if ! cache_bashum_is_valid_file $1 
	then
		fail "Bashum is improperly named: $1"
	fi

	echo $(basename $1) | sed 's|^\(.*\)-[0-9].*$|\1|'
}

# usage: cache_bashum_get_version <file>
cache_bashum_get_version() {
	if (( $# != 1 ))
	then
		fail 'usage: cache_bashum_get_version <file>'
	fi

	if ! cache_bashum_is_valid_file $1 
	then
		fail "Bashum is improperly named: $1"
	fi

	echo $(basename $1) | sed 's|^\(.*\)-\([0-9].*\)\.bashum$|\2|'
}


# usage: cache_bashum_from_name <name> [<version>]
cache_bashum_from_name() {
	if (( $# != 1 )) && (( $# != 2 ))
	then
		fail 'usage: cache_bashum_from_name <name> [<version>]'
	fi

	# find everything that matches the input
	local matches=()
	for match in $bashum_cache_home/*/$1-${2:-*}.bashum
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
		if [[ $match = *SNAPSHOT* ]]
		then
			continue
		fi

		if [[ $match > $max ]]
		then
			max=$match
		fi
	done

	echo $max
}
