#!/bin/bash

TIMESTAMP_FIELD="tstamp"

function pre_archive_hook() {
    _drop_indices $1 $2
}

function post_archive_hook() {
    _create_indices $1 $2
}

function pre_rollback_hook() {
    _drop_indices $1 $2
}

function post_rollback_hook() {
    _create_indices $1 $2
}

function _drop_indices() {
    DB=$1
    table=$2

    # mysql_query $DB "DROP INDEX event ON $table;"
    # mysql_query $DB "DROP INDEX recuidIdx ON $table;"
}

function _create_indices() {
    DB=$1
    table=$2

    # mysql_query $DB "CREATE INDEX event ON $table (userid, event_pid) USING BTREE;"
    # mysql_query $DB "CREATE INDEX recuidIdx ON $table (recuid, uid) USING BTREE;"
}
