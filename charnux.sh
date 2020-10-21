#!/bin/bash
##Adapt file/direcory names for UNIX environment (Wed  7 Oct 19:03:03 CEST 2020)
##Will only keep in a file/directory name:
##		-dashes (-)
##		-letters (a-Z)
##		-digits (0-9)
##		-periods (.)
##		-slashes (/)
##		-underscores (_)
##		-blank spaces ( )
##only it the target does not exist

##############################OPTIONS##############################
usage() { echo "$0 usage:" && grep " .)\ #" $0; exit 0; }
declare -i doFiles=0
declare -i doDires=0
declare -i depth=0
while getopts ":fdp:h" o; do
    case "${o}" in
        f) # Choose only files
            doFiles=1
            ;;
        d) # Choose only directories
            doDires=1
            ;;
        p) # Depth of subdirectories
            depth=OPTARG
            ;;
        h | *) # Show help.
            usage
            ;;
    esac
done
shift $((OPTIND-1))
name=$1
name=${name:-.}
##############################-------##############################
function replacenames() {
	old=$1
	new=$(echo $old | sed -E "s/[^-a-zA-Z0-9\.\/_\S]//g")
	if [ "$old" != "$new" ];then
		if [ !  -f "$new" -a ! -d "$new" ];then
			echo $old" ---> "$new
			mv -n "$old" "$new"
		else
			echo "File or directory $new already exists, $old will NOT be renamed!" >&2
		fi
	else
		echo "x"
	fi
}

export -f replacenames

if [ $doFiles -eq 1 -a $doDires -eq 1 ];then
	find "$name" -maxdepth $depth -exec bash -c 'replacenames "$1"' bash {} \;
elif [ $doFiles -eq 1 ];then
	find "$name" -maxdepth $depth -type f -exec bash -c 'replacenames "$1"' bash {} \;
elif [ $doDires -eq 1 ];then
	find "$name" -maxdepth $depth -type d -exec bash -c 'replacenames "$1"' bash {}  \;
else
	echo "Nothing to do!"
fi
