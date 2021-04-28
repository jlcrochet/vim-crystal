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

" vim-endwise
if get(g:, "loaded_endwise")
  let b:endwise_addition = "end"
  let b:endwise_words = "def,macro,class,struct,module,enum,annotation,lib,union,if,unless,case,while,until,for,begin,do"
  let b:endwise_syngroups = "crystalKeyword,crystalDefine"
endif

" matchit.vim
if get(g:, "loaded_matchit")
  let b:match_words = g:crystal#ftplugin#match_words
  let b:match_skip = 'S:^crystal\%(Keyword\|Define\|BlockControl\|DefineBlockControl\)$'
endif
