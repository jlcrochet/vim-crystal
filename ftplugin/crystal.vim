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

if !get(g:, "crystal_simple_indent")
  let g:crystal_highlight_definitions = 1
endif

if get(g:, "crystal_fold")
  setlocal foldmethod=syntax
  let g:crystal_highlight_definitions = 1
endif

" matchit.vim
let b:match_words = g:crystal#match_words
let b:match_skip = 'S:^crystal\%(Keyword\|Define\)$'

" vim-endwise
if get(g:, "loaded_endwise")
  augroup endwise
    autocmd! FileType crystal
          \ let b:endwise_addition = "end" |
          \ let b:endwise_words = "def,macro,class,struct,module,enum,annotation,lib,union,if,unless,case,while,until,for,begin,do" |
          \ let b:endwise_syngroups = "crystalKeyword,crystalDefine"
  augroup END
endif
