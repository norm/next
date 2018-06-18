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

function task_frontmatter {
    local file="$1"

    if head -1 "$file" | grep -q \`\`\`; then
        awk '
                /^```/ { t++; next; }
                t == 1 { print; }
            ' "$file"
    fi
}

function task_body {
    local file="$1"

    # skip frontmatter if it is there
    if head -1 "$file" | grep -q \`\`\`; then
        awk '
                /^```/ { t++; next }
                t == 2 { print; }
            ' "$file"
    else
        cat "$file"
    fi
}

function task_frontmatter_key {
    local file="$1"
    local key="$2"

    task_frontmatter "$file" | grep "$2" | sed -e 's/.*= *//'
}

function to_epoch {
    date -juf '%Y-%m-%d' "$1" +%s
}

function next_date {
    local file="$1"
    local date="$(task_frontmatter_key "$file" next)"

    if [ -z "$date" ]; then
        echo "0"
    else
        to_epoch "$date"
    fi
}

function all_todos {
    local file="$1"

    task_body "$file" \
        | grep -E '^ *[*+-] +\[[ xX]\] +'
}

function outstanding_todos {
    local file="$1"

    # list all the open todos -- where the todos are nested, they
    # are considered to be pre-requisites for completing the item
    # they are nested under, so they are sorted first
    all_todos "$1" \
        | grep -E '^ *[*+-] +\[ \] +' \
        | perl -nE 'm{^( *)[*+-] +\[ \] (.*)}; say length($1), " ", $2;' \
        | sort -s --reverse --numeric-sort --key=1 \
        | cut -d' ' -f2-
}

function list_outstanding_todos {
    local now=$(date +%s)

    for taskfile in $TASKS_DIR/*.task $TASKS_DIR/**/*.task; do
        local taskname="${taskfile#$TASKS_DIR/}"
        local stamp=$(next_date "$taskfile")
        local arch=$(task_frontmatter_key "$taskfile" archived)

        if [ -n "$arch" ]; then
            continue
        fi
        if [ "$stamp" -gt "$now" ]; then
            continue
        fi

        echo "${taskname%.*}:"
        outstanding_todos "$taskfile" \
            | sed -e 's/^/    /'
        echo ''
    done
}


if [ "$0" = "${BASH_SOURCE[0]}" ]; then
    # run main if we are being executed as a script
    # (rather then sourced, eg in tests or by advanced shell users)
    main
fi
