#!/bin/sh

#<pitch>
# Add variables that refers to the current script informations
#</pitch>

set -e

usage()
{
	cat <<ENDCAT
USAGE : $THIS_SCRIPT_NAME [--tag name] add|update|remove file

ARGUMENTS:
	add				add the reflection variables (in the tag)
	update			update (replace) the reflection variables (in the tag)
	remove			remove the reflection variables (in the tag)

OPTIONS:
	--tag name		the tag name to search for (or create if missing)
ENDCAT
}

# TODO code the injection and replacement of this block

cat <<ENDCAT
THIS_SCRIPT_NAME=\`basename "\$0"\`
THIS_SCRIPT_DIR=\`dirname "\$0"\`
THIS_SCRIPT_DIR_ABS=\`realpath "\$THIS_SCRIPT_DIR"\`
THIS_SCRIPT_NAME_ABS=\`basename "\$THIS_SCRIPT_DIR_ABS"\`
ENDCAT

