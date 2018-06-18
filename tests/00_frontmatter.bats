#!/usr/bin/env bats

source next.sh


@test "extract frontmatter from file" {
    local expected="\
        title = example
        tags = onetag twotag threetag four"

    run task_frontmatter tests/00_example.task
    diff -u \
        <(echo "$output") \
        <(echo "$expected" | sed -e 's/^        //')
}

@test "extract body from file" {
    local expected="\

        # Hello

        World."

    run task_body tests/00_example.task
    diff -u \
        <(echo "$output") \
        <(echo "$expected" | sed -e 's/^        //')
}

@test "extract body from file without frontmatter" {
    local expected="$(cat README.markdown)"

    run task_body README.markdown
    diff -u \
        <(echo "$output") \
        <(echo "$expected")
}
