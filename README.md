# Bashum 

Finally, a package manager for bash, written in bash!  Bashum provides
support for building, installing and managing .bashums


# Commands

* *build*     - Assembles the bashum project in the current working directory.
* *install*   - Installs a bashum to the local bashum repo.
* *list*      - Lists the currently installed bashums.
* *show*      - Shows a detailed view of a bashum pacage, a .bashum file or a remote file. 
* *uninstall* - Uninstalls a bashum file.

# Installation

* Install the current version.
	
	curl https://raw.github.com/pkopriv2/bashum/master/install.sh | bash -s 

* Install a specific version.

	curl https://raw.github.com/pkopriv2/bashum/master/install.sh | bash -s "1.0.0"

# Building a Bashum Project 

The standard set of bashum files are those that are assembled by default when building a bashum project:

* */project.sh*  The project descriptor file.  See below. [_required_]
* */bin/* Executable files.  When installed, these will automatically be on the path.
* */lib/* Library files.  These may be included in other bashum files. 
* */env/* Environment files.  These will be sourced in the current environment.  Library files may not be included in these files.

## Project.sh

The project.sh file is the only explicitly required file in a bashum project.  It is a bash-dsl 
that describes the project.  The following functions are available: 

* *name*  The name of the project [_required_]
* *version*  The version of the project [_required_]
* *author* The name of the author of the project
* *email* The email of the author
* *description* A short description of the project.  Should fit on a single line.
* *file*  A 'non-standard' file that should also be assembled (can be a file-glob)
* *depends* Denotes a dependency that this project has on other bashum projects. Takes a name and an optional version. 

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
are referenced 


