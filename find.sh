#!/bin/sh

ENV_TYPE="$3"

. `dirname $0`/configuration.sh
. `dirname $0`/functions.sh

# Usage: find.sh TABLE_NAME VALUE ENV

date_in_range_files $DB $1 $2

