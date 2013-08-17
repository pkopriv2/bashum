#! /usr/bin/env bash


# Print a message to stderr.  If the terminal
# supports colored output, then the message 
# will be printed in red.
#
# $1 - The message to print
#
error() {
	if ! tput setaf &> /dev/null
	then
		echo -e "$1" 1>&2
	else
		echo -e "$(tput setaf 1)$1$(tput sgr0)" 1>&2
	fi
}


# Print a message to stdout.  If the terminal
# supports colored output, then the message 
# will be printed in green.
#
# $1 - The message to print
#
info() {
	if ! tput setaf &> /dev/null
	then
		echo -e "$1"
	else
		echo -e "$(tput setaf 2)$1$(tput sgr0)"
	fi
}

# Print a message to stdout.  If the terminal
# supports colored output, then the message 
# will be printed in green.
#
# $1 - The message to print
#
bold() {
	if ! tput setaf &> /dev/null
	then
		echo -e "$1"
	else
		echo -e "$(tput bold)$1$(tput sgr0)"
	fi
}
