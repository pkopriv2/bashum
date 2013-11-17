require 'lib/bashum/lang/fail.sh'
require 'lib/bashum/util/git.sh'

export bashum_home=${bashum_home:-$HOME/.bashum}
export bashum_repo=${bashum_repo:-$HOME/.bashum_repo}
export bashum_update_frequency=${bashum_update_frequency:-604800}
export bashum_update_root=${bashum_update_root:-$bashum_repo/updates}
export bashum_update_repo_url=${bashum_update_repo_url:-"git://github.com/pkopriv2/bashum-versions.git"}
export bashum_update_last_check_file=${bashum_update_last_check_file:-$bashum_update_root/.last_check}
export bashum_update_last_update_file=${bashum_update_last_update_file:-$bashum_update_root/.last_update}
export bashum_update_package=${bashum_update_package:-"bashum-latest.tar"}

# ensure that 'git' is installed 
if ! command -v git &> /dev/null
then
    fail "git is required."
fi

# ensure the update directory exists
[[ -d $bashum_update_root ]] || mkdir -p $bashum_update_root

# ensure the last check file
if ! [[ -f $bashum_update_last_check_file ]] 
then
    echo $(date +"%s") > $bashum_update_last_check_file
fi

# usage: bashum_update_get_last_check 
bashum_update_get_last_check() {
    if (( $# != 0 ))
    then
        fail 'usage: bashum_update_get_last_check'
    fi

    cat $bashum_update_last_check_file
}

# usage: bashum_update_set_last_check <time>
bashum_update_set_last_check() {
    if (( $# != 1 ))
    then
        fail 'usage: bashum_update_set_last_check <time>'
    fi

    echo $1 > $bashum_update_last_check_file
}

# usage: bashum_update_get_last_update 
bashum_update_get_last_update() {
    if (( $# != 0 ))
    then
        fail 'usage: bashum_update_get_last_update'
    fi

    cat $bashum_update_last_update_file
}

# usage: bashum_update_set_last_update <time>
bashum_update_set_last_update() {
    if (( $# != 1 ))
    then
        fail 'usage: bashum_update_set_last_update <time>'
    fi

    echo $1 > $bashum_update_last_update_file
}

# usage: bashum_update_repo_get_home 
bashum_update_repo_get_home() {
    if (( $# != 0 )) 
    then
        fail "usage: bashum_update_repo_get_home"
    fi

    git_repo_get_home "$bashum_update_root" \
        "$bashum_update_repo_url"
}

# usage: bashum_update_repo_ensure 
bashum_update_repo_ensure() {
    if (( $# != 0 )) 
    then
        fail "usage: bashum_update_repo_ensure "
    fi

    if ! git_repo_is_installed "$bashum_update_root" "$bashum_update_repo_url"
    then
        git_repo_install "$bashum_update_root" \
            "$bashum_update_repo_url"
    fi

    git_repo_sync $(bashum_update_repo_get_home)
}

# usage: bashum_update_get_package_time
bashum_update_get_package_time() {
    if (( $# != 0 )) 
    then
        fail "usage: bashum_update_repo_sync"
    fi

    git_repo_file_last_modified $(bashum_update_repo_get_home) \
        "$bashum_update_package"
}

# usage: bashum_update
bashum_update() {
    if (( $# != 0 )) 
    then
        fail "usage: bashum_update"
    fi

    local package_file=$(bashum_update_repo_get_home)/$bashum_update_package
    if ! tar -xf $package_file -C $(dirname $bashum_home)
    then
        console_error "Error unpackaging update file [$package_file]"
        exit 1
    fi 
}

# usage: bashum_auto_update
bashum_auto_update() {
    if (( $# != 0 )) 
    then
        fail "usage: bashum_update"
    fi

    local now=$(date +"%s")
    local last_check=$(bashum_update_get_last_check)

    let elapsed=$now-$last_check
    if (( $elapsed < $bashum_update_frequency ))
    then
        return 0
    fi

    echo "Checking for bashum updates"
    bashum_update_repo_ensure

    local last_update=$(bashum_update_get_last_update)
    local last_package_time=$(bashum_update_get_package_time)

    if (( $last_package_time <= $last_update ))
    then
        echo "No updates found."
        return 0
    fi

    echo "Updating bashum."
    bashum_update
    echo "Update complete. Please re-source your environment to complete"
}

bashum_auto_update
