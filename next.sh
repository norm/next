#!/usr/bin/env bash

TASKS_DIR="${NEXT_TASKS_DIR:=${HOME}/Documents/next}"


function main {
    ensure_bash_version
    ensure_tasks_dir

    list_outstanding_todos 
}

function ensure_bash_version {
    if [ ${BASH_VERSION%%.*} -lt 4 ]; then
        echo "next requires bash 4 or greater"
        exit 10
    fi
}

function ensure_tasks_dir {
    install -d $TASKS_DIR
}

function all_todos {
    local file="$1"

    grep -E '^ *[*+-] +\[[ xX]\] +' "$file"
}

function outstanding_todos {
    local file="$1"

    all_todos "$1" \
        | grep -E '^ *[*+-] +\[ \] +' \
        | perl -nE 'm{^( *)[*+-] +\[ \] (.*)}; say $2;'
}

function list_outstanding_todos {
    for taskfile in $TASKS_DIR/*.task $TASKS_DIR/**/*.task; do
        local taskname="${taskfile#$TASKS_DIR/}"

        echo "${taskname%.*}:"
        outstanding_todos "$taskfile" \
            | sed -e 's/^/    /'
        echo ''
    done
}

main
