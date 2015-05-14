#!/bin/sh

ENV_TYPE="$3"

. `dirname $0`/configuration.sh
. `dirname $0`/functions.sh

# Usage: rollback.sh TABLE_NAME FROM_VALUE ENV

HOOK=`dirname $0`/hooks/$1.sh

if [ -f "$HOOK" ]; then
    . "$HOOK"
fi

pre_rollback_hook $DB $1 $2

import_from_date $DB $1 $2

post_rollback_hook $DB $1 $2

