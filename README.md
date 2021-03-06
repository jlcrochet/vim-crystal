## Introduction

This was originally a fork of [vim-crystal](https://github.com/vim-crystal/vim-crystal) that discarded many of the original's features in order to study how syntax highlighting and indentation could be improved. It turned into a complete rewrite of the original plugin and merging my changes was no longer feasible, so I decided to move it to a separate repository for anyone who wants a faster and more accurate alternative to the original vim-crystal.

This plugin includes support for [embedded crystal (ECR)](https://crystal-lang.org/api/latest/ECR.html).

## Configuration

NOTE: The following variables are read only when this plugin is first loaded, so in order for any changes to take effect, you must place them in `.vimrc` or some other file loaded on startup and then restart Vim.

#### `g:crystal_simple_indent`

The default indentation style used by this plugin is the one most commonly found in the Crystal community, which allows for "hanging" or "floating" indentation. Some examples:

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

For those who prefer a more traditional indentation style or who desire slightly faster highlighting and indentation, set `g:crystal_simple_indent` to `1`. The above examples will now be indented thus:

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

#### `g:crystal_fold`

If `1`, definition blocks for methods, classes, etc. will be folded.

NOTE: Setting this will disable `g:crystal_simple_indent`, since floating blocks have to be matched in order for folding to work properly.

#### `g:ecrystal_extensions`

This plugin uses a dictionary of filetype extensions to determine which filetype to use when loading ECR files. For example, opening a file named `foo.html.ecr` will load HTML as the filetype with ECR syntax added on top.

The default recognized filetype extensions are as follows:

    .html => html
    .js => javascript
    .json => json
    .yml => yaml
    .txt => text
    .md => markdown

Each extension maps to the name of the filetype that you want to load for that extension.

To add or overwrite entries in the dictionary, set `g:ecrystal_extensions` to a dictionary with the entries you want to inject. For example, the following would allow the plugin to recognize XML files and would cause `*.js` files to be recognized as JSX instead of JavaScript:

    let g:ecrystal_extensions = { "xml": "xml", "js": "javascriptreact" }

## Performance Comparison with [vim-crystal](https://github.com/vim-crystal/vim-crystal)

Comparisons made between the respective HEAD's of each plugin as of this writing (2021-5-1), using [this test file](https://gist.github.com/jlcrochet/720c5a83aa15eef2d2eda2c05bc5b2f1). The test file is comprised of snippets taken from the official documentation along with some random edge cases I came up with myself. The benchmarks were run with NeoVim 0.5.0.

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

    5.08s

    jlcrochet/vim-crystal:

    0.47s
    0.36s  (g:crystal_simple_indent == 1)

### Indentation

Benchmark:

    command! IndentBenchmark
          \ goto |
          \ let start = reltime() |
          \ call feedkeys("=G", "x") |
          \ echo reltimestr(reltime(start)) |
          \ unlet start

Again, a pretty rough test, but it gets the job done. We simply re-indent the entire file once.

Results:

    vim-crystal/vim-crystal:

    10.29s

    jlcrochet/vim-crystal (VimL):

    1.12s
    0.52s  (g:crystal_simple_indent == 1)

    jlcrochet/vim-crystal (Lua):

    0.24s
    0.12s  (g:crystal_simple_indent == 1)
