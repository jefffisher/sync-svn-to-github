#!/bin/sh

DIR=`dirname $0`/Public
GIT_DIR=`dirname $0`/orion-sdk
HEAD=HEAD

if [ "$#" -gt "0" ]; then HEAD=$1; fi

for REV in `svn log -q $DIR -rBASE:$HEAD | grep ^r | sed 's/^r\([0-9]*\).*/\1/' | tail +2`; do
    MSG="SVN r$REV: `svn log $DIR -c$REV --incremental | tail +4`"
    USER="`svn log $DIR -c$REV -q | grep ^r | cut -d' ' -f3`"
    DATE="`svn log $DIR -c$REV -q | grep ^r | cut -d' ' -f5-7`"

    case "$USER" in
        "bill.vaglienti") EMAIL="billvaglienti@gmail.com";;
        "ryan.vansickle") EMAIL="$USER@gmail.com";;
        *) EMAIL="$USER@trilliumeng.com";;
    esac

    svn up $DIR -r$REV | grep 'Public/.*$' | while read -r ENTRY; do
	SVN_FILE=`echo "$ENTRY" | grep -o Public/.*$`
        GIT_FILE=`echo "$SVN_FILE" | sed 's/Public/orion-sdk/'`
        BASE_PATH=`echo "$GIT_FILE" | sed 's/orion-sdk\///'`
        if [ "${ENTRY:0:1}" == "D" ]; then
            rm -rf "$GIT_FILE"
        elif [ ! -d "$GIT_FILE" ]; then
            cp -rf "$SVN_FILE" "$GIT_FILE"
        else
            cp -rf "$SVN_FILE/*" "$GIT_FILE"
        fi
        pushd $GIT_DIR > /dev/null
        git add "$BASE_PATH"
        popd > /dev/null
    done

    pushd $GIT_DIR > /dev/null
    GIT_COMMITTER_NAME="$USER" GIT_COMMITTER_EMAIL="$EMAIL" git commit -m "$MSG" --author="$USER <$EMAIL>" --date="$DATE"
    popd > /dev/null
done

pushd $GIT_DIR > /dev/null
git push
popd > /dev/null
