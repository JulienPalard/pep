#!/bin/sh

URL='http://svn.python.org/projects/peps/trunk/'
PEP_PATH='/usr/share/doc/python-pep/'
PEP_REGEX='pep-[0-9]+\.txt'

upgrade()
{
    PROGRESS="$1"

    if [ "$(whoami)" != "root" ]
    then
        echo "You have to be root to upgrade Python PEPs." 1>&2
        exit 1
    fi
    mkdir -p "$PEP_PATH"
    cd "$PEP_PATH"
    LIST="$(wget -qO - $URL \
            | grep -oE \"$PEP_REGEX\") \
            | sort \
            | uniq)"
    LENGTH=$(echo "$LIST" | wc -l)
    COUNT=0
    [ -n "$PROGRESS" ] && echo Downloading PEPs...
    echo "$LIST" | while read PEP
    do
        COUNT=$((COUNT + 1))
        [ -n "$PROGRESS" ] && echo -n "\r$(($COUNT * 100 / $LENGTH))%"
        wget -qN $URL/$PEP
    done
    [ -n "$PROGRESS" ] && echo "\rDone !"
}

show()
{
    PEP_NUMBER="$(printf "%04i\n" $1)"
    pager "$PEP_PATH/pep-$PEP_NUMBER.txt"
}

search()
{
    cd "$PEP_PATH"
    grep --color=always "$1" *
}

case $1 in
    upgrade)
        upgrade $2
        ;;
    search)
        shift
        search $*
        ;;
    *)
        show $1
        ;;
esac