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


if [[ ! -f version.txt ]]
then
	console_error "Must be in the root of the project directory."
	exit 1
fi

version=$(cat version.txt)
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

# ensure that we have a clean staging directory
staging_dir=target/.bashum
if [[ -e $staging_dir ]]
then
	rm -rf $staging_dir
fi

mkdir -p $staging_dir

# copy the files into the staging directory
files=( "bin" "lib" "env" "env.sh" "commands" "version.txt" )
for file in ${files[@]}
do
	if ! cp -r $file $staging_dir
	then
		console_error "Error copying file [$file] to staging dir [$staging_dir]"
		exit 1
	fi
done

# create the output file
out=bashum-$version.tar
if [[ -f $out ]] 
then
	rm -f $out
fi

builtin cd target
if ! tar -cvf $out .bashum 
then
	console_error "Error building bashum tar"
	exit 1
fi
