#!/bin/sh

ENV_TYPE="$3"
BASE="`dirname $0`"

. $BASE/configuration.sh
. $BASE/functions.sh

# Usage: archive.sh TABLE_NAME INERVAL ENV

HOOK=$BASE/hooks/$1.sh

if [ -f "$HOOK" ]; then
    . "$HOOK"
fi

pre_archive_hook $DB $1 $2

extract_before_interval $DB $1 $2

post_archive_hook $DB $1 $2

