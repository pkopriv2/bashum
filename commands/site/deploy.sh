#! commands/site_deploy.sh

export bashum_project_file=${bashum_project_file:-"project.sh"}

require 'lib/bashum/cli/console.sh'
require 'lib/bashum/cli/options.sh'
require 'lib/bashum/site.sh'

site_deploy_usage() {
    echo "$bashum_cmd site deploy [options]"
}

site_deploy_help() {
    bold 'USAGE'
    echo
    printf "\t"; deploy_usage
    echo


    bold 'DESCRIPTION'
    printf '%s' '
    Builds and deploys the site for the project in the current working directory 
    to either the snapshot (if its version is a snapshot) or the release repo (if
    its version is a release or no snapshot repo is given).

    The project file methods that define these repos are: 
    
        - site_release_repo <url>
        - site_snapshot_repo <url>
    
    Note: You must have push permissions for the deployment to work.
'

    bold 'OPTIONS'
    printf '%s' '
    - None 

'
}

site_deploy() {
    if options_is_help "$@"
    then
        site_deploy_help "$@"
        exit $?
    fi

    # determine if we're in an actual bashum-style project.
    if [[ ! -f $bashum_project_file ]]
    then
        error "Unable to locate project file: $bashum_project_file"
        exit 1
    fi

    info "Deploying site: " 
    echo 

    # okay, deploy the site
    bashum_site_deploy $(pwd) 
}
