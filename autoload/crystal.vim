" Vim autoload file
" Language: Crystal <crystal-lang.org>
" Author: Jeffrey Crochet <jlcrochet@pm.me>
" URL: https://github.com/jlcrochet/vim-crystal

" Caching important syntax ID's for use in indentation logic
let g:crystal#multiline_regions = {}

for s:name in ["crystalString", "crystalSymbol", "crystalRegex", "crystalRegexGroup", "crystalRegexComment", "crystalRegexEscape", "crystalCommand", "crystalHeredocLine", "crystalHeredocLineRaw", "crystalHeredocEnd"]
  let g:crystal#multiline_regions[hlID(s:name)] = 1
endfor

lockvar g:crystal#multiline_regions

unlet s:name

const g:crystal#keyword = hlID("crystalKeyword")
const g:crystal#define = hlID("crystalDefine")
const g:crystal#operator = hlID("crystalOperator")
const g:crystal#delimiter = hlID("crystalDelimiter")
const g:crystal#comment_delimiter = hlID("crystalCommentDelimiter")

" matchit.vim
let s:match_words = [
      \ '\<\%(def\|macro\|class\|struct\|module\|enum\|annotation\|lib\|union\|if\|unless\|case\|while\|until\|for\|begin\|do\):\@!\>',
      \ '\<\%(else\|elsif\|when\|in\|rescue\|ensure\|break\|next\|yield\|return\):\@!\>',
      \ '\<end:\@!\>'
      \ ]
const g:crystal#match_words = join(s:match_words, ":")
unlet s:match_words
