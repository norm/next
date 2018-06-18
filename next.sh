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

function all_todos {
    local file="$1"

    task_body "$file" \
        | grep -E '^ *[*+-] +\[[ xX]\] +'
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


if [ "$0" = "${BASH_SOURCE[0]}" ]; then
    # run main if we are being executed as a script
    # (rather then sourced, eg in tests or by advanced shell users)
    main
fi
