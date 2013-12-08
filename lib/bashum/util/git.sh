
# ensure that 'git' is installed 
if ! command -v git &> /dev/null
then
    fail "git is required."
fi

# usage: git_repo_get_dirname <url>
git_repo_get_dirname() {
    if (( $# != 1 )) 
    then
        fail "usage: git_repo_get_dirname <url>"
    fi

    echo "$(basename $1)@$(basename $(dirname $1))"
}

# usage: git_repo_get_home <root_dir> <url>
git_repo_get_home() {
    if (( $# != 2 )) 
    then
        fail "usage: git_repo_get_home <root_url> <url>"
    fi

    echo $1/$(git_repo_get_dirname $2)
}

# usage: git_repo_is_installed <root_dir> <url>
git_repo_is_installed() {
    if (( $# != 2 )) 
    then
        fail "usage: git_repo_is_installed <root_dir> <url>"
    fi

    [[ -d "$(git_repo_get_home $1 $2)" ]]; return $?;
}

# usage: git_repo_install <root_dir> <url>
git_repo_install() {
    if (( $# != 2 )) 
    then
        fail "usage: git_repo_install <root_dir> <url>"
    fi

    if git_repo_is_installed $1 $2 
    then
        fail "That repo [$2] has already been installed to [$2]"
    fi

    local target_dir="$(git_repo_get_home $1 $2)"
    ( 
        git clone $2 $target_dir || 
            fail "Failed to clone git repo [$2]"
    ) || exit 1
}


# usage: git_repo_sync <dir>
git_repo_sync() {
    if (( $# != 1 )) 
    then
        fail "usage: git_repo_sync <dir>"
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

# usage: git_repo_file_last_modified <dir> <file>
git_repo_file_last_modified() {
    if (( $# != 2 )) 
    then
        fail 'usage: git_repo_file_last_modified <dir> <file>'
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
        if [[ ! -f $2 ]]
        then
            fail "File [$2] does not exist in repo [$1]"
        fi

        git log -1 --format="%at" -- $2 ||
            fail "Error getting last modified time of file [$2]"
    ) || exit 1
}
