# /usr/bin/env bash

export bashum_home=${bashum_home:-"$HOME/.bashum"}
export bashum_repo=${bashum_repo:-$bashum_home/repo}
export bashum_path=${bashum_path:-"$bashum_home:$bashum_repo/packages"}

declare -A bashum_requires=()

require() {
	if [[ -z $1 ]]
	then
		echo "Must provide a script to load." 1>&2 
		caller 0 1>&2
		exit 1
	fi

	# can this be better?  we're not actually checking against the 'actual'
	# script, but the script as 'required'.  
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
