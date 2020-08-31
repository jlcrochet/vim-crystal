" Vim indent file
" Language: Crystal <crystal-lang.org>
" Author: Jeffrey Crochet <jlcrochet@pm.me>
" URL: https://github.com/jlcrochet/vim-crystal

" Initialization {{{
" ==============

" Only load this indent file when no other was loaded
if exists('b:did_indent')
  finish
endif

let b:did_indent = 1

lua get_crystal_indent = require("get_crystal_indent")

" Now, set up our indentation expression and keys that trigger it
setlocal indentexpr=v:lua.get_crystal_indent(v:lnum)
setlocal indentkeys=0},0),0],0.,!^F,o,O
setlocal indentkeys+=0=end,0=else,0=elsif,0=when,0=in,0=ensure,0=rescue
