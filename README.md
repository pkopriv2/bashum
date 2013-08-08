# Bashum 

Finally, a package manager for bash, written in bash!  Bashum provides
support for building, installing and managing .bashums


# Commands

* *build*   - Assembles the bashum project in the current working directory.
* *install* - Installs a bashum to the local bashum repo.
* *list*    - Lists the currently installed bashums.
* *show*    - Shows a detailed view of a bashum pacage, a .bashum file or a remote file.
* *remove*  - Uninstalls a bashum file.
* *run*     - Runs an executable under the current bashum project.
* *test*    - Runs a subset of tests for the project.

# Dependencies

## Bash:4.x 
	
OSX: 
	
	sudo brew install bash
	sudo mv /usr/bin/bash /usr/bin/bash3
	sudo ln -s /usr/local/bin/bash /usr/bin/bash

Linux:
	
	aptitude install bash

Windows:

	http://www.cygwin.com/ ( or just get smart and get Linux... )


## GNU Core Utils

OSX: 
	
	sudo brew install coreutils

Linux:
	
	aptitude install coreutils

Windows:

	http://www.cygwin.com/ 
	
## GNU Tar

OSX: 
	
	sudo brew install gnu-tar
	sudo mv /usr/bin/tar /usr/bin/tar-bsd
	sudo ln -s /usr/local/bin/gtar /usr/bin/tar

Linux:
	
	aptitude install tar

Windows:

	http://www.cygwin.com/ 
	

# Installation

* Install the current version.
	
	curl https://raw.github.com/pkopriv2/bashum/master/install.sh | bash -s 

* Install a specific version.

	curl https://raw.github.com/pkopriv2/bashum/master/install.sh | bash -s "1.0.0"

Resource your bash environment.  Usually, just start a new terminal session.

# Building a Bashum Project 

The standard set of bashum files are those that are assembled by default when building a bashum project:

* */project.sh*  The project descriptor file.  See below. [_required_]
* */bin/* Executable files.  When installed, these will automatically be on the path.
* */lib/* Library files.  These may be included in other bashum files. 
* */env/* Environment files.  These will be sourced in the current environment.  Library files may not be included in these files.

## /project.sh

The project.sh file is the only explicitly required file in a bashum project.  It is a bash-dsl 
that describes the project.  The following functions are available: 

* *name*         - The name of the project [_required_]
* *version*      - The version of the project [_required_]
* *author*       - The name of the author of the project
* *email*        - The email of the author
* *description*  - A short description of the project.  Should fit on a single line.
* *file*         - A 'non-standard' file that should also be assembled (can be a file-glob)
* *depends*      - Denotes a dependency that this project has on other bashum projects. Takes a name and an optional version. 

Example:

	name    "test-project"
	version "1.0.0-SNAPSHOT"
	author  "Preston Koprivica"
	email   "pkopriv2@gmail.com"

	file    "license.txt" 
	file    "lib2/*.sh" 

	depends "stdlib" 
	depends "other" "1.0.0"

## Requiring other files

For the most part, bashum tries to be transparent to the current environment.  Things should just work.  However,
a custom "require" function is available _all_ bashum projects and libraries.  Within the project itself, the files
are referenced relative to the _root_ of the project.  When referencing other projects, you must first require the
project, then files relative to the project.

Example:

Given the following project:

* /bin/test
* /lib/lib.sh

/bin/test: 

	require_bashum 'stdlib'    # imports the stdlib bashum. (require 'stdlib' would work too) 
	
	require 'lib/lib.sh'       # imports the lib.sh in this project.	
	require 'lib/console.sh'   # imports the stdlib console. 
