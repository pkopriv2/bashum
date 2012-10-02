#! /bin/bash

console_info() {
	if ! tput setaf &> /dev/null
	then
		echo -e "$1"
	else
		echo -e "$(tput setaf 2)$1$(tput sgr0)"
	fi
}

console_error() {
	if ! tput setaf &> /dev/null
	then
		echo -e "$1" 1>&2
	else
		echo -e "$(tput setaf 1)$1$(tput sgr0)" 1>&2
	fi
}


if [[ ! -f project.txt ]]
then
	console_error "Must be in the root of the project directory."
	exit 1
fi

version=$(cat project.txt | awk '{print $2;}')
while [[ $# -gt 0 ]]
do
	arg="$1"

	case "$arg" in
		-l|--latest)
			version="latest"
			;;
		*)
			console_error "That option is not allowed" 
			;;
	esac
	shift
done

console_info "Packaging version: $version" 

mkdir -p target

out=target/bashum-$version.tar
if [[ -f $out ]] 
then
	rm -f $out
fi

griswold -o $out                     \
		 -b .bashum                  \
		  bin                        \
		  lib                        \
		  commands                   \
		  env.sh                     \
