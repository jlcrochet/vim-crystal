" Vim indent file
" Language: Crystal <crystal-lang.org>
" Author: Jeffrey Crochet <jlcrochet@pm.me>
" URL: https://github.com/jlcrochet/vim-crystal

if get(b:, "did_indent")
  finish
endif

let b:did_indent = 1

setlocal indentkeys=0},0),0],0.,!^F,o,O
setlocal indentkeys+=0=end,0=else,0=elsif,0=when,0=in,0=ensure,0=rescue

if has("nvim-0.5")
  lua get_crystal_indent = require("get_crystal_indent")
  setlocal indentexpr=v:lua.get_crystal_indent(v:lnum)

  finish
else
  setlocal indentexpr=GetCrystalIndent(v:lnum)
endif

if exists("*GetCrystalIndent")
  finish
endif

" GetCrystalIndent {{{
function! GetCrystalIndent(lnum) abort
endfunction
" }}}

" vim:fdm=marker
