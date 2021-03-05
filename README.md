## Introduction

This was originally a fork of [vim-crystal](https://github.com/vim-crystal/vim-crystal) that discarded many of the original's features in order to study how syntax highlighting and indentation could be improved. It turned into a complete rewrite of the original plugin and merging my changes was no longer feasible, so I decided to move it to a separate repository for anyone who wants a faster and more accurate alternative to the original vim-crystal.

## Configuration

NOTE: The following variables are read only when this plugin is first loaded, so in order for any changes to take effect, you must place them in `.vimrc` or some other file loaded on startup and then restart Vim.

### `g:crystal_simple_indent`

The default indentation style used by this plugin is the one most commonly found in the Crystal community, which allows for "hanging" or "floating" indentation. Some examples:

```
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
```

This style is popular, but it can cause indentation to be slower in some cases, since many previous lines may have to be examined in order to determine the indentation for a given line.

For those who prefer a more traditional indentation style or who desire faster indentation, set `g:crystal_simple_indent` to `1`. The above examples will now be indented thus:

```
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
```

### `g:crystal_fold`

If `1`, definition blocks for methods, classes, etc. will be folded.

### `g:crystal_highlight_definitions`

If `1`, definition keywords &mdash; `def`, `macro`, `class`, `module`, `struct`, `lib`, `enum`, and `annotation` &mdash; will be highlighted differently than other keywords like `if` and `while`.

NOTE: Setting this has no effect if `g:crystal_fold` has been set, since this is required for folding to work properly; it will also have no effect unless `g:crystal_simple_indent` is set, since it is required for efficiently computing indentation for floating blocks. In other words, only set this if: 1) you want to use the "simple" indentation style; 2) you do _not_ want to use folding; and 3) you still want definition keywords to receive special highlighting.

## Performance Comparison with [vim-crystal](https://github.com/vim-crystal/vim-crystal)

Comparisons made between the respective HEAD's of each plugin as of this writing (2021-3-4), using `test.cr` as the test file. `test.cr` is comprised of snippets taken from the official documentation along with some random edge cases I came up with myself. The benchmarks were run with NeoVim 0.5.0.

### Syntax

Benchmark:

    command! SyntaxBenchmark
          \ syntime clear |
          \ syntime on |
          \ let last_lnum = line("$") |
          \ for _ in range(15) |
          \ goto |
          \ while line(".") < last_lnum |
          \ redraw |
          \ execute "normal! \<c-d>" |
          \ endwhile |
          \ endfor |
          \ syntime off |
          \ syntime report |
          \ unlet last_lnum

The general idea is to go to the top of the file, redraw the viewport, page down (<kbd>Ctrl</kbd>+<kbd>D</kbd>), and repeat until the end of the file has been reached. This is done fifteen times, after which we get the cumulative results from `syntime report`. It's kinda rough, but it works.

Results:

    vim-crystal/vim-crystal:

    5.71s
    5.56s  (g:crystal_no_expensive = 1)

    jlcrochet/vim-crystal:

    0.29s
    0.29s  (g:crystal_highlight_definitions = 1)

### Indentation

Benchmark:

    command! IndentBenchmark
          \ let start = reltime() |
          \ call feedkeys("ggVG=", "x") |
          \ echo reltimestr(reltime(start)) |
          \ unlet start

Again, a pretty rough test, but it gets the job done. We simply re-indent the entire file once.

Results:

    vim-crystal/vim-crystal:

    15.10s
     9.61s  (g:crystal_no_expensive = 1)

    jlcrochet/vim-crystal (VimL):

    0.80s
    0.00s  (g:crystal_simple_indent = 1)

    jlcrochet/vim-crystal (Lua):

    0.31s
    0.00s  (g:crystal_simple_indent = 1)

## TODO

* ECR
* Folding
