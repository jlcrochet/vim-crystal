" Vim autoload file
" Language: Crystal <crystal-lang.org>
" Author: Jeffrey Crochet <jlcrochet@pm.me>
" URL: https://github.com/jlcrochet/vim-crystal

" This pattern helps to match all overloadable operators; these are also
" the only operators that can be referenced as symbols or used as
" methods.
"
" NOTE: There is one exception: `!` cannot be overloaded; however, it
" isn't worth it to separate it from the rest.
let s:overloadable_operators = [
      \ '[+\-|^~%]',
      \ '\*\*\=',
      \ '\/\/\=',
      \ '=\%(==\=\|\~\)',
      \ '![=~]\=',
      \ '<\%(=>\=\|<\)\=',
      \ '>[>=]\=',
      \ '&\%([+-]\|\*\*\=\)\=',
      \ '\[][=?]\='
      \ ]
const g:crystal#syntax#overloadable_operators = '\%('.join(s:overloadable_operators, '\|').'\)'

unlet s:overloadable_operators

" Number patterns:
function s:or(...)
  return '\%('.join(a:000, '\|').'\)'
endfunction

function s:optional(re)
  return '\%('.a:re.'\)\='
endfunction

let s:integer_suffix = '[ui]\%(8\|16\|32\|64\|128\)'
let s:float_suffix = 'f\%(32\|64\)'
let s:exponent_suffix = '[eE][+-]\=[[:digit:]_]*'

let s:fraction = '\.\d[[:digit:]_]*' . s:optional(s:exponent_suffix) . s:optional(s:float_suffix)

let s:nonzero_re = '[1-9][[:digit:]_]*' . s:or(
      \ s:integer_suffix,
      \ s:float_suffix,
      \ s:exponent_suffix . s:optional(s:float_suffix),
      \ s:fraction
      \ ) . '\='

let s:zero_re = '0' . s:or(
      \ 'b[01_]*' . s:optional(s:integer_suffix),
      \ 'o[0-7_]*' . s:optional(s:integer_suffix),
      \ 'x[[:xdigit:]_]*' . s:optional(s:integer_suffix),
      \ '_*' . s:or(s:integer_suffix, s:float_suffix, s:exponent_suffix, s:fraction),
      \ '_[[:digit:]_]*' . s:or(s:integer_suffix, s:float_suffix, s:exponent_suffix, s:fraction) . '\=',
      \ ) . '\='

let s:syn_match_template = 'syn match crystalNumber /\%%#=1%s/ nextgroup=@crystalPostfix skipwhite display'

const g:crystal#syntax#numbers = printf(s:syn_match_template, s:nonzero_re) .. " | " .. printf(s:syn_match_template, s:zero_re)

delfunction s:or
delfunction s:optional

unlet
      \ s:integer_suffix s:float_suffix s:exponent_suffix
      \ s:fraction s:nonzero_re s:zero_re
      \ s:syn_match_template
