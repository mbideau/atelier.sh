#!/bin/sh
#
# Manage argument definition and parsing
#

set -e

# TODO build the variable that needs to be injected
# TODO find a way to add,update, and remove elements from an exisiting code

cat <<ENDCAT
debug "Parsing arguments"
set +e
getopt --test > /dev/null
return=\$?
set -e
if [ \$return -ne 4 ] 
then
    error "Unable to parse arguments/options because of missing enhanced getopt"
    exit 1
fi

SHORT=$ARGS_SHORT_DEF
LONG=$ARGS_LONG_DEF

# @see : http://stackoverflow.com/questions/192249/how-do-i-parse-command-line-arguments-in-bash (
# temporarily store output to be able to check for errors
# activate advanced mode getopt quoting e.g. via “--options”
# pass arguments only via   -- "\$@"   to separate them correctly
PARSED=\`getopt --options \$SHORT --longoptions \$LONG --name "\$0" -- "\$@"\`
if [ \$? -ne 0 ]; then
    # e.g. \$? == 1
    #  then getopt has complained about wrong arguments to stdout
    exit 3
fi
# use eval with "\$PARSED" to properly handle the quoting
eval set -- "\$PARSED"

# now enjoy the options in order and nicely split until we see --
while true; do
    case "\$1" in
		$INJECT_OPTIONS_PROCESSING
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
$INJECT_ARGUMENTS_DEFINITION

ENDCAT

