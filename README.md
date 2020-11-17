## Introduction

This was originally a fork of [vim-crystal](https://github.com/vim-crystal/vim-crystal) that discarded many of the original's features in order to study how syntax highlighting and indentation could be made faster and more accurate. I have decided to move it to a separate repository for anyone who wants a faster, lightweight alternative to the original vim-crystal.

## Performance Comparison with [vim-crystal](https://github.com/vim-crystal/vim-crystal)

Comparisons made between the respective HEAD's of each plugin as of this writing (2020-11-17), using `test.cr` as the test file. I'm currently running NeoVim 0.5.0.

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

Results on my machine:

    vim-crystal/vim-crystal:

    2.56s
    5.30s  (g:crystal_no_expensive = 1) (?)

    jlcrochet/vim-crystal:

    0.29s

Surprisingly, vim-crystal's syntax highlighting is significantly slower when `g:crystal_no_expensive` is enabled. Regardless, this plugin far outperforms vim-crystal for syntax highlighting.

### Indentation

Benchmark:

    command! IndentBenchmark
          \ let start = reltime() |
          \ for _ in range(15) |
          \ call feedkeys("ggVG=", "x") |
          \ endfor |
          \ echo reltimestr(reltime(start)) |
          \ unlet start

Again, a pretty rough test, but it gets the job done.

Results:

    vim-crystal/vim-crystal:

      13.34s
    ~132.30s  (g:crystal_no_expensive = 1) (?!)

    jlcrochet/vim-crystal (VimL):

    12.00s

    jlcrochet/vim-crystal (Lua):

    4.58s

For some reason, indentation with vim-crystal is *much* slower when `g:crystal_no_expensive` is enabled.

This plugin's VimL-based indent function (`GetCrystalIndent`) is faster than that of vim-crystal, but not by much. If using NeoVim 0.5+, the Lua-based indent function is significantly faster.

## TODO

* ECR
* Folding
