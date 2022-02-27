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
let s:exponent_suffix = '[eE][+-]\=\d\+\%(_\d\+\)*' . s:optional('_\=' . s:float_suffix)

let s:fraction = '\.\d\+\%(_\d\+\)*' . s:choice(
      \ s:float_suffix,
      \ s:exponent_suffix,
      \ '_' . s:choice(s:float_suffix, s:exponent_suffix)
      \ ) . '\='

let s:nonzero_re = '[1-9]\d*\%(_\d\+\)*' . s:choice(
      \ s:integer_suffix,
      \ s:float_suffix,
      \ s:exponent_suffix,
      \ '_' . s:choice(s:integer_suffix, s:float_suffix, s:exponent_suffix),
      \ s:fraction
      \ ) . '\='

let s:zero_re = '0' . s:choice(
      \ s:integer_suffix,
      \ s:float_suffix,
      \ '_' . s:choice(s:integer_suffix, s:float_suffix, s:exponent_suffix),
      \ s:fraction,
      \ 'b[01]\+\%(_[01]\+\)*' . s:optional(s:integer_suffix),
      \ 'o\o\+\%(_\o\+\)*' . s:optional(s:integer_suffix),
      \ 'x\x\+\%(_\x\+\)*' . s:optional(s:integer_suffix)
      \ ) . '\='

let s:template = 'syn match crystalNumber /\%%#=1%s/ nextgroup=@crystalPostfix skipwhite'

const g:crystal#syntax#number = printf(s:template, s:nonzero_re) .. " | " .. printf(s:template, s:zero_re)

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

" The syntax for PCRE escapes and groups is pretty complicated, so we're
" building it here:
let s:pcre_escape = '\\' . s:choice(
      \ 'c.',
      \ '\d\+',
      \ 'o{\o\+}',
      \ 'x\%(\x\x\|{\x\+}\)',
      \ '[pP]{\h\w*}',
      \ "g" . s:choice('\d\+', '{\%(-\=\d\+\|\h\w*\)}', '<\%(-\=\d\+\|\h\w*\)>', '''\%(-\=\d\+\|\h\w*\)'''),
      \ "k" . s:choice('<\h\w*>', '''\h\w*''', '{\h\w*}'),
      \ '.'
      \ )

const g:crystal#syntax#pcre_escape = printf(
      \ 'syn match crystalPCREescape /\%%#=1%s/ contained',
      \ s:pcre_escape
      \ )

let s:pcre_group_modifier = "?" . s:choice(
      \ '<\h\w*>',
      \ '''\h\w*''',
      \ "P" . s:choice('<\h\w*>', '[>=]\h\w*'),
      \ '[:|>=!]',
      \ '-\=[iJmsUx]\+:\=',
      \ '<[=!]',
      \ "R",
      \ '[+-]\=\d\+',
      \ '&\h\w*',
      \ "(" . s:choice('[+-]\=\d\+', '<\h\w*>', '''\h\w*''', 'R\%(\d\+\|&\h\w*\)', '\h\w*') . ")",
      \ 'C\d*'
      \ )

const g:crystal#syntax#pcre_group = printf(
      \ 'syn region crystalPCREGroup matchgroup=crystalPCREMetaCharacter start=/\%%#=1(\%%(%s\)\=/ end=/\%%#=1)/ contained transparent',
      \ s:pcre_group_modifier
      \ )

unlet
      \ s:integer_suffix s:float_suffix s:exponent_suffix
      \ s:fraction s:nonzero_re s:zero_re
      \ s:template
      \ s:pcre_escape s:pcre_group_modifier

delfunction s:choice
delfunction s:optional
