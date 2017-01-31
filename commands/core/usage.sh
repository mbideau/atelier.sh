#!/bin/sh

#<pitch>
# Manage the usage() function
#</pitch>


set -e

#<reflection>
THIS_SCRIPT_NAME=`basename "$0"`
THIS_SCRIPT_DIR=`dirname "$0"`
THIS_SCRIPT_DIR_ABS=`realpath "$THIS_SCRIPT_DIR"`
THIS_SCRIPT_NAME_ABS=`basename "$THIS_SCRIPT_DIR_ABS"`
#</reflection>

usage()
{
	cat <<ENDCAT

ENDCAT
}

# TODO find a way to specify argument definition
# TODO find a way to add,update, and remove those definition in the existing usage function

cat <<ENDCAT
usage()
{

}
ENDCAT
