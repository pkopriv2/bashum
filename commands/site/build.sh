#! /usr/bin/env bash

require 'lib/bashum/cli/console.sh'
require 'lib/bashum/cli/options.sh'
require 'lib/bashum/lang/fail.sh'
require 'lib/bashum/site.sh'

site_build_usage() {
    echo "$bashum_cmd site build [options]"
}

site_build_help() {
    bold 'USAGE'
    echo 
    printf "\t"; site_build_usage
    echo


    bold 'DESCRIPTION'
    printf '%s' '
    Builds the site in the target directory.
'

    bold 'OPTIONS'
    printf '%s' '
    -None

'
}

site_build() {
    if options_is_help "$@" 
    then
        site_build_help "$@"
        exit $?
    fi

    bashum_site_build $(pwd)
}
