" Vim ftplugin file
" Language: Crystal <crystal-lang.org>
" Author: Jeffrey Crochet <jlcrochet@pm.me>
" URL: https://github.com/jlcrochet/vim-crystal

if get(b:, "did_ftplugin")
  finish
endif

setlocal shiftwidth=2
setlocal comments=:#
setlocal commentstring=#\ %s
setlocal suffixesadd=.cr

" matchit.vim
if get(g:, "loaded_matchit")
  let b:match_words = g:crystal#match_words
  let b:match_skip = 'S:^crystal\%(Keyword\|Define\)$'
endif

let b:did_ftplugin = 1
