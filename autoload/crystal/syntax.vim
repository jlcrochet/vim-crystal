" Vim autoload file
" Language: Crystal <crystal-lang.org>
" Author: Jeffrey Crochet <jlcrochet@pm.me>
" URL: https://github.com/jlcrochet/vim-crystal

function s:choice(...)
  return '\%('.join(a:000, '\|').'\)'
endfunction

function s:optional(re)
  return '\%('.a:re.'\)\='
endfunction

" Number patterns:
let s:integer_suffix = '[ui]\%(8\|16\|32\|64\|128\)'
let s:float_suffix = 'f\%(32\|64\)'
let s:exponent_suffix = '[eE][+-]\=[[:digit:]_]*'

let s:fraction = '\.\d[[:digit:]_]*' . s:optional(s:exponent_suffix) . s:optional(s:float_suffix)

let s:nonzero_re = '[1-9][[:digit:]_]*' . s:choice(
      \ s:integer_suffix,
      \ s:float_suffix,
      \ s:exponent_suffix . s:optional(s:float_suffix),
      \ s:fraction
      \ ) . '\='

let s:zero_re = '0' . s:choice(
      \ 'b[01_]*' . s:optional(s:integer_suffix),
      \ 'o[0-7_]*' . s:optional(s:integer_suffix),
      \ 'x[[:xdigit:]_]*' . s:optional(s:integer_suffix),
      \ '_*' . s:choice(s:integer_suffix, s:float_suffix, s:exponent_suffix, s:fraction),
      \ '_[[:digit:]_]*' . s:choice(s:integer_suffix, s:float_suffix, s:exponent_suffix, s:fraction) . '\=',
      \ ) . '\='

let s:template = 'syn match crystalNumber /\%%#=1%s/ nextgroup=@crystalPostfix skipwhite'

const g:crystal#syntax#number = printf(s:template, s:nonzero_re) .. " | " .. printf(s:template, s:zero_re)

unlet
      \ s:integer_suffix s:float_suffix s:exponent_suffix
      \ s:fraction s:nonzero_re s:zero_re
      \ s:template

" This pattern helps to match all overloadable operators; these are also
" the only operators that can be referenced as symbols or used as
" methods.
const g:crystal#syntax#overloadable_operators = s:choice(
      \ '[+\-|^~%]',
      \ '\*\*\=',
      \ '\/\/\=',
      \ '=\%(==\=\|\~\)',
      \ '![=~]\=',
      \ '<\%(=>\=\|<\)\=',
      \ '>[>=]\=',
      \ '&\%([+-]\|\*\*\=\)\=',
      \ '\[][=?]\='
      \ )

delfunction s:choice
delfunction s:optional
