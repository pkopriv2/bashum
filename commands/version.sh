require 'lib/bashum/cli/console.sh'

version() {
	bold "BASHUM VERSION"
	echo 

	cat $bashum_home/version.txt
}
