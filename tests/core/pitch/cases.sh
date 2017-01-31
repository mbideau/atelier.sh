#!/bin/sh

PITCH_SCRIPT=`dirname "$0"`/../../../commands/core/pitch.sh

echo "Testing pitch core function"

fail() {
	echo "FAIL $1\n   -> $2"
}

# should display usage
output=`sh "$PITCH_SCRIPT"`
return=$?
if [ $return -ne 1 ]
then
	fail no_args_should_exit_1_and_display_usage "return code is not 1 ($return)"
fi
if ! echo "$output"|grep -q 'Too few arguments'
then
	fail no_args_should_exit_1_and_display_usage "error message 'Too few arguments' is missing in the output"
fi
if ! echo "$output"|grep -q 'USAGE'
then
	fail no_args_should_exit_1_and_display_usage "usage is missing in the output"
fi

