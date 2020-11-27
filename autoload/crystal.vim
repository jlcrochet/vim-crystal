" Vim autoload file
" Language: Crystal <crystal-lang.org>
" Author: Jeffrey Crochet <jlcrochet@pm.me>
" URL: https://github.com/jlcrochet/vim-crystal

" Caching important syntax ID's for use in indentation logic
const g:crystal#multiline_regions = {}

for id in ["crystalString", "crystalSymbol", "crystalRegex", "crystalCommand", "crystalComment", "crystalHeredocLine", "crystalHeredocLineRaw", "crystalHeredocDelimiter"]
  let g:crystal#multiline_regions[hlID(id)] = 1
endfor

const g:crystal#keyword = hlID("crystalKeyword")
const g:crystal#operator = hlID("crystalOperator")
const g:crystal#delimiter = hlID("crystalDelimiter")
const g:crystal#comment_delimiter = hlID("crystalCommentDelimiter")
const g:crystal#macro_delimiter = hlID("crystalMacroDelimiter")
