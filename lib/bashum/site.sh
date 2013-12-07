#! /usr/bin/env bash

require 'lib/bashum/cli/console.sh'
require 'lib/bashum/lang/fail.sh'
require 'lib/bashum/project_file.sh'
require 'lib/bashum/util/git.sh'

export bashum_project_file=${bashum_project_file:-"project.sh"}
export bashum_repo=${bashum_repo:-$HOME/.bashum_repo}
export bashum_site_root=${bashum_site_root:-$bashum_repo/sites}

# make sure the root directory is there
[[ -d $bashum_site_root ]] || mkdir -p $bashum_site_root

# ensure that 'git' is installed 
if ! command -v git &> /dev/null
then
	fail "git is required."
fi


# usage: bashum_site_repo_get_home <url> 
bashum_site_repo_get_home() {
    if (( $# != 1 )) 
    then
        fail "usage: bashum_site_repo_get_home <url>"
    fi

    git_repo_get_home "$bashum_site_root" \
        "$1"
}

# usage: bashum_site_repo_ensure <url> 
bashum_site_repo_ensure() {
    if (( $# != 1 )) 
    then
        fail "usage: bashum_site_repo_ensure <url>"
    fi

    if ! git_repo_is_installed "$bashum_site_root" "$1"
    then
        git_repo_install "$bashum_site_root" \
            "$1"
    fi

    git_repo_sync $(bashum_site_repo_get_home $1)
}

# usage: bashum_site_deploy <project_root>
bashum_site_deploy() {
	if (( $# != 1 ))
	then
		fail 'usage: bashum_site_deploy <project_root>'
	fi

    if [[ ! -d $1 ]]
    then
        fail "That is not a directory [$1]"
    fi

	(
        builtin cd $1 

		local project_file="$(pwd)/$bashum_project_file"
		if [[ ! -f $project_file ]]
		then
			fail "Unable to locate project file [$project_file]" 
		fi

        declare local name
        name=$(project_file_get_name $project_file) ||
            fail "Error getting project name [$project_file]"

        declare local version
        version=$(project_file_get_version $project_file) ||
            fail "Error getting project version [$project_file]"

        local output_file=target/"$name"-"$version".md
        bashum_site_build $(pwd) $output_file 

        # okay, now just deploy the file to the repo
        local site_repo_url=$(project_file_get_site_repo $project_file)
        local site_repo_home=$(bashum_site_repo_get_home $site_repo_url)

        # sync the site repo.
        bashum_site_repo_ensure $site_repo_url

        # add the file and push
        local repo_file=$site_repo_home/$(basename $output_file)
        if ! cp $output_file $repo_file
        then
            fail "Error moving file [$output_file] to [$repo_file]"
        fi

        (
            cd $site_repo_home
            
            local base_name=$(basename $repo_file)
            git add $base_name && git commit -m "Adding $base_name" && git push origin master ||
                fail "Error deploying file [$base_name] to [$site_repo_url]"
        ) || exit 1

	) || exit 1
}

# usage: site_readme_build <project_root> [output_file]
bashum_site_build() {
	if (( $# < 1 ))
	then
		fail 'usage: site_readme_build <project_root> [output_file]'
	fi

	(
		builtin cd $1 

		local project_file="$(pwd)/$bashum_project_file"
		if [[ ! -f $project_file ]]
		then
			fail "Unable to locate project file [$project_file]" 
		fi

		# cleanup the staging directory
		local staging_dir=target/site-staging
		if [[ -e $staging_dir ]]
		then
			rm -rf $staging_dir
		fi

		# go ahead and create the staging directory
		if ! mkdir -p $staging_dir
		then
			fail "Error creating staging directory [$staging_dir]"
		fi

        declare local name
        name=$(project_file_get_name $project_file) ||
            fail "Error getting project name [$project_file]"

        declare local version
        version=$(project_file_get_version $project_file) ||
            fail "Error getting project version [$project_file]"

		local author=$(project_file_get_author $project_file)
		local email=$(project_file_get_email $project_file)
		local description=$(project_file_get_description $project_file)
        
        # start making the site
		local staging_file=$staging_dir/"$name"-"$version".md
        {
            echo "# ${name^^}-${version^^}"
            echo 

            echo "$description" 
            echo

            # put in the contact information
            echo "## Contact"
            echo 
            echo "* Author: $author"
            echo "* Email: $email"
            echo 

        } >> $staging_file


        # put in the dependency information
        local dependencies=( $(project_file_get_dependencies $project_file) )
        {
            echo "## Dependencies" 
            echo 

            printf '\x60\x60\x60\n' 

            if (( ${#dependencies[@]} > 0 )) 
            then

                for dependency in "${dependencies[@]}"
                do
                    local dep_name=${dependency%%:*}
                    local dep_version=${dependency##*:}

                    echo "* $dep_name [$dep_version]"
                done
            else
                echo "None"
            fi

            printf '\x60\x60\x60\n' 
            echo

        } >> $staging_file

        # run the tests and store the output
        {
            echo "## Test Results" 
            echo 

            printf '\x60\x60\x60\n' 

            ( bashum test 2>&1 ) || fail "Cannot build site.  Error running tests" 

            printf '\x60\x60\x60\n' 
            echo

        } >> $staging_file

        # Note the time
        {
            echo "## Build Date" 
            echo 
            echo "$(date)"
            echo 
        } >> $staging_file

        # okay, the site is staged.  go ahead and move it to its final location
        local output_file=${2:-target/"$name"-"$version".md}
        if ! cp $staging_file $output_file 
        then
            fail "Error moving staging site [$staging_file] to [$output_file]"
        fi

    ) || exit 1
}
