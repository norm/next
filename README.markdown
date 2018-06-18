next
====

Given a directory expected to contain one or more `.task` files, 
`next` will list check each file for uncompleted "todos".

A todo is a line which starts `* [ ]`, `+ [ ]`, or `- [ ]`, in the
style of [GitHub Flavored Markdown][gfm] task lists.

[gfm]: https://github.github.com/gfm/#task-list-items-extension-

By default, the directory is `$HOME/Documents/next`, this can be
overridden by setting the `NEXT_TASKS_DIR` environment variable.


## Installing

    make install

## Running tests

    make test
