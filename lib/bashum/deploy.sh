require 'lib/bashum/archive.sh'
require 'lib/bashum/project_file.sh'
require 'lib/bashum/remote.sh'
require 'lib/bashum/repo.sh'

# usage: deploy_project [<project_root>]
deploy_project() {
	if (( $# > 1 ))
	then
		fail 'usage: deploy_project [<project_root>]'
	fi

	(
		if [[ ! -z $1 ]]
		then
			builtin cd $1 
		fi

		# TODO: make this the standard target/<name>-<version>.bashum location
		local target_file=$bashum_tmp_dir/$(str_random).bashum
		archive_build $(pwd) $target_file

		deploy_file $target_file
	) || exit 1
}

# usage: deploy_file <file>
deploy_file() {
	if (( $# != 1 ))
	then
		fail 'usage: deploy_file <file>'
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

	declare local name
	name=$(project_file_get_name $project_file) || 
		exit 1

	declare local version
	version=$(project_file_get_version $project_file) || 
		exit 1

	local remote_repo=$(project_file_get_repo $project_file)
	if [[ -z $remote_repo ]]
	then
		fail "No deployment repo was found for bashum [$1]" 
	fi

	if ! remote_repo_is_installed $remote_repo
	then
		remote_repo_install $remote_repo
	fi

	local repo_home=$(remote_repo_get_home $remote_repo) 
	if [[ ! -d $repo_home ]]
	then
		# shouldn't be possible...but be paranoid 
		fail "Remote repo [$remote_repo] is not installed"
	fi

	remote_repo_sync $repo_home

	local target_file=$repo_home/"$name-$version".bashum
	if ! cp $1 $target_file
	then
		fail "Failed to copy the bashum [$1] to the remote repo [$repo_home]"
	fi

	(
		builtin cd $repo_home
		git remote add deploy $remote_repo || echo -n # ignore any errors

		local base_name=$(basename $target_file)
		git add $base_name && git commit -m "Adding $base_name" && git push deploy master ||
			fail "Error deploying file [$base_name] to [$remote_repo]"
	) || exit 1
}
