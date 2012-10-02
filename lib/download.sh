#! /usr/bin/env bash

require 'lib/console.sh'

# downloads a remote resource to the specified location.
download() {
	if (( $# != 2 ))
	then
		error "Must provide both a url and target"
		return 1
	fi

	local url=$1
	local out=$2

	info "Downloading bashum file: $url to: $out"

	if command -v curl &> /dev/null
	then
		if ! curl -# -L $url > $out
		then
			error "Error downloading: $url.  Either cannot download or cannot write to file: $out"
			return 1
		fi

	elif command -v wget &> /dev/null
	then
		if ! wget -q -O $out $url
		then
			error "Error downloading: $url.  Either cannot download or cannot write to file: $out"
			return 1
		fi

	else
		error "This installation requires either curl or wget."
		return 1
	fi
}
