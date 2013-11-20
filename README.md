# Bashum 

Finally, a package manager for bash - written in bash!  But it's much more
than a simple package manager.  Bashum is a complete development ecosystem 
for bash. 

For those who aren't all that interested in developing bash code, you can
still use bashum to use bash code.  I love writing bash tools and love 
giving them away.  Feel free to use bashum to install some of my stuff 
and let me know how things are working.

# Commands

* *build*         - Assembles the bashum project in the current working directory.
* *deploy*        - Assembles and deploys the bashum project in the current working directory.
* *install*       - Installs a bashum to the local bashum repo.
* *list*          - Lists the currently installed bashums.
* *remove*        - Uninstalls a bashum file.
* *remote add*    - Adds a repo to the list of remote repositories.
* *remote remove* - Removes a repo from the list of remote repositories.
* *remote list*   - Lists all the remote repositories.
* *run*           - Runs an executable under the current bashum project.
* *search*        - Searches the list of remote repositories for bashums to install.
* *show*          - Shows a detailed view of a bashum pacage, a .bashum file or a remote file.
* *test*          - Runs a subset of tests for the project.

# Dependencies

## Bash:4.x 
	
OSX: 
	
	sudo brew install bash
	sudo mv /bin/bash /bin/bash3
	sudo ln -s /usr/local/bin/bash /bin/bash
	
Linux:
	
	aptitude install bash

Windows:

	http://www.cygwin.com/ ( or just get smart and get Linux... )


## GNU Core Utils

OSX: 
	
	brew install coreutils

Linux:
	
	aptitude install coreutils

Windows:

	http://www.cygwin.com/ 
	
## GNU Tar

OSX: 
	
	brew install gnu-tar
	sudo mv /usr/bin/tar /usr/bin/tar-bsd
	sudo ln -s /usr/local/bin/gtar /usr/bin/tar

Linux:
	
	aptitude install tar

Windows:

	http://www.cygwin.com/ 

## Git 

OSX: 
	
	brew install git

Linux:
	
	aptitude install git-svn

Windows:

	http://www.cygwin.com/ 
	

# Installation

* Install the current version.
	
	curl https://raw.github.com/pkopriv2/bashum/master/install.sh | bash -s 

* Install a specific version.

	curl https://raw.github.com/pkopriv2/bashum/master/install.sh | bash -s "1.0.0"

Resource your bash environment.  Usually, just start a new terminal session.

## Installing Bashums

With the latest releast of bashum, installing packages has become incredibly easy.  To search for a
list of bashums to install, simply type: 
	
	bashum search <expression>

The search expressions are simply grep expressions - so feel free to use those regular expressions!
Once you have found a bashum to install, type: 

	bashum install <package> [--version <optional_version>]

And that's it! 

## Remote Repositories

By default, bashum is configured to search and install from a single remote repository 
(http://github.com/pkopriv2/bashum-main). If you'd like to checkout some tools that are
still in development:

	bashum remote add https://github.com/pkopriv2/bashum-snapshot.git

You may add as many repositories as you'd like by using:

	bashum remote add <url>

A bashum repository is nothing but a git repo, so feel free to make your own!  The only 
requirements are that the bashums sit at the root of the repo and they are named
with the following pattern: *\<name\>-\<version\>.bashum*, e.g.:

* /your-awesome-tool-1.0.0.bashum
* /your-amazing-tool-2.0.0.bashum

# Building a Bashum Project 

The standard set of bashum files are those that are assembled by default when building a bashum project:

* */project.sh*  The project descriptor file.  See below. [_required_]
* */bin/* Executable files.  When installed, these will automatically be on the path.
* */lib/* Library files.  These may be included in other bashum files. 
* */env/* Environment files.  These will be sourced in the current environment.  Library files may not be included in these files.

## /project.sh

The project.sh file is the only explicitly required file in a bashum project.  It is a bash-dsl 
that describes the project.  The following functions are available: 

* *name*          - The name of the project [_required_]
* *version*       - The version of the project [_required_]
* *author*        - The name of the author of the project
* *email*         - The email of the author
* *description*   - A short description of the project.  Should fit on a single line.
* *file*          - A 'non-standard' file that should also be assembled (can be a file - glob)
* *depends*       - Denotes a dependency that this project has on other bashum projects. Takes a name and an optional version.
* *snapshot_repo* - The url of the snapshot remote repository.
* *release_repo*  - The url of the release remote repository.

Example:

	name    "test-project"
	version "1.0.0-SNAPSHOT"
	author  "Preston Koprivica"
	email   "pkopriv2@gmail.com"

	file    "license.txt" 
	file    "lib2/*.sh" 

	depends "stdlib" 
	depends "other" "1.0.0"

	snapshot_repo "git@github.com:pkopriv2/bashum-snapshot.git"
	release_repo  "git@github.com:pkopriv2/bashum-main.git"
	
	
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


## Copyright

Copyright 2013 Preston Koprivica (pkopriv2@gmail.com)

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
