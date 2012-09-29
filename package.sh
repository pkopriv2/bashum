#! /bin/bash

info() {
	if ! tput setaf &> /dev/null
	then
		echo -e "$1"
	else
		echo -e "$(tput setaf 2)$1$(tput sgr0)"
	fi
}

error() {
	if ! tput setaf &> /dev/null
	then
		echo -e "$1" 1>&2
	else
		echo -e "$(tput setaf 1)$1$(tput sgr0)" 1>&2
	fi
}

version=$(cat $rr_home/project.txt | awk '{print $2;}')
while [[ $# -gt 0 ]]
do
	arg="$1"

	case "$arg" in
		-l|--latest)
			version="latest"
			;;
		*)
			error "That option is not allowed" 
			;;
	esac
	shift
done

info "Packaging version: $version" 

mkdir -p $rr_home/target

out=$rr_home/target/remote-runner-$version.tar
if [[ -f $out ]] 
then
	rm -f $out
fi

griswold -o $out                     \
		 -c $rr_home                 \
		 -b remote-runner-$version   \
		  bin                        \
		  dsl                        \
		  env                        \
		  lib                        \
		  scripts                    \
		  env.sh                     \
		  require.sh                                       
