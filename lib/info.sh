# info.sh

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
