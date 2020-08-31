" Vim ftplugin file
" Language: Crystal <crystal-lang.org>
" Author: Jeffrey Crochet <jlcrochet@pm.me>
" URL: https://github.com/jlcrochet/vim-crystal

if exists('b:did_ftplugin')
  finish
endif

let b:did_ftplugin = 1

" This file is loaded on 'ecrystal' filetype
if &filetype !=# 'crystal'
  finish
endif

setlocal comments=:#
setlocal commentstring=#\ %s
setlocal suffixesadd=.cr
