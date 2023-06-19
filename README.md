## Introduction

This was originally a fork of [vim-crystal](https://github.com/vim-crystal/vim-crystal) that discarded many of the original's features in order to study how syntax highlighting and indentation could be improved. It turned into a complete rewrite of the original plugin and merging my changes was no longer feasible, so I decided to move it to a separate repository for anyone who wants a faster and more accurate alternative to the original vim-crystal.

This plugin includes support for [embedded crystal (ECR)](https://crystal-lang.org/api/latest/ECR.html).

## Installation

This is a standard Vim plugin which can be installed using your plugin manager of choice. If you do not already have a plugin manager, I recommend [vim-plug](https://github.com/junegunn/vim-plug).

## Configuration

#### `g:crystal_simple_indent`

The default indentation style used by this plugin is the one most commonly found in the Crystal community, which allows for "hanging" or "floating" indentation. Some examples:

~~~crystal
x = if y
      5
    else
      10
    end

x = begin
      h["foo"]
    rescue KeyError
      "Not found"
    end

x = case y
    when :foo
      5
    when :bar
      10
    else
      1
    end

x = [:foo, :bar,
     :baz, :qux]

x = 5 + 10 +
    15 + 20 -
    5 * 3

x = y.foo
     .bar
     .baz
~~~

For those who prefer a more traditional indentation style or who desire slightly faster highlighting and indentation, set `g:crystal_simple_indent` to `1`. The above examples will now be indented thus:

~~~crystal
x = if y
  5
else
  10
end

x = begin
  h["foo"]
rescue KeyError
  "Not Found"
end

x = case y
when :foo
  5
when :bar
  10
else
  1
end

x = [:foo, :bar,
  :baz, :qux]
# OR
x = [
  :foo, :bar,
  :baz, :qux
]

x = 5 + 10 +
  15 + 20 -
  5 * 3
# OR
x =
  5 + 10 +
  15 + 20 -
  5 * 3

x = y.foo
  .bar
  .baz
# OR
x = y
  .foo
  .bar
  .baz
~~~

#### `g:crystal_markdown_comments`

This variable controls whether or not Markdown should be highlighted in comments; it can have three possible values:

* `0`: Disabled
* `1`: Enabled (default)
* `2`: Enabled; additionally, code lines &mdash; that is, lines that begin with at least four spaces or one tab or are inside of a fenced code block (delimited with ` ``` ` or `~~~`) &mdash; will be highlighted as Crystal code unless the language for the block is set to anything other than `crystal` (good for writing documentation)

Setting to `0` may cause highlighting to become faster in files with lots of comments, while setting to `2` may do the opposite.

NOTE: I haven't yet been able to find an exhaustive summary of which Markdown features are supported by Crystal, so for now, only the basic features are supported in addition to fenced code blocks (delimited with ` ``` ` or `~~~`).

Additionally, the only decorations that are currently allowed to span multiple lines are fenced code blocks. For example, the following will not be highlighted properly:

~~~crystal
# `1 + 2 +
# 3`
~~~

But this will:

~~~crystal
# ```
# 1 + 2 +
# 3
# ```
~~~

#### `g:ecrystal_extensions`

This plugin uses a dictionary of filetype extensions to determine which filetype to use when loading ECR files. For example, opening a file named `foo.html.ecr` will load HTML as the filetype with ECR syntax added on top.

The default recognized filetype extensions are as follows:

~~~
.html => html
.js => javascript
~~~

Each extension maps to the name of the filetype that you want to load for that extension.

To add or overwrite entries in the dictionary, set `g:ecrystal_extensions` to a dictionary with the entries you want to inject. For example, the following would allow the plugin to recognize `*.md` files as Markdown:

~~~vim
let g:ecrystal_extensions = #{ md: "markdown" }
~~~

If no subtype is specified in the file name itself (e.g., `foo.ecr`), the value of `g:ecrystal_default_subtype` is used as the subtype.

#### `g:ecrystal_default_subtype`

Determines the default subtype to use for ECR files when no subtype is specified in the file name itself (e.g., `foo.ecr`).

The default value is `html`. Setting this to nothing (`let g:ecrystal_default_subtype = ""`) will cause no subtype to be used.
