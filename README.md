# Bashum 

Finally, a package manager for bash, written in bash!  Bashum provides
support for building, installing and managing .bashums


# Commands

* *build*   - The main remote-runner script. Most of the features are located as sub-commands of this program.
* *install* - The daemonized form of rr.  Will run rr subcommands on a regular interval, with extra error checking.
* *list*      - An alias to "rr cmd".
* *show*      - An alias to "rr run". 
* *uninstall* - A tar wrapper that facilitates in the packaging of files.

# Installation

* Install the current version.
	
	curl https://raw.github.com/pkopriv2/remote-runner/master/install.sh | bash -s 

* Install a specific version.

	curl https://raw.github.com/pkopriv2/remote-runner/master/install.sh | bash -s "1.0.0"

# Usage

1. Create an ssh public/private key pair.
	
	rr key create home

2. Bootstrap a host with the key.

	rr host boostrap root@localhost home

3. Create an archive (This is a repo for remote scripts)

	pushd ~
	rr archive create test
	rr archive install test
	popd

4. Edit the archive

	rrcd test
	cat - > scripts/default.sh <<-EOF
	log_info "Hello, world.  I am on \$HOSTNAME!"

	file "~/test.txt"<<-FILE
		contents "hello, world"
	FILE
	EOF

5. Run the archive!

	rrr --host root@localhost --archive test 
