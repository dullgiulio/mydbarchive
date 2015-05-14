#!/bin/bash

TIMESTAMP_FIELD="uid"

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

    # mysql_query $DB "DROP INDEX recordident ON $table"
    # mysql_query $DB "DROP INDEX sys_log_uid ON $table"
}

function _create_indices() {
    DB=$1
    table=$2

    # mysql_query $DB "CREATE INDEX recordident ON $table (tablename, recuid, tstamp) USING BTREE"
    # mysql_query $DB "CREATE INDEX sys_log_uid ON $table (sys_log_uid) USING BTREE"
}
