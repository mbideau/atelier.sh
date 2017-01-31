#!/bin/sh
#
# TODO insert the pitch sentence here
#

#<configuration>
DEBUG=true
# TODO insert the configuration here

#<reflection>
THIS_SCRIPT_NAME=`basename "$0"`
THIS_SCRIPT_DIR=`dirname "$0"`
THIS_SCRIPT_DIR_ABS=`realpath "$THIS_SCRIPT_DIR"`
THIS_SCRIPT_NAME_ABS=`basename "$THIS_SCRIPT_DIR_ABS"`


usage()
{
	cat <<ENDCAT
USAGE:
    $THIS_SCRIPT_NAME OPTIONS action file

ARGUMENTS:
    action      the name of the action to execute
                available actions are : TODO insert the available actions here
                TODO describe each action here

    file        the file to use

    TODO add,modify,remove arguments according to your needs

OPTIONS:
    -h|--help 					display this help

    TODO insert your options here

EXAMPLE:
	TODO insert your usage example here

ENDCAT
}


#<core>
debug()   {
	if [ "$DEBUG" = 'true' -o "$DEBUG" = '1' ]; then echo "[`date "+%H:%M:%S"`]   DEBUG   $1"; fi
}
warning() {
	echo "[`date "+%H:%M:%S"`]  WARNING  $1" >&2
}
error()   {
	echo "[`date "+%H:%M:%S"`]   ERROR   $1" >&2
}


#<arguments>
debug "Parsing arguments"
set +e
getopt --test > /dev/null
return=$?
set -e
if [ $return -ne 4 ]
then
    error "Unable to parse arguments/options because of missing enhanced getopt"
    exit 1
fi

# TODO insert your argument and options definition here
# TODO use comma as separator and semi-colon when a value is required
SHORT=h
LONG=help

# @see : http://stackoverflow.com/questions/192249/how-do-i-parse-command-line-arguments-in-bash (2nd awnser)
# temporarily store output to be able to check for errors
# activate advanced mode getopt quoting e.g. via “--options”
# pass arguments only via   -- "$@"   to separate them correctly
PARSED=`getopt --options $SHORT --longoptions $LONG --name "$0" -- "$@"`
if [ $? -ne 0 ]; then
    # e.g. $? == 1
    #  then getopt has complained about wrong arguments to stdout
    exit 3
fi
# use eval with "$PARSED" to properly handle the quoting
eval set -- "$PARSED"

# now enjoy the options in order and nicely split until we see --
while true; do
    case "$1" in
        -h|--help)
            help=1
            break
        ;;
	# TODO insert your options parsing here
	# TODO use shift when no value is expected, and shift 2 when the option has a value
	# TODO for option that has a value, the value is in the $2 
        --)
            shift
            break
        ;;
        *)
            echo "Programming error"
            exit 4
        ;;
    esac
done

# handle non-option arguments
action=$1
file=$2
# TODO insert here your arguments

#<help>
if [ ! -z "$help" ]
then
	usage
	exit 0
fi


#<defaults>
debug "Setting defaults values"
# TODO insert here your default value (if value where not specified)

#<checks>
debug "Checking arguments and options values"
if [ $# -lt 2 ]
then
    error "Too few arguments"
	usage
    exit 2
elif [ $# -gt 2 ]
then
    error "Too many arguments"
	usage
    exit 2
fi
if [ ! -f "$file" ]
then
	error "File '$file' doesn't exist"
	exit 1
fi
# TODO insert here your arguments and options checks


#<summary>
if [ "$DEBUG" = 'true' -o "$DEBUG" = '1' ]
then
	cat <<ENDCAT
Summary:
                   file : $file
                 action : $action
                 TODO insert here other arguments and options
ENDCAT
fi

#<main>
debug "Entering main process"
case $action in
	# TODO insert your processing here
	*)
		error "Invalid action '$action'" && usage && exit 1
	;;
esac

