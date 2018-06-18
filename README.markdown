next
====

Given a directory expected to contain one or more `.task` files, 
`next` will list check each file for uncompleted "todos".

A todo is a line which starts `* [ ]`, `+ [ ]`, or `- [ ]`, in the
style of [GitHub Flavored Markdown][gfm] task lists.

[gfm]: https://github.github.com/gfm/#task-list-items-extension-

By default, the directory is `$HOME/Documents/next`, this can be
overridden by setting the `NEXT_TASKS_DIR` environment variable.

The task files can contain metadata, by prefacing the file with
"front matter" -- a block surrounded by triple-backticks (```).

For example:

    ```
    title = Things to do
    ```

    * [ ] Do a thing
    * [ ] Do another thing

If a task contains subtasks (illustrated by indenting the following
tasks), `next` will sort them before the parent task.

For example, given a `thing.task` file:

    * [ ] Do the thing
        - [ ] Figure out the thing
        - [ ] Plan how to do the thing

`next` will output:

    thing:
        Figure out the thing
        Plan how to do the thing
        Do the thing


## Installing

    make install

## Running tests

    make test
