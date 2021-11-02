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
      \ "crystalStringEnd",
      \ "crystalSymbol",
      \ "crystalSymbolEnd",
      \ "crystalRegex",
      \ "crystalRegexEnd",
      \ "crystalRegexGroup",
      \ "crystalRegexComment",
      \ "crystalRegexEscape",
      \ "crystalCommand",
      \ "crystalCommandEnd",
      \ "crystalHeredocLine",
      \ "crystalHeredocLineRaw",
      \ "crystalHeredocEnd"
      \ ]

let s:regions = {}

for s:name in s:names
  let s:regions[hlID(s:name)] = 1
endfor

const g:crystal#highlighting#multiline_regions = s:regions

const g:crystal#highlighting#keyword = hlID("crystalKeyword")
const g:crystal#highlighting#define = hlID("crystalDefine")
const g:crystal#highlighting#block_control = hlID("crystalBlockControl")
const g:crystal#highlighting#define_block_control = hlID("crystalDefineBlockControl")
const g:crystal#highlighting#operator = hlID("crystalOperator")
const g:crystal#highlighting#assignment_operator = hlID("crystalAssignmentOperator")
const g:crystal#highlighting#delimiter = hlID("crystalDelimiter")
const g:crystal#highlighting#comment_start = hlID("crystalCommentStart")

unlet s:name s:names s:regions
