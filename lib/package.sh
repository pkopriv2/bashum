#! /usr/bin/env bash

export bashum_home=${bashum_home:-$HOME/.bashum}
export bashums_home=${bashums_home:-$bashum_home/bashums}
export bashum_bin_dir=${bashum_bin_dir:-$bashum_home/bin}

require 'lib/error.sh'
require 'lib/info.sh'
require 'lib/fail.sh'
require 'lib/project.sh'


# download_package <url> <target> 
package_download() {
	info "Downloading bashum package: $1"

	if command -v curl &> /dev/null
	then
		if ! curl -L $1 > $2
		then
			error "Error downloading: $1.  Either cannot download or cannot write to file: $2"
			exit 1
		fi

	elif command -v wget &> /dev/null
	then
		if ! wget -q -O $2 $1
		then
			error "Error downloading: $1.  Either cannot download or cannot write to file: $2"
			exit 1
		fi

	else
		error "This installation requires either curl or wget."
		exit 1
	fi
}

# Validates the contents of a pacakge.
package_validate() {

	# locate the required <name>/project_file.sh
	local project_file=$(tar -tf $1 | grep '^[^/]*/project.sh')
	if [[ -z $project_file ]]
	then
		error "Package [$1] is missing a project.sh file."
		exit 1
	fi

	# extract the project file (to temp location)
	if ! tar -C $bashum_tmp_dir -xvf "$1" "$project_file" &> /dev/null
	then
		error "That package [$1] is corrupted"
		exit 1
	fi

	# load the project file.
	project_load_file $bashum_tmp_dir/"$project_file"

	# ensure that the structure is expected.
	declare local file
	for file in $(tar -tf $1) 
	do
		if ! echo "$file" | grep -q "^$name"
		then
			error "That package [$1] is corrupted.  Unexpected file: $file"
			exit 1
		fi
	done

	# ensure each dependency is satisfied.
	local orig_name=$name
	local orig_version=$version

	for dep in "${dependencies[@]}"
	do
		local dep_name=${dep%%:*}
		local dep_version_expected=${dep##*:}

		local dep_home=$(project_get_home "$dep_name")
		if [[ ! -d $dep_home ]]
		then
			error "Missing dependency: $dep_name${dep_version_expected:+":$dep_version_expected"}"
			exit 1
		fi

		if [[ -z $dep_version_expected ]]
		then
			continue
		fi

		local dep_project_file=$dep_home/project.sh
		(
			project_load_file "$dep_project_file"
			if [[ "$version" < "$dep_version_expected" ]]
			then
				error "Required version [$dep_version_expected] of [$dep_name] not found.  Currently, version [$version] is installed." 
				exit 1
			fi
		) || exit 1
	done
}
