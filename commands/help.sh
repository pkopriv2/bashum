require 'lib/command.sh'
require 'lib/console.sh'

help() {
	bold "BASHUM HELP"
	echo 

	printf "%s\n" '
	Bashum is a package manager for bash projects.  It provides support
	for building, installing, and maintaining .bashum files.  
'

	bold "COMMANDS"
	echo

	local commands=( $(command_get_all) )
	for file in ${commands[@]}
	do
		if [[ $file = *help.sh ]] 
		then
			continue
		fi

		source $file

		local fn=$(command_get_usage_fn $file)
		if ! declare -f $fn &>/dev/null
		then
			continue
		fi

		printf "\t"; $fn "$@"
	done
	echo 

	bold 'MORE INFO'
	printf "%s\n" '
	To get more detailed help, simply type bashum <command> help [--detailed]

'
}
