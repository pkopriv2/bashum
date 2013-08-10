#! /usr/bin/env bash

export bashum_cache_url=${bashum_cache_url:-"https://github.com/pkopriv2/bashum_repo.git"}

require 'lib/fail.sh'

# usage: package_get_home <name>
cache_get_home() {
	echo "$bashum_repo/cache"
}

cache_exists() {
	[[ -d $(cache_get_home) ]]; return $?;
}

cache_validate() {
	local cache_dir=$(cache_get_home)

	cache_exists && 
		[[ -d $cache_dir/.git ]]
}

cache_delete() {
	[[ -d $(cache_get_home) ]] && 
		rm -rf $(cache_get_home)
}

cache_install() {
	local parent_dir=$(dirname $(

	( 
		mkdir -p $(cache_get_home)
		cd $(cache_get_home)
		git clone $bashum_cache_url || 
			fail "Failed to clone bashum cache repo: $bashum_cache_url"
	) || exit 1
}

cache_sync() {
	( 
		cd $(cache_get_home)
		git checkout master && git fetch origin && git reset --hard origin/master ||
			fail "Failed to sync cache repository"
	) || exit 1
}

cache_search() {
	if (( $# != 1 ))
	then
		fail 'usage: cache_search <expression>'
	fi

	(
		cd $(cache_get_home)
		find -maxdepth 1 -type f -name '*.bashum' |
			sed 's|([^-]*)-(.*)\.bashum|\1: \2' 
	)
}

cache_ensure() {
	if ! cache_exists 
	then
		cache_install ||
			fail "Error installing bashum repo cache"
	fi

	if ! cache_validate 
	then
		cache_delete ||
			fail "Error removing bashum repo cache"

		cache_install ||
			fail "Error installing bashum repo cache"
	fi

	cache_sync ||
		fail "Error syncing bashum repo."
}

cache_get_bashum() {
	:
}

cache_bashum_is_installed() {
 :
}


