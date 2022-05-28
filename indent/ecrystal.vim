" Vim indent file
" Language: Embedded Crystal <crystal-lang.org/api/latest/ECR.html>
" Author: Jeffrey Crochet <jlcrochet@hey.com>
" URL: https://github.com/jlcrochet/vim-crystal

if get(b:, "did_indent")
  let b:ecrystal_subtype_indentexpr = &indentexpr
else
  let b:ecrystal_subtype_indentexpr = "-1"
  let b:did_indent = 1
endif

setlocal
      \ indentexpr=GetEcrystalIndent()
      \ indentkeys+==end,=else,=elsif

if exists("*GetEcrystalIndent")
  finish
endif

let s:start_re = '[([{]\|\C\v<%(if|unless|begin|do)>'
let s:middle_re = '\C\v<%(else|elsif)>'
let s:end_re = '[)\]}]\|\C\<end\>'

let s:skip_expr = 'synID(line("."), col("."), 0)->synIDattr("name") !~# ''^crystal\%(Delimiter\|Keyword\)$'''

function GetEcrystalIndent() abort
  call cursor(0, 1)

  if searchpair(s:start_re, s:middle_re, s:end_re, "nz", s:skip_expr, v:lnum)
    return indent(searchpair(s:start_re, s:middle_re, s:end_re, "bW", s:skip_expr))
  endif

  let prev_lnum = prevnonblank(v:lnum - 1)

  if prev_lnum == 0
    return 0
  endif

  if searchpair(s:start_re, s:middle_re, s:end_re, "b", s:skip_expr, prev_lnum)
    return indent(prev_lnum) + shiftwidth()
  endif

  return eval(b:ecrystal_subtype_indentexpr)
endfunction
