# lib/bashum/archive.sh

require 'lib/bashum/repo.sh'
require 'lib/bashum/project_file.sh'

require 'lib/bashum/cli/console.sh'
require 'lib/bashum/lang/string.sh'


export bashum_project_file=${bashum_project_file:-"project.sh"}
export bashum_standard_files=${bashum_standard_files:-"bin:lib:env:project.sh"}

if ! command -v tar &> /dev/null
then
	fail "Installation requires a working version of tar." 
fi

# usage: archive_extract_project_file <file>
archive_extract_project_file() {
	if (( $# != 1 ))
	then
		fail 'usage: archive_extract_project_file <file>'
	fi

	# locate the required <name>/project_file.sh
	local project_file=$(tar -tf $1 | grep '^[^/]*/project.sh')
	if [[ -z $project_file ]]
	then
		fail "Package [$1] is missing a project.sh file."
	fi

	# make a tmp directory
	local output_dir=$bashum_tmp_dir/$1_$(str_random)
	if ! mkdir -p $output_dir
	then
		fail "Error making output directory [$output_dir]"
	fi

	# extract the project file (to temp location)
	if ! tar -C $output_dir -xvf "$1" "$project_file" &> /dev/null
	then
		fail "That package [$1] is corrupted"
	fi

	# finally, echo the location to the file. 
	echo "$output_dir/$project_file" 
}

archive_get_executables() {
	if [[ -z $1 ]]
	then
		error 'Must provide a bashum file'
		exit 1
	fi

	local archive=$1
	if [[ ! -f $archive ]] 
	then
		error "That bashum file [$archive] doesn't exist"
		exit 1
	fi
	
	tar -tf $archive | grep '^[^/]*/bin/[^/]\+$' 
}

archive_get_libs() {
	if [[ -z $1 ]]
	then
		error 'Must provide a bashum file'
		exit 1
	fi

	local archive=$1
	if [[ ! -f "$archive" ]] 
	then
		error "That bashum file [$archive] doesn't exist"
		exit 1
	fi
	
	tar -tf $archive | grep '^[^/]*/lib/.' | grep '\.sh$'
}

# usage: archive_is_installable <file>
archive_is_installable() {
	if (( $# != 1 ))
	then
		fail 'usage: archive_is_installable <file>'
	fi

	declare local project_file
	if ! project_file=$(archive_extract_project_file $1) 
	then
		return 1
	fi

	# ensure that the structure is expected.
	declare local name
	if ! name=$(project_file_get_name $project_file)
	then
		return 1
	fi

	for file in $(tar -tf $1) 
	do
		if ! echo "$file" | grep -q "^$name"
		then
			echo "That bashum [$1] is corrupted.  Unexpected file: $file" 1>&2
			return 1
		fi
	done
}

# usage: archive_build [<project_root>] [output_file]
archive_build() {
	if (( $# > 2 ))
	then
		fail 'usage: archive_build [<project_root>] [output_file]'
	fi

	(
		if (( $# == 1 ))
		then
			builtin cd $1 
		fi

		local project_file="$(pwd)/$bashum_project_file"
		if [[ ! -f $project_file ]]
		then
			fail "Unable to locate project file [$project_file]" 
		fi

		local name=$(project_file_get_name $project_file)
		local version=$(project_file_get_version $project_file)

		# cleanup the staging directory
		local staging_parent_dir=target/staging
		local staging_dir=$staging_parent_dir/$name
		if [[ -e $staging_dir ]]
		then
			rm -rf $staging_dir
		fi

		# go ahead and create the staging directory
		if ! mkdir -p $staging_dir
		then
			fail "Error creating staging directory [$staging_dir]"
		fi

		_IFS=$IFS
		IFS=":"
		
		# copy the standard files into the staging directory
		declare local file 
		for file in $bashum_standard_files
		do
			if [[ ! -f $file && ! -d $file ]]
			then
				continue
			fi 

			if ! cp -r $file $staging_dir
			then
				fail  "Error copying file [$file] to staging dir [$staging_dir]"
			fi
		done

		IFS=$_IFS

		# copy the custom files into the staging directory
		local file_globs=$(project_file_get_globs $bashum_project_file)
		for glob in "${file_globs[@]}"
		do
			for file in $glob
			do
				if [[ ! -f $file && ! -d $file ]]
				then
					continue
				fi
	
				if ! cp -r $file $staging_dir
				then
					fail "Error copying file [$file] to staging dir [$staging_dir]"
				fi
			done
		done

		if [[ -n $2 ]]
		then
			local out=$2 
		else
			local out=$(pwd)/target/$name-$version.bashum
		fi

		echo "Building output file: $out"

		# build the bashum!
		builtin cd $staging_parent_dir
		if ! tar -cf $out $name
		then
			fail "Error building bashum tar" 
		fi
	) || exit 1


}

# usage: archive_install <file>
#
# Installs the given archive to the local repository, without 
# verifying dependencies.
#
archive_install() {
	if (( $# != 1 ))
	then
		fail 'usage: archive_install <file>'
	fi

	if ! archive_is_installable "$1"
	then
		error "Error validating bashum [$1]"
		exit 1
	fi

	local project_file=$(archive_extract_project_file "$1")

	# validate the dependencies 
	local dependencies=( $(project_file_get_dependencies $project_file) )
	for dependency in "${dependencies[@]}"
	do 
		local dep_name=${dependency%%:*}
		local dep_version=${dependency##*:}

		if ! repo_package_is_installed $dep_name $dep_version
		then
			fail "Missing dependency [$dep_name:$dep_version]"
		fi
	done

	local name=$(project_file_get_name $project_file)

	# cleanup any existing package with this project's name
	# TODO: should we prevent re-installing an existing package?
	if repo_package_is_installed $name 
	then
		if ! repo_package_remove $name
		then
			fail "Error removing package [$name]" 
		fi
	fi

	# okay, we should be good to install!
	tar -xf "$1" -C $(repo_get_package_root) 
	if ! repo_package_generate_executables "$name"
	then
		fail "Error generating package executables: $name"
	fi

	echo "Successfully installed package: $name:$version" 
}
