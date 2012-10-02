# fail.sh

# Cause the calling script to fail by printing the
# given message along with the current stack trace
# to standard out and exit with the specified error 
# status.
#
# $1 - The message to print
# $2 - The exit code.
#
fail() {
	echo "An error occurred: $1" 1>&2

	local frame=0
	while true 
	do
		if ! caller $frame 1>&2
		then
			break
		fi

		let frame=frame+1 # (( frame++ )) will trigger an error if errexit is set.
	done

	exit ${2:-1}
}
