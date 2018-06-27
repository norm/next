#!/usr/bin/env bash

TASKS_DIR="${NEXT_TASKS_DIR:=${HOME}/Documents/next}"
TASKS_EXTENSION="${NEXT_TASK_EXT:=task}"
TIMEOUT_INTERVAL="${NEXT_TIMEOUT:=120}"


function main {
    ensure_bash_version
    ensure_tasks_dir

    case "$1" in
        committer)  git_committer ;;
        *)          list_outstanding_todos ;;
    esac
}

function status_line {
    printf '\r%-79s\r' "$*"
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
    local todos

    local task_files=0
    local todo_count=0

    for taskfile in $TASKS_DIR/*.${TASKS_EXTENSION} $TASKS_DIR/**/*.${TASKS_EXTENSION}; do
        local taskname="${taskfile#$TASKS_DIR/}"

        # skip if this is an unexpanded glob (no matching task files)
        if [[ "$taskname" == "*.${TASKS_EXTENSION}"
              || "$taskname" == "**/*.${TASKS_EXTENSION}"
        ]]; then
            continue
        fi

        local stamp=$(next_date "$taskfile")
        local arch=$(task_frontmatter_key "$taskfile" archived)
        let task_files++

        if [ -n "$arch" ]; then
            continue
        fi
        if [ "$stamp" -gt "$now" ]; then
            continue
        fi

        todos=$(outstanding_todos "$taskfile")
        if [ -n "$todos" ]; then
            let todo_count++
            echo "${taskname%.*}:"
            echo "$todos" \
                | sed -e 's/^/    /'
            echo ''
        fi
    done

    if [ $task_files == 0 ]; then
        echo "-- no .${TASKS_EXTENSION} files found in ${TASKS_DIR}."
    elif [ $todo_count == 0 ]; then
        echo "-- no todos found in $task_files file(s)."
    fi
}

function handle_file_changes {
    # When a file has changed, sleep for a period then see if no further
    # changes have been made (to avoid creating many tiny commits when
    # actively editing notes). If no further changes have happened,
    # commit and push the current state.

    touch -t "$(date -r "$stamp" '+%Y%m%d%H%M.%S')" "$TIMESTAMP"

    (
        # run this part in a background subshell
        # so we're not blocking on each change
        sleep $TIMEOUT_INTERVAL

        local new_stamp="$(stat -f'%a' "$TIMESTAMP")"
        if [ $stamp = $new_stamp ]; then
            local changes="$(git status --porcelain)"
            if [ -n "$changes" ]; then
                status_line
                echo "$changes"
                # FIXME not necessarily master?
                git add . \
                    && git commit -m"Autocommited by next at $(date)" \
                    && git push origin master \
                    && echo ''
            else
                status_line
            fi
        fi
    ) &
}

function git_committer {
    cd ${TASKS_DIR}
    TIMESTAMP=$(mktemp)

    while read stamp full_path; do
        local path="${full_path##${TASKS_DIR}/}"

        # don't try processing file changes that are to do with git
        # (otherwise we'll enter a vicious circular mess)
        if [[ $path != .git* ]]; then
            status_line " -> $path"
            handle_file_changes
        fi
    done < <(fswatch -t -f '%s' .)
}


if [ "$0" = "${BASH_SOURCE[0]}" ]; then
    # run main if we are being executed as a script
    # (rather then sourced, eg in tests or by advanced shell users)
    main "$@"
fi
