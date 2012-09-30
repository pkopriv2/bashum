# See if bashum_home has been set.  If not, try to find it.
export bashum_home=$HOME/.bashum
export bashum_home=${bashum_home:-$HOME/.bashum}
export bashums_home=${bashums_home:-$bashum_home/bashums}

# update the global path.
if ! echo $PATH | grep -q $bashum_home 
then
	PATH=$PATH:$bashum_home/bin
fi

# source any extra environment scripts (provided by bashums)
for script in $(ls $bashum_home/*/env/*.sh)
do
	if [[ -f $script ]]
	then
		source $script
	fi
done
