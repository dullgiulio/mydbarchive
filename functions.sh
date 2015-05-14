#!/bin/bash

function _get_numbers() {
    filename=`basename "$1"`
    filename=${filename/$table-/}
    echo ${filename/.sql.gz/}
}

function mysql_query() {
    database=$1
    query=$2   

     mysql -u $USER -p"$PASSWORD" -h $HOST -P $PORT --database $database \
           -e "$query" 
}

function archive_table() {
    database=$1
    table=$2
    beginning=$3
    end=$4
   
    mkdir -p "$database/$table/"
 
    outfile="`printf '%s/%s/%s/%s-%012d-%012d.sql' \"$BASE\" \"$database\" \"$table\" \"$table\" \"$beginning\" \"$end\"`"

    mysqldump -u $USER -p"$PASSWORD" -h $HOST -P $PORT --database $database --tables "$table" \
            --no-create-db --no-create-info --skip-add-locks --skip-comments \
            --lock-tables=false --extended-insert=FALSE --complete-insert=TRUE \
            --where "$TIMESTAMP_FIELD >= $beginning AND $TIMESTAMP_FIELD < $end" >$outfile
    gzip -9 $outfile    
}

function delete_archived() {
    database=$1
    table=$2
    beginning=$3
    end=$4

    mysql_query $database "DELETE FROM $table WHERE $TIMESTAMP_FIELD >= $beginning AND $TIMESTAMP_FIELD < $end"
}

function date_in_range() {
    date_ts=$1
    beginning=$2
    end=$3

    if [ $date_ts -ge $beginning ] && [ $date_ts -lt $end ]; then
        return 0 # Opposite booleans in shell.
    else
        return 1
    fi
}

function date_in_range_files() {
    database=$1
    table=$2
    date=$3

    ls -1 $database/$table/ | grep "^$table" | while read ofilename; do
        filename=$(_get_numbers $ofilename)       

        beginning=`echo $filename | cut -d'-' -f1`
        end=`echo $filename | cut -d'-' -f2`

        if date_in_range $date $beginning $end ; then
            echo "$database/$table/$ofilename"
            return 0
        fi 
    done
}

function latest_saved_date() {
    database=$1
    table=$2

    ls -1 $database/$table/ | grep "^$table" | while read ofilename; do
        echo $(_get_numbers $ofilename) | cut -d'-' -f2
    done | sort -n | tail -1
}

function beginning_of_time() {
    database=$1
    table=$2

    mysql -u $USER -p"$PASSWORD" -h $HOST -P $PORT --database $database \
          -B -e "SELECT MIN($TIMESTAMP_FIELD) FROM $table;" | tail -1
}

function end_of_time() {
    database=$1
    table=$2

    mysql -u $USER -p"$PASSWORD" -h $HOST -P $PORT --database $database \
          -B -e "SELECT MAX($TIMESTAMP_FIELD) FROM $table;" | tail -1
}

function extract_before_interval() {
    database=$1
    table=$2
    interval=$3

    beginning=$(beginning_of_time $database $table)
    end=$(end_of_time $database $table)
    start=$beginning

    seq $beginning $interval $end | tail -n +2 | \
    while read end; do
        archive_table $database $table $start $end
        # delete_archived $database $table $start $end
    
        start=$(expr $end + 1)
    done
}

function import_file() {
    filename=$1

    echo -n "Importing $filename ... "

    zcat $filename | mysql -u $USER -p"$PASSWORD" -h $HOST -P $PORT --database $database
    rm $filename

    echo "done."
}

function import_from_date() {
    database=$1
    table=$2
    beginning=$3

    first_file=$(date_in_range_files $database $table $beginning)
    
    if [ "$first_file" = "" ]; then
        echo "Date not found in any file."
        return 1
    fi

    filename=$(_get_numbers $first_file)
    end=$(echo $filename | cut -d'-' -f2)

    import_file $first_file
    
    ls -1 $database/$table/ | grep "^$table" | sort -n | while read ofilename; do
        filename=$(_get_numbers $ofilename)    
        fbeginning=$(echo $filename | cut -d'-' -f1)

        if [ $fbeginning -ge $end ]; then
            import_file $database/$table/$ofilename
        fi
    done
}

## Copies to archive records from date1 to date2
# archive_table $DB sys_log 1355472695 1355478371

## Deletes records between date1 and date2
# delete_archived $DB sys_log 1355472695 1355478371 

## Get the date of the latest saved record
# latest_saved_date $DB sys_log

## COMMAND: Extracts (archives and deletes) from the beginning to end end - interval.
# extract_before_interval $DB sys_log $((60*60*24*7))

## COMMAND: Finds the file that contains the record for a certain timestamp.
# date_in_range_files $DB sys_log 1355419799

## COMMAND: Import all archived records from date
# import_from_date $DB sys_log 1355383808
