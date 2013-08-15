export bashum_home=${bashum_home:-$HOME/.bashum}
export bashum_command_home=${bashum_command_home:-$bashum_home/commands}

# usage: command_get_from_args <arg> [<arg>]*
command_get_from_args() {
	if (( $# < 1 ))
	then
		fail 'usage: command_get_from_args <arg> [<arg>]*' 
	fi

	local cur=$bashum_command_home
	while (( $# > 0 ))
	do
		cur=$cur/$1; shift 
		if [[ -f "$cur".sh ]]
		then
			break
		fi

		if [[ ! -d $cur ]]
		then
			return 1
		fi
	done

	# ensure we've found it
	if [[ ! -f "$cur".sh ]]
	then
		return 1
	fi

	# okay, we found it.  emit the command.
	echo "$cur".sh

	# okay, now simply echo the remaining args
	while (( $# > 0 ))
	do
		echo $1; shift
	done
}

# usage: command_get_main_fn <file>
command_get_main_fn() {
	if (( $# != 1 ))
	then
		fail 'usage: command_get_main_fn <file>' 
	fi

	if [[ ! -f $1 ]]
	then
		fail "That command file [$1] does not exist"
	fi

	# remove the command home from the name 
	local remaining=${1##$bashum_command_home/}
	local remaining=${remaining%%.sh}

	# okay, now split on "/" 
	local sub_dirs=( $( echo $remaining | sed 's|\/| |g' ) )

	# and finally, join with _
	local idx=0
	local size=${#sub_dirs[@]}

	while (( $idx < $size )) 
	do
		if (( $idx == $size-1 ))
		then
			echo -n "${sub_dirs[$idx]}"
			return 0
		fi

		echo -n "${sub_dirs[$idx]}_"
		let idx+=1
	done
}

# usage: command_get_help_function <file>
command_get_help_fn() {
	if (( $# != 1 ))
	then
		fail 'usage: command_get_help_function <file>' 
	fi

	if [[ ! -f $1 ]]
	then
		fail "That command file [$1] does not exist"
	fi

	echo "$(command_get_main_fn $1)_help"
}

# usage: command_get_help_function <file>
command_get_usage_fn() {
	if (( $# != 1 ))
	then
		fail 'usage: command_get_help_function <file>' 
	fi

	if [[ ! -f $1 ]]
	then
		fail "That command file [$1] does not exist"
	fi

	echo "$(command_get_main_fn $1)_usage"
}

# usage: command_get_all
command_get_all() {
	(
		find $bashum_command_home -type f -name '*.sh'
	)
}

