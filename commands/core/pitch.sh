#!/bin/sh
#
# Manage the pitch sentence
#

#<configuration>
CODE='#p>'
TAG='pitch'
DEBUG=true

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
                available actions are : locate|get|add|update|remove
                'locate' display the line number where the pitch is/should be
                'get' display the current pitch (if defined)
                'add' add the pitch (see the INPUT section below)
                'update' update the pitch (see the INPUT section below)
                'remove' remove the pitch

    file        the shell file to use as the source and destination (will be written to)

OPTIONS:
    -l|--locate_with method     the way to locate the pitch in the file
                                methods available are : 2st-line|3rd-line|code|tag
                                '2st-line' is the second line of the file
                                '3rd-line' is the third line of the file
                                'code' is the first line starting with '$CODE'
                                'tag' is the line after the string '#<$TAG>'
                                the default method is auto-detect, with fallback to '3rd-line'

    -a|--insert_at position     if the 'code' or 'tag' is missing and they were the location method choosen
                                the program need to insert them somewhere in the file
                                this option tell how to do it
                                available method are : 1st-uncommented-line|before-usage
                                the default method is '1st-uncommented-line'

    -p|--pitch sentence         the pitch (don't forget to enclose the sentence with quotes in shell, because of spaces)
                                pitch can also be inputed from stdin (see the INPUT section below)

INPUT:
    The pitch can be specified by using the --pitch option or by inputing it from stdin.

EXAMPLE:
    $THIS_SCRIPT_NAME --pitch 'Helper script to write nice code' add superscript.sh

    echo 'Helper script to write nice code'|$THIS_SCRIPT_NAME add superscript.sh

    $THIS_SCRIPT_NAME add superscript.sh <<ENDPITCH
    Helper script to write nice code
    ENDPITCH

    The --pitch option is prioritary over the stdin input if both are used.

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

SHORT=hl:a:p:i
LONG=help,locate_with:,insert_at:,pitch:,in_place

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
        -l|--locate_with)
            method=$2
            shift 2
            ;;
        -a|--insert_at)
            position=$2
            shift 2
            ;;
        -p|--pitch)
        	pitch_option=1
            sentence="$2"
            shift 2
            ;;
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


#<help>
if [ ! -z "$help" ]
then
	usage
	exit 0
fi


#<defaults>
debug "Setting defaults values"
if [ "$method" = '' ]
then
	method='auto-detect'
fi
if [ "$position" = '' ]
then
	position='1st-uncommented-line'
fi


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
if ! echo "$method"|grep -q '^\(2st-line\|3rd-line\|code\|tag\|auto-detect\)$'
then
	error "Invalid method '$method'"
	usage
	exit 1
fi
if [ "$method" = 'auto-detect' ]
then
	if grep -q "^#<$TAG>" "$file"
	then
		method=tag
	elif grep -q "^$CODE" "$file"
	then
		method=code
	else
		method='3rd-line'
	fi
fi
if ! echo "$position"|grep -q '^\(1st-uncommented-line\|before-usage\)$'
then
	error "Invalid position '$position'"
	usage
	exit 1
fi
if [ -z "$pitch_option" -a "$action" = 'add' -o "$action" = 'update' ]
then
	echo "reading pitch sentence from stdin"
	read sentence
fi
if echo "$sentence"|grep -q '/'
then
	error "Slash '/' in pitch sentence are not yet supported (lacking escaping), sorry!" >&2
	exit 1
fi


#<summary>
if [ "$DEBUG" = 'true' -o "$DEBUG" = '1' ]
then
	cat <<ENDCAT
Summary:
                   file : $file
                 action : $action
          locate method : $method
    insert at position  : $position
                  pitch : $sentence
ENDCAT
fi

#<main>
debug "Entering main process"
case $action in
	locate)
		case $method in
			2nd-line) echo 2
			;;
			3rd-line) echo 3
			;;
			code)
				if ! grep -q "^$CODE" "$file"
				then
					error "Code '$CODE' not found"
					exit 5
				else
					grep -n "^$CODE" "$file"|head -n 1|awk -F ':' '{print $1}'
				fi
			;;
			tag)
				if ! grep -q "^#<$TAG>" "$file"
				then
					error "Tag '$TAG' not found"
					exit 5
				else
					grep -n "^#<$TAG>" "$file"|head -n 1|awk -F ':' '{print $1}'
				fi
			;;
			*) error "Invalid method '$method'" && usage && exit 1
			;;
		esac
	;;
	get)
		case $method in
			2nd-line|3rd-line)
				num=`echo "$method"|grep -o '^[23]'`
				line=`tail -n +$num "$file"|head -n 1`
				if ! echo "$line"|grep -q '^\(# \?.*\)\?$'
				then
					error "The line $num is not a comment a therefore is not a pitch"
					exit 5
				else
					echo "$line"|sed 's/^# \?//'
				fi
			;;
			code)
				if ! grep -q "^$CODE" "$file"
				then
					error "Code '$CODE' not found"
					exit 5
				else
					grep "^$CODE" "$file"|sed "s/^$CODE \?//"
				fi
			;;
			tag)
				if grep -q "^#<$TAG>" "$file"
				then
					tag_line_num=`grep -n "^#<$TAG>" "$file"|head -n 1|awk -F ':' '{print $1}'`
					next_line_num=`expr $tag_line_num + 1`
					next_line=`tail -n +$next_line_num "$file"|head -n 1`
					if echo "$next_line"|grep -q '^#\|^$'
					then
						echo "$next_line"|sed 's/^# \?//'
					else
						error "The line $num (next after the tag) is not a comment, therefore is not a pitch"
						exit 5
					fi
				else
					error "Tag '$TAG' not found"
					exit 5
				fi
			;;
			*) error "Invalid method '$method'" && usage && exit 1
			;;
		esac
	;;
	add|update)
		case $method in
			2nd-line|3rd-line)
				num=`echo "$method"|grep -o '^[23]'`
				line=`tail -n +$num "$file"|head -n 1`
				if ! echo "$line"|grep -q '^\(# \?.*\)\?$'
				then
					warning "The line $num is code (not comment). Inserting pitch the line above"
					sed "${num}i # $sentence\n" -i "$file"
				else
					sed "${num}s/.*/# $sentence/" -i "$file"
				fi
			;;
			code)
				if grep -q "^$CODE" "$file"
				then
					sed "s/^$CODE \?.*/$CODE $sentence/" -i "$file"
				elif [ "$method" = 'update' ]
				then
					exit 1
				else
					warning "No code '$CODE' found'. Inserting using position '$position'"
					case $position in
						1st-uncommented-line)
							first_uncommented_line="`grep -n '^[^#]\|^$' "$file"|head -n 1|awk -F ':' '{print $1}'`"
							sed "${first_uncommented_line}i $CODE $sentence" -i "$file"
						;;
						before-usage)
							usage_line=`grep -n '^usage()' "$file"|head -n 1|awk -F ':' '{print $1}'`
							sed "${usage_line}i $CODE $sentence" -i "$file"
						;;
					esac
				fi
			;;
			tag)
				if grep -q "^#<$TAG>" "$file"
				then
					tag_line_num=`grep -n "^#<$TAG>" "$file"|head -n 1|awk -F ':' '{print $1}'`
					next_line_num=`expr $tag_line_num + 1`
					next_line=`tail -n +$next_line_num "$file"|head -n 1`
					if echo "$next_line"|grep -q '^#'
					then
						sed "${next_line_num}s/.*/# $sentence/" -i "$file"
					elif echo "$next_line"|grep -q '^$'
					then
						sed "${next_line_num}i # $sentence" -i "$file"
					else
						warning "The line $num (next after the tag) is code (not comment). Inserting pitch line before it"
						sed "${next_line_num}i # $sentence" -i "$file"
					fi
				elif [ "$method" = 'update' ]
				then
					exit 1
				else
					warning "No tag '$TAG' found'. Inserting using position '$position'"
					case $position in
						1st-uncommented-line)
							first_uncommented_line="`grep -n '^[^#]\|^$' "$file"|head -n 1|awk -F ':' '{print $1}'`"
							sed "${first_uncommented_line}i #<$TAG>\n$sentence" -i "$file"
						;;
						before-usage)
							usage_line=`grep -n '^usage()' "$file"|head -n 1|awk -F ':' '{print $1}'`
							sed "${usage_line}i #<$TAG>\n$sentence" -i "$file"
						;;
					esac
				fi
			;;
			*) error "Invalid method '$method'" && usage && exit 1
			;;
		esac
		echo "`if [ "$action" = 'add' ]; then echo 'Added'; else echo 'Updated'; fi` pitch to '$file'"
	;;
	remove)
		case $method in
			2nd-line|3rd-line)
				num=`echo "$method"|grep -o '^[23]'`
				line=`tail -n +$num "$file"|head -n 1`
				if echo "$line"|grep -q '^#'
				then
					sed "${num}s/.*/# $sentence/" -i "$file"
				fi
			;;
			code)
				if grep -q "^$CODE" "$file"
				then
					sed "s/^$CODE \?.*/$CODE /" -i "$file"
				fi
			;;
			tag)
				if grep -q "^#<$TAG>" "$file"
				then
					tag_line_num=`grep -n "^#<$TAG>" "$file"|head -n 1|awk -F ':' '{print $1}'`
					next_line_num=`expr $tag_line_num + 1`
					next_line=`tail -n +$next_line_num "$file"|head -n 1`
					if echo "$next_line"|grep -q '^#'
					then
						sed "${next_line_num}d" -i "$file"
					elif echo "$next_line"|grep -q '^$'
					then
						echo >/dev/null # do nothing hack
					else
						warning "The line $num (next after the tag) is not a comment, therefore is not a pitch. Doing nothing"
					fi
				fi
			;;
		esac
		echo "Removed pitch from '$file'"
	;;
	*)
		error "Invalid action '$action'" && usage && exit 1
	;;
esac

