" Vim autoload file
" Language: Crystal <crystal-lang.org>
" Author: Jeffrey Crochet <jlcrochet@pm.me>
" URL: https://github.com/jlcrochet/vim-crystal

" Caching important syntax ID's for use in indentation logic
let s:names = [
      \ "crystalString",
      \ "crystalStringEscape",
      \ "crystalStringInterpolationDelimiter",
      \ "crystalStringParenthesisEscape",
      \ "crystalStringSquareBracketEscape",
      \ "crystalStringCurlyBraceEscape",
      \ "crystalStringAngleBracketEscape",
      \ "crystalStringPipeEscape",
      \ "crystalSymbol",
      \ "crystalRegex",
      \ "crystalRegexGroup",
      \ "crystalRegexComment",
      \ "crystalRegexEscape",
      \ "crystalCommand",
      \ "crystalHeredocLine",
      \ "crystalHeredocLineRaw",
      \ "crystalHeredocEnd"
      \ ]

let g:crystal#indent#multiline_regions = {}

for s:name in s:names
  let g:crystal#indent#multiline_regions[hlID(s:name)] = 1
endfor

lockvar g:crystal#multiline_regions

unlet s:name s:names

const g:crystal#indent#keyword = hlID("crystalKeyword")
const g:crystal#indent#define = hlID("crystalDefine")
const g:crystal#indent#block_control = hlID("crystalBlockControl")
const g:crystal#indent#define_block_control = hlID("crystalDefineBlockControl")
const g:crystal#indent#operator = hlID("crystalOperator")
const g:crystal#indent#assignment_operator = hlID("crystalAssignmentOperator")
const g:crystal#indent#delimiter = hlID("crystalDelimiter")
