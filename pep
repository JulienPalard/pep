#!/bin/sh

PEP_REPOSITORY='http://svn.python.org/projects/peps/trunk/'
LOCAL_PEP_PATH='/usr/share/doc/python-pep/'
PEP_REGEX='pep-[0-9]+\.txt'

fail_due_to_rights()
{
    echo "Failed to upgrade local PEPs repository" >&2
    echo "As your LOCAL_PEP_PATH is $LOCAL_PEP_PATH and it's nor writeable" >&2
    echo "Shouldn't you try to run it as root ?" >&2
    exit 1
}

upgrade()
{
    PROGRESS="$1"

    mkdir -p "$LOCAL_PEP_PATH" 2>/dev/null
    [ -w "$LOCAL_PEP_PATH" ] || fail_due_to_rights
    cd "$LOCAL_PEP_PATH"
    LIST="$(wget -qO - $PEP_REPOSITORY \
            | grep -oE "$PEP_REGEX" \
            | sort | uniq)"
    LENGTH=$(printf "%s" "$LIST" | wc -l)
    COUNT=0
    [ -n "$PROGRESS" ] && echo "Downloading PEPs..."
    printf "%s\n" "$LIST" | while read PEP
    do
        COUNT=$((COUNT + 1))
        [ -n "$PROGRESS" ] && echo -n "\r$(($COUNT * 100 / $LENGTH))%"
        wget -qN "$PEP_REPOSITORY/$PEP"
    done
    [ -n "$PROGRESS" ] && echo "\rDone !"
}

show()
{
    PEP_NUMBER="$(printf "%04i\n" $1)"
    PEP_FILE="$LOCAL_PEP_PATH/pep-$PEP_NUMBER.txt"

    if [ -f "$PEP_FILE" ]
    then
        pager "$LOCAL_PEP_PATH/pep-$PEP_NUMBER.txt"
    else
        echo "PEP $PEP_NUMBER is not found in the local PEPs repository" >&2
        echo "Try '$0 upgrade with progress' to fetch it from the internet" >&2
    fi
}

search()
{
    cd "$LOCAL_PEP_PATH"
    grep --color=always $* * | sed 's/.txt//'
}

help()
{
    cat <<HELP
Usage:
    Reading a PEP :
      $ $0 PEP_NUMBER
    example:
      $ $0 8

    Upgrading local PEPs repository :
      $ $0 upgrade
    Or the verbose version:
      $ $0 upgrade with progress

    Searching for a word / regex into PEPs :
      $ $0 search [OPTIONS] PATTERN
    Search uses grep, so all grep options are available here, examples :
      $ $0 search guido | head -n 1
      pep-0007.txt:Author: guido@python.org (Guido van Rossum)
      $ $0 search -i guido
      pep-0001:Dictator for Life, Guido van Rossum) can be consulted during the
      $ $0 search -Ei ros{2}um | head -n 1
      pep-0001:Dictator for Life, Guido van Rossum) can be consulted during the
HELP
}

case $1 in
    "" | "-h" | "--help")
        help
        ;;
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
