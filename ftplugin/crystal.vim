" Vim ftplugin file
" Language: Crystal <crystal-lang.org>
" Author: Jeffrey Crochet <jlcrochet@pm.me>
" URL: https://github.com/jlcrochet/vim-crystal

if get(b:, "did_ftplugin")
  finish
endif

let b:did_ftplugin = 1

setlocal shiftwidth=2
setlocal comments=:#
setlocal commentstring=#\ %s
setlocal suffixesadd=.cr

if get(g:, "crystal_fold")
  let g:crystal_simple_indent = 0
endif

" matchit.vim
let b:match_words = g:crystal#ftplugin#match_words
let b:match_skip = 'S:^crystal\%(Keyword\|Define\|BlockControl\|DefineBlockControl\)$'
