# /usr/bin/env bash

export bashum_home=${bashum_home:-$HOME/.bashum}
export bashum_repo=${bashum_repo:-$HOME/.bashum_repo}
export bashum_path=${bashum_path:-$bashum_home:$bashum_repo/packages}

declare -A bashum_requires=()

require() {
	if [[ -z $1 ]]
	then
		echo "Must provide a script to load." 1>&2 
		caller 0 1>&2
		exit 1
	fi

	# can this be better?  we're not actually checking against the 'actual'
	# script, but the script as 'required' which is most likely a relative
	# script and can potentially conflict.
	if [[ "${bashum_requires["$1"]}" == "1" ]]
	then
		return 0 
	fi

	_IFS=$IFS
	IFS=":"

	declare local path
	for path in $bashum_path 
	do
		local script=$path/$1

		# if a directory was required, put it on the path.
		if [[ -d $script ]]
		then
			bashum_path=$script:$bashum_path
			IFS=$_IFS
			return 0
		fi

		# if the script doesn't exist on this path, just continue
		if [[ ! -f $script ]]
		then
			continue
		fi

		IFS=$_IFS

		source $script
		bashum_requires["$1"]="1" 
		return 0
	done

	echo "Unable to locate script: $1" 1>&2 
	caller 0 1>&2
	exit 1
}

require_bashum() {
	if [[ -z $1 ]]
	then
		echo "Must provide a bashum to load." 1>&2 
		caller 0 1>&2
		exit 1
	fi
	
	local bashum_home="$bashum_repo/packages/$1"
	if [[ ! -d $bashum_home ]]
	then
		echo "Unable to locate bashum: $1" 1>&2 
		caller 0 1>&2
		exit 1
	fi

	export bashum_path=$bashum_home:$bashum_path
}
