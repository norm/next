#!/usr/bin/env bats


@test "list outstanding tasks" {
    local expected="\
        things:
            a thing to do

        sub/more_things:
            another thing to do
            pluses are things to do
            hyphens are things to do too"

    NEXT_TASKS_DIR=tests/tasks run ./next.sh
    diff -u \
        <(echo "$output") \
        <(echo "$expected" | sed -e 's/^        //')
}
