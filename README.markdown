next
====

Given a directory expected to contain one or more `.task` files, 
`next` will list check each file for uncompleted "todos".

A todo is a line which starts `* [ ]`, `+ [ ]`, or `- [ ]`, in the
style of [GitHub Flavored Markdown][gfm] task lists.

[gfm]: https://github.github.com/gfm/#task-list-items-extension-

By default, the directory is `$HOME/Documents/next`, this can be
overridden by setting the `NEXT_TASKS_DIR` environment variable.

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


## Postponing tasks

The task files can contain metadata, by prefacing the file with
"front matter" -- a block surrounded by triple-backticks (```).

By adding a date (using the key `next`) to a task's metadata, that task
and all of its todos will be ignored while that date is in the future.

For example:

    ```
    title = Things to do
    next = 2030-01-01
    ```

    * [ ] Do a thing
    * [ ] Do another thing


## Archiving tasks

A task file can be archived by adding a key `archived` to the metadata,
with a non-empty value. The value is ignored.

For example:

    ```
    next = 2012-01-1
    archived = true
    ```

    # Stuff.

    * [ ] This is no longer a todo that will be surfaced.


## Installing

    make install

## Running tests

    make test
