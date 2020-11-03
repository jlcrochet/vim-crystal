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
const g:crystal#global_variable = hlID("crystalGlobalVariable")

const g:crystal#string_delimiter = hlID("crystalStringDelimiter")
const g:crystal#symbol_delimiter = hlID("crystalSymbolDelimiter")
const g:crystal#regex_delimiter = hlID("crystalRegexDelimiter")
const g:crystal#command_delimiter = hlID("crystalCommandDelimiter")

const g:crystal#delimiters = {}

for id in [g:crystal#string_delimiter, g:crystal#symbol_delimiter, g:crystal#regex_delimiter, g:crystal#command_delimiter]
  let g:crystal#delimiters[id] = 1
endfor

const g:crystal#block_parameter_delimiter = hlID("crystalBlockParameterDelimiter")
const g:crystal#macro_delimiter = hlID("crystalMacroDelimiter")
const g:crystal#proc_operator = hlID("crystalProcOperator")
