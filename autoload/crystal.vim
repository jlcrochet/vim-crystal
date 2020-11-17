" Vim autoload file
" Language: Crystal <crystal-lang.org>
" Author: Jeffrey Crochet <jlcrochet@pm.me>
" URL: https://github.com/jlcrochet/vim-crystal

" Caching important syntax ID's for use in indentation logic
const g:crystal#string = hlID("crystalString")
const g:crystal#symbol = hlID("crystalSymbol")
const g:crystal#regex = hlID("crystalRegex")
const g:crystal#command = hlID("crystalCommand")
const g:crystal#comment = hlID("crystalComment")
const g:crystal#heredoc_line = hlID("crystalHeredocLine")
const g:crystal#heredoc_line_raw = hlID("crystalHeredocLineRaw")
const g:crystal#heredoc_delimiter = hlID("crystalHeredocDelimiter")

const g:crystal#multiline_regions = {}

for id in [g:crystal#string, g:crystal#symbol, g:crystal#regex, g:crystal#command, g:crystal#comment, g:crystal#heredoc_line, g:crystal#heredoc_line_raw, g:crystal#heredoc_delimiter]
  let g:crystal#multiline_regions[id] = 1
endfor

const g:crystal#keyword = hlID("crystalKeyword")
const g:crystal#operator = hlID("crystalOperator")
const g:crystal#delimiter = hlID("crystalDelimiter")
const g:crystal#macro_delimiter = hlID("crystalMacroDelimiter")
