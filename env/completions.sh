#! /usr/bin/env bash

export bashum_home=${bashum_home:-$HOME/.bashum}
export bashum_repo=${bashum_repo:-$HOME/.bashum_repo}

_bashum_complete() {
	_bashum_command_list() {
		(
			declare local command
			for command in $bashum_home/commands/*.sh
			do
				if [[ ! -f $command ]]
				then
					continue
				fi

				command=$(basename $command)
				command=${command%%.sh}
				echo $command
			done
		)
	}

	_bashum_package_list() {
		(
			declare local package
			for package in $bashum_repo/packages/*
			do
				if [[ ! -d $package ]]
				then
					continue
				fi

				basename $package
			done
		)
	}

	_bashum_executable_list() {
		(
			declare local executable
			for executable in bin/* 
			do
				if [[ ! -f $executable ]]
				then
					continue
				fi

				basename $executable
			done
		)
	}

	local cur=${COMP_WORDS[COMP_CWORD]}
	local cmd=""
	local index=1

	while (( index < COMP_CWORD )) 
	do
		cmd+=":${COMP_WORDS[index]}"
		(( index++ ))
	done

	COMPREPLY=()   

	case "$cmd" in
		"")
			local commands=( $(_bashum_command_list) )
			COMPREPLY=( $( compgen -W '${commands[@]}' $cur ) )
			;;
		:remove|:show)
			local packages=( $(_bashum_package_list) )
			COMPREPLY=( $( compgen -W '${packages[@]}' $cur ) )
			;;
		:run)
			local executables=( $(_bashum_executable_list) )
			COMPREPLY=( $( compgen -W '${executables[@]}' $cur ) )
			;;
		*)
			COMPREPLY=( $( compgen -o default $cur ) )
			;;
	esac

	unset -f _bashum_env_list
	unset -f _bashum_package_list
	unset -f _bashum_executable_list

	return 0
}

if [[ ! -z $BASH ]]
then
	complete -F _bashum_complete bashum
fi
