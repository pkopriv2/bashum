# /usr/bin/env bash

require 'lib/bashum/lang/string.sh' 

export bashum_tmp_dir=${bashum_tmp_dir:-/tmp/bashum_$(str_random)}

[[ -d $bashum_tmp_dir ]] || mkdir -p $bashum_tmp_dir

# cleanup on exit.
on_exit() {
	rm -r $bashum_tmp_dir
}; trap "on_exit" EXIT
