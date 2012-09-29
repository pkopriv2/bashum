# /usr/bin/env bash

export bashum_home=${bashum_home:-"$HOME/.bashum"}
export bashums_path=${bashums_path:-"$bashum_home:$bashum_home/bashums"}

declare -A bashums_requires=()

require() {
	if [[ -z $1 ]]
	then
		echo "Must provide a script to load." 1>&2 
		caller 0 1>&2
		exit 1
	fi

	if [[ "${bashums_requires["$1"]}" == "1" ]]
	then
		return 0 
	fi

	_IFS=$IFS
	IFS=":"

	for path in $bashums_path 
	do
		local script=$path/$1
		if [[ ! -f $script ]]
		then
			continue
		fi

		IFS=$_IFS

		source $script
		bashums_requires["$script"]="1"
		return 0
	done

	echo "Unable to locate script: $1" 1>&2 
	caller 0 1>&2
	exit 1
}
