#! commands/deploy.sh

export bashum_project_file=${bashum_project_file:-"project.sh"}

require 'lib/bashum/cli/console.sh'
require 'lib/bashum/cli/options.sh'
require 'lib/bashum/deploy.sh'

deploy_usage() {
	echo "$bashum_cmd deploy [options]"
}

deploy_help() {
	bold 'USAGE'
	echo
	printf "\t"; deploy_usage
	echo


	bold 'DESCRIPTION'
	printf '%s' '
	Deploys the project in the current working directory to either the 
	snapshot (if its version is a snapshot) or the release repo (if
	its version is a release or no snapshot repo is given).

	The project file methods that define these repos are: 
	
	    - snapshot_repo <url>
	    - release_repo <url>
	
	Note: You must have push permissions for the deployment to work.
'

	bold 'OPTIONS'
	printf '%s' '
	- None 

'
}

deploy() {
	if options_is_help "$@"
	then
		deploy_help "$@"
		exit $?
	fi

	# determine if we're in an actual bashum-style project.
	if [[ ! -f $bashum_project_file ]]
	then
		error "Unable to locate project file: $bashum_project_file"
		exit 1
	fi

	# package up everything.
	info "Deploying project: " 
	echo 

	# load the project file.
	project_file_print "$bashum_project_file" 

	# okay, deploy the bashum
	deploy_project
}
