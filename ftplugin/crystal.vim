" Vim ftplugin file
" Language: Crystal <crystal-lang.org>
" Author: Jeffrey Crochet <jlcrochet@pm.me>
" URL: https://github.com/jlcrochet/vim-crystal

if get(b:, "did_ftplugin")
  finish
endif

let b:did_ftplugin = 1

" This file is loaded on 'ecrystal' filetype
if &filetype !=# 'crystal'
  finish
endif

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
let s:match_words = [
      \ '\<\%(def\|macro\|class\|struct\|module\|enum\|annotation\|lib\|union\|if\|unless\|case\|while\|until\|for\|begin\|do\):\@!\>',
      \ '\<\%(else\|elsif\|when\|in\|rescue\|ensure\|break\|next\|yield\|return\):\@!\>',
      \ '\<end:\@!\>'
      \ ]
let b:match_words = join(s:match_words, ":")
unlet s:match_words

let b:match_skip = 'S:^crystal\%(Keyword\|Define\)$'

" vim-endwise
