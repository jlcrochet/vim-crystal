" Vim indent file
" Language: Embedded Crystal <crystal-lang.org/api/latest/ECR.html>
" Author: Jeffrey Crochet <jlcrochet@pm.me>
" URL: https://github.com/jlcrochet/vim-crystal

if get(b:, "did_indent")
  finish
endif

let b:did_indent = 1

setlocal indentexpr=GetEcrystalIndent()

if exists("*GetEcrystalIndent")
  finish
endif

let s:start_re = '\<\%(if\|unless\|begin\|do\):\@!\>'
let s:middle_re = '\<\%(else\|elsif\):\@!\>'
let s:end_re = '\<end:\@!\>'

let s:skip_expr = "synID(line('.'), col('.'), 0) != g:crystal#keyword"

function GetEcrystalIndent() abort
  let has_shifted = 0
  let shift = 0

  if searchpair(s:start_re, s:middle_re, s:end_re, "nz", s:skip_expr, v:lnum)
    let has_shifted = 1
    let shift -= 1
  endif

  let prev_lnum = prevnonblank(v:lnum - 1)

  if searchpair(s:start_re, s:middle_re, s:end_re, "b", s:skip_expr, prev_lnum)
    let has_shifted = 1
    let shift += 1
  endif

  " If no shifts occurred, fall back to subtype indentation.
  if has_shifted
    return indent(prev_lnum) + shift * shiftwidth()
  else
    return eval(b:ecrystal_subtype_indentexpr)
  endif
endfunction
