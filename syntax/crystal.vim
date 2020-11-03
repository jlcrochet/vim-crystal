" Vim syntax file
" Language: Crystal <crystal-lang.org>
" Author: Jeffrey Crochet <jlcrochet@pm.me>
" URL: https://github.com/jlcrochet/vim-crystal

if has_key(b:, "current_syntax")
  finish
endif

let b:current_syntax = "crystal"

" Syntax {{{1
let s:overloadable_operators = '[+\-*/%~^&|!\[\]=?<>]'

syn cluster crystalTop contains=TOP

" Comments {{{2
syn region crystalComment matchgroup=crystalCommentDelimiter start=/\%#=1#/ end=/\%#=1\_$/ display oneline contains=crystalTodo
syn keyword crystalTodo TODO NOTE XXX FIXME HACK TBD contained

syn region crystalShebang start=/\%#=1\%^#!/ end=/\%#=1\_$/ display oneline

" Identifiers {{{2
syn match crystalInstanceVariable /\%#=1@\h\w*/ display
syn match crystalClassVariable /\%#=1@@\h\w*/ display
syn match crystalGlobalVariable /\%#=1\$\%([~?]\|\d\+?\=\|\h\w*\)/ display
syn match crystalFreshVariable /\%#=1%\h\w*/ display contained

syn match crystalConstant /\%#=1\<\u\w*/ display

" Literals {{{2
syn keyword crystalNil nil
syn keyword crystalBoolean true false
syn keyword crystalSelf self

" Numbers {{{3
function s:or(...)
  return '%('.join(a:000, '|').')'
endfunction

function s:optional(re)
  return '%('.a:re.')='
endfunction

let s:integer_suffix = '[ui]%(8|16|32|64|128)'
let s:float_suffix = 'f%(32|64)'
let s:exponent_suffix = '[eE][+-]=[[:digit:]_]*'

let s:fraction = '\.\d[[:digit:]_]*' . s:optional(s:exponent_suffix) . s:optional(s:float_suffix)

let s:nonzero_re = '[1-9][[:digit:]_]*' . s:or(
      \ s:integer_suffix,
      \ s:float_suffix,
      \ s:exponent_suffix . s:optional(s:float_suffix),
      \ s:fraction
      \ ) . '='

let s:zero_re = '0' . s:or(
      \ 'b[01_]*' . s:optional(s:integer_suffix).'>',
      \ 'o[0-7_]*' . s:optional(s:integer_suffix).'>',
      \ 'x[[:xdigit:]_]*' . s:optional(s:integer_suffix).'>',
      \ '_*' . s:or(s:integer_suffix, s:float_suffix, s:fraction),
      \ '_+' . s:optional(s:or(s:exponent_suffix, s:nonzero_re))
      \ ) . '='

let s:syn_match_template = 'syn match crystalNumber /\%%#=1\v<%s/ display'

execute printf(s:syn_match_template, s:nonzero_re)
execute printf(s:syn_match_template, s:zero_re)

delfunction s:or
delfunction s:optional

unlet
      \ s:integer_suffix s:float_suffix s:exponent_suffix
      \ s:fraction s:nonzero_re s:zero_re
      \ s:syn_match_template

" Characters {{{3
syn match crystalCharacter /\%#=1'\%(\\\%(u\%(\x\{4}\|{\x\{1,6}}\)\|['\\abefnrtv0]\)\|.\)'/ display contains=crystalCharacterEscape
syn match crystalCharacterEscape /\%#=1\\\%(u\%(\x\{4}\|{\x\{1,6}}\)\|['\\abefnrtv0]\)/ display contained

" Strings {{{3
syn region crystalString matchgroup=crystalStringDelimiter start=/\%#=1"/ end=/\%#=1"/ display contains=crystalStringInterpolation,crystalStringEscape

syn region crystalString matchgroup=crystalStringDelimiter start=/\%#=1%Q\=(/ end=/\%#=1)/ display contains=crystalStringParentheses,crystalStringInterpolation,crystalStringEscape
syn region crystalStringParentheses matchgroup=crystalString start=/\%#=1(/ end=/\%#=1)/ display transparent contained contains=crystalStringParentheses,crystalStringInterpolation,crystalStringEscape

syn region crystalString matchgroup=crystalStringDelimiter start=/\%#=1%Q\=\[/ end=/\%#=1]/ display contains=crystalStringSquareBrackets,crystalStringInterpolation,crystalStringEscape
syn region crystalStringSquareBrackets matchgroup=crystalString start=/\%#=1\[/ end=/\%#=1]/ display transparent contained contains=crystalStringSquareBrackets,crystalStringInterpolation,crystalStringEscape

syn region crystalString matchgroup=crystalStringDelimiter start=/\%#=1%Q\={/ end=/\%#=1}/ display contains=crystalStringCurlyBraces,crystalStringInterpolation,crystalStringEscape
syn region crystalStringCurlyBraces matchgroup=crystalString start=/\%#=1{/ end=/\%#=1}/ display transparent contained contains=crystalStringCurlyBraces,crystalStringInterpolation,crystalStringEscape

syn region crystalString matchgroup=crystalStringDelimiter start=/\%#=1%Q\=</ end=/\%#=1>/ display contains=crystalStringAngleBrackets,crystalStringInterpolation,crystalStringEscape
syn region crystalStringAngleBrackets matchgroup=crystalString start=/\%#=1</ end=/\%#=1>/ display transparent contained contains=crystalStringAngleBrackets,crystalStringInterpolation,crystalStringEscape

syn region crystalString matchgroup=crystalStringDelimiter start=/\%#=1%Q\=|/ end=/\%#=1|/ display contains=crystalStringInterpolation,crystalStringEscape

syn region crystalStringInterpolation matchgroup=crystalStringInterpolationDelimiter start=/\%#=1#{/ end=/\%#=1}/ display contained contains=@crystalTop,crystalNestedBlock

syn match crystalStringEscape /\%#=1\\\%(\d\{1,3}\|x\x\x\|u\%(\x\{4}\|{\x\{1,6}\%(\s\x\{1,6}\)*}\)\|\_.\)/ display contained

" Raw Strings {{{3
syn region crystalString matchgroup=crystalStringDelimiter start=/\%#=1%q(/  end=/\%#=1)/ skip=/\%#=1(.\{-})/  display
syn region crystalString matchgroup=crystalStringDelimiter start=/\%#=1%q\[/ end=/\%#=1]/ skip=/\%#=1\[.\{-}]/ display
syn region crystalString matchgroup=crystalStringDelimiter start=/\%#=1%q{/  end=/\%#=1}/ skip=/\%#=1{.\{-}}/  display
syn region crystalString matchgroup=crystalStringDelimiter start=/\%#=1%q</  end=/\%#=1>/ skip=/\%#=1<.\{-}>/  display
syn region crystalString matchgroup=crystalStringDelimiter start=/\%#=1%q|/  end=/\%#=1|/ display

" String Arrays {{{3
syn region crystalString matchgroup=crystalStringDelimiter start=/\%#=1%w(/ end=/\%#=1)/ display contains=crystalStringArrayParentheses,crystalStringParenthesisEscape
syn region crystalStringArrayParentheses matchgroup=crystalString start=/\%#=1(/ end=/\%#=1)/ display transparent contained contains=crystalStringArrayParentheses,crystalStringParenthesisEscape
syn match crystalStringParenthesisEscape /\%#=1\\[()[:space:]]/ display contained

syn region crystalString start=/\%#=1%w\[/ end=/\%#=1]/ display contains=crystalStringArraySquareBrackets,crystalStringSquareBracketEscape
syn region crystalStringArraySquareBrackets matchgroup=crystalString start=/\%#=1\[/ end=/\%#=1]/ display transparent contained contains=crystalStringArraySquareBrackets,crystalStringSquareBracketEscape
syn match crystalStringSquareBracketEscape /\%#=1\\[\[\][:space:]]/ display contained

syn region crystalString start=/\%#=1%w{/ end=/\%#=1}/ display contains=crystalStringArrayCurlyBraces,crystalStringCurlyBraceEscape
syn region crystalStringArrayCurlyBraces matchgroup=crystalString start=/\%#=1{/ end=/\%#=1}/ display transparent contained contains=crystalStringArrayCurlyBraces,crystalStringCurlyBraceEscape
syn match crystalStringCurlyBraceEscape /\%#=1\\[{}[:space:]]/ display contained

syn region crystalString start=/\%#=1%w</ end=/\%#=1>/ display contains=crystalStringArrayAngleBrackets,crystalStringAngleBracketEscape
syn region crystalStringArrayAngleBrackets matchgroup=crystalString start=/\%#=1</ end=/\%#=1>/ display transparent contained contains=crystalStringArrayAngleBrackets,crystalStringAngleBracketEscape
syn match crystalStringAngleBracketEscape /\%#=1\\[<>[:space:]]/ display contained

syn region crystalString matchgroup=crystalString start=/\%#=1%w|/ end=/\%#=1|/ display contains=crystalStringPipeEscape
syn match crystalStringPipeEscape /\%#=1\\[|[:space:]]/ display contained

" Here Documents {{{3
syn region crystalHeredoc matchgroup=crystalHeredocDelimiter start=/\%#=1<<-\z(\w\+\)/ end=/\%#=1\_^\s*\z1\>/ display transparent contains=@crystalTop,crystalHeredocLine
syn region crystalHeredocLine start=/\%#=1\_^/ end=/\%#=1\_$/ display oneline contained contains=crystalStringInterpolation,crystalStringEscape nextgroup=crystalHeredocLine skipempty

syn region crystalHeredoc matchgroup=crystalHeredocDelimiter start=/\%#=1<<-'\z(\w\+\)'/ end=/\%#=1\_^\s*\z1\>/ display transparent contains=@crystalTop,crystalHeredocLineRaw
syn region crystalHeredocLineRaw start=/\%#=1\_^/ end=/\%#=1\_$/ display oneline contained nextgroup=crystalHeredocLineRaw skipempty

" Symbols {{{3
syn match crystalSymbol /\%#=1:\h\w*[=?!]\=/ display contains=crystalSymbolDelimiter
execute 'syn match crystalSymbol /\%#=1:'.s:overloadable_operators.'\+/ display contains=crystalSymbolDelimiter'

syn match crystalSymbolDelimiter /\%#=1:/ display contained

syn region crystalSymbol matchgroup=crystalSymbolDelimiter start=/\%#=1:"/ end=/\%#=1"/ display contains=crystalStringInterpolation,crystalStringEscape

syn region crystalSymbol matchgroup=crystalSymbolDelimiter start=/\%#=1%i(/  end=/\%#=1)/ display contains=crystalStringArrayParentheses,crystalStringParenthesisEscape
syn region crystalSymbol matchgroup=crystalSymbolDelimiter start=/\%#=1%i\[/ end=/\%#=1]/ display contains=crystalStringArraySquareBrackets,crystalStringSquareBracketEscape
syn region crystalSymbol matchgroup=crystalSymbolDelimiter start=/\%#=1%i{/  end=/\%#=1}/ display contains=crystalStringArrayCurlyBraces,crystalStringCurlyBraceEscape
syn region crystalSymbol matchgroup=crystalSymbolDelimiter start=/\%#=1%i</  end=/\%#=1>/ display contains=crystalStringArrayAngleBrackets,crystalStringAngleBracketEscape
syn region crystalSymbol matchgroup=crystalSymbolDelimiter start=/\%#=1%i|/  end=/\%#=1|/ display contains=crystalStringPipeEscape

syn match crystalNamedTupleKey /\%#=1\<[[:lower:]_]\w*[?!]\=:/he=e-1 display
syn match crystalNamedTupleKey /\%#=1\<\u\w*::\@!/he=e-1 display

syn match crystalNamespaceOperator /\%#=1::/ display nextgroup=crystalConstant

" Regular Expressions {{{3
syn region crystalRegex matchgroup=crystalRegexDelimiter start=/\%#=1\// end=/\%#=1\/[imx]*/ display oneline contains=crystalStringInterpolation,crystalStringEscape,@crystalPCRE

syn match crystalNoRegex /\%#=1\/\// display

syn region crystalRegex matchgroup=crystalRegexDelimiter start=/\%#=1%r(/  end=/\%#=1)/ skip=/\%#=1(.\{-})/  display contains=crystalStringInterpolation,crystalStringEscape,@crystalPCRE
syn region crystalRegex matchgroup=crystalRegexDelimiter start=/\%#=1%r\[/ end=/\%#=1]/ skip=/\%#=1\[.\{-}]/ display contains=crystalStringInterpolation,crystalStringEscape,@crystalPCRE
syn region crystalRegex matchgroup=crystalRegexDelimiter start=/\%#=1%r{/  end=/\%#=1}/ skip=/\%#=1{.\{-}}/  display contains=crystalStringInterpolation,crystalStringEscape,@crystalPCRE
syn region crystalRegex matchgroup=crystalRegexDelimiter start=/\%#=1%r</  end=/\%#=1>/ skip=/\%#=1<.\{-}>/  display contains=crystalStringInterpolation,crystalStringEscape,@crystalPCRE
syn region crystalRegex matchgroup=crystalRegexDelimiter start=/\%#=1%r|/  end=/\%#=1|/ display contains=crystalStringInterpolation,crystalStringEscape,@crystalPCRE

" PCRE {{{4
syn match crystalRegexMetacharacter /\%#=1[.^$|]/ display contained
syn match crystalRegexQuantifier /\%#=1[*+?]/ display contained
syn match crystalRegexQuantifier /\%#=1{\d*,\=\d*}/ display contained
syn region crystalRegexClass matchgroup=crystalRegexMetacharacter start=/\%#=1\[\^\=/ end=/\%#=1]/ display oneline transparent contained contains=crystalRegexEscape,crystalRegexPOSIXClass
syn match crystalRegexPOSIXClass /\%#=1\[\^\=:\%(alnum\|alpha\|ascii\|blank\|cntrl\|digit\|graph\|lower\|print\|punct\|space\|upper\|word\|xdigit\):]/ display contained
syn region crystalRegexGroup matchgroup=crystalRegexMetacharacter start=/\%#=1(\%(?\%([:>|=!]\|<\%([=!]\|\h\w*>\)\)\)\=/ end=/\%#=1)/ display transparent oneline contained
syn region crystalRegexComment start=/\%#=1(#/ end=/\%#=1)/ display oneline contained
syn match crystalRegexEscape /\%#=1\\[dDsSwWAZbBG]/ display contained
syn region crystalRegexEscape matchgroup=crystalRegexEscape start=/\%#=1\\Q/ end=/\%#=1\\E/ display oneline contained
syn match crystalRegexCapturedGroup /\%#=1\\\%(\d\+\|g\%({\w\+}\|<\w\+>\)\)/ display contained
syn match crystalRegexFlags /\%#=1(?[imx]*)/ display contained

syn cluster crystalPCRE contains=
      \ crystalRegexMetacharacter,crystalRegexClass,crystalRegexGroup,crystalRegexComment,
      \ crystalRegexEscape,crystalRegexCapturedGroup,crystalRegexQuantifier,crystalRegexFlags

" Commands {{{3
syn region crystalCommand matchgroup=crystalCommandDelimiter start=/\%#=1`/ end=/\%#=1`/ display contains=crystalStringInterpolation,crystalStringEscape

syn region crystalCommand matchgroup=crystalCommandDelimiter start=/\%#=1%x(/  end=/\%#=1)/ display contains=crystalStringParentheses,crystalStringInterpolation,crystalStringEscape
syn region crystalCommand matchgroup=crystalCommandDelimiter start=/\%#=1%x\[/ end=/\%#=1]/ display contains=crystalStringSquareBrackets,crystalStringInterpolation,crystalStringEscape
syn region crystalCommand matchgroup=crystalCommandDelimiter start=/\%#=1%x{/  end=/\%#=1}/ display contains=crystalStringCurlyBraces,crystalStringInterpolation,crystalStringEscape
syn region crystalCommand matchgroup=crystalCommandDelimiter start=/\%#=1%x</  end=/\%#=1>/ display contains=crystalStringAngleBrackets,crystalStringInterpolation,crystalStringEscape
syn region crystalCommand matchgroup=crystalCommandDelimiter start=/\%#=1%r|/  end=/\%#=1|/ display contains=crystalStringInterpolation,crystalStringEscape

" Definitions {{{2
syn keyword crystalKeyword def macro fun nextgroup=crystalMethodSelf,crystalMethodDefinition skipwhite
syn match crystalMethodSelf /\%#=1self\./he=e-1 display contained nextgroup=crystalMethodDefinition
syn match crystalMethodDefinition /\%#=1[[:lower:]_]\w*[=?!]\=/ display contained
execute 'syn match crystalMethodDefinition /\%#=1'.s:overloadable_operators.'\+/ display contained'

syn keyword crystalKeyword class struct nextgroup=crystalTypeDefinition skipwhite
syn match crystalTypeDefinition /\%#=1\u\w*\%(::\u\w*\)*/ display contained

syn keyword crystalKeyword lib annotation enum module nextgroup=crystalNamespaceDefinition skipwhite
syn match crystalNamespaceDefinition /\%#=1\u\w*\%(::\u\w*\)*/ display contained

" Miscellaneous {{{2
syn keyword crystalKeyword
      \ if unless elsif else end return next break raise case when in
      \ then while until private protected forall of alias begin
      \ rescue ensure yield uninitialized out

syn keyword crystalKeyword do nextgroup=crystalBlockParameters skipwhite
syn match crystalBlockDelimiter /\%#=1{/ display nextgroup=crystalBlockParameters skipwhite
syn match crystalBlockDelimiter /\%#=1}/ display

syn region crystalNestedBlock start=/\%#=1{/ matchgroup=crystalBlockDelimiter end=/\%#=1}/ display contained contains=@crystalTop,crystalNestedBlock

syn region crystalBlockParameters matchgroup=crystalBlockParameterDelimiter start=/\%#=1|/ end=/\%#=1|/ display transparent oneline contained

syn keyword crystalKeyword nextgroup=crystalNilableModifier
      \ getter setter property class_getter class_setter class_property

syn match crystalNilableModifier /\%#=1?/ display contained

syn match crystalMethodOperator /\%#=1\./ display nextgroup=crystalMethod
syn match crystalMethod /\%#=1[[:lower:]_]\w*[=?!]\=/ display contained
execute 'syn match crystalMethod /\%#=1'.s:overloadable_operators.'\+/ display contained'

syn match crystalRangeOperator /\%#=1\.\.\.\=/ display

syn match crystalProcOperator /\%#=1->/ display nextgroup=crystalMethod skipwhite

syn keyword crystalKeyword require nextgroup=crystalString skipwhite

syn region crystalAnnotation matchgroup=crystalAnnotationDelimiter start=/\%#=1@\[/ end=/\%#=1]/ display oneline transparent

" Macros {{{2
syn region crystalMacro matchgroup=crystalMacroDelimiter start=/\%#=1\\\={{/ end=/\%#=1}}/ display containedin=ALLBUT,crystalComment contains=@crystalTop,crystalFreshVariable,crystalNestedBlock
syn region crystalMacro matchgroup=crystalMacroDelimiter start=/\%#=1\\\={%/ end=/\%#=1%}/ display containedin=ALLBUT,crystalComment contains=@crystalTop,crystalFreshVariable

syn keyword crystalKeyword for contained containedin=crystalMacro
" }}}2

unlet s:overloadable_operators

" Highlighting {{{1
hi def link crystalComment Comment
hi def link crystalCommentDelimiter crystalComment
hi def link crystalTodo Todo
hi def link crystalShebang Special
hi def link crystalInstanceVariable Identifier
hi def link crystalClassVariable Identifier
hi def link crystalGlobalVariable Identifier
hi def link crystalConstant Constant
hi def link crystalDelimiter Delimiter
hi def link crystalNil Constant
hi def link crystalBoolean Boolean
hi def link crystalSelf Constant
hi def link crystalNumber Number
hi def link crystalCharacter Character
hi def link crystalCharacterEscape PreProc
hi def link crystalString String
hi def link crystalStringDelimiter crystalString
hi def link crystalStringEscape PreProc
hi def link crystalStringInterpolationDelimiter PreProc
hi def link crystalStringParenthesisEscape crystalStringEscape
hi def link crystalStringSquareBracketEscape crystalStringEscape
hi def link crystalStringCurlyBraceEscape crystalStringEscape
hi def link crystalStringAngleBracketEscape crystalStringEscape
hi def link crystalStringPipeEscape crystalStringEscape
hi def link crystalHeredocLine String
hi def link crystalHeredocLineRaw crystalHeredocLine
hi def link crystalHeredocDelimiter crystalHeredocLine
hi def link crystalSymbol String
hi def link crystalSymbolDelimiter crystalSymbol
hi def link crystalRegex String
hi def link crystalRegexDelimiter crystalRegex
hi def link crystalRegexMetacharacter SpecialChar
hi def link crystalRegexPOSIXClass crystalRegexMetacharacter
hi def link crystalRegexComment Comment
hi def link crystalRegexEscape PreProc
hi def link crystalRegexCapturedGroup crystalRegexMetacharacter
hi def link crystalRegexQuantifier crystalRegexMetacharacter
hi def link crystalCommand String
hi def link crystalCommandDelimiter crystalCommand
hi def link crystalKeyword Keyword
hi def link crystalNilableModifier crystalKeyword
hi def link crystalMethodDefinition Typedef
hi def link crystalMethodSelf crystalSelf
hi def link crystalTypeDefinition Typedef
hi def link crystalNamespaceDefinition Typedef
hi def link crystalMacroDelimiter PreProc
hi def link crystalFreshVariable Identifier
hi def link crystalAnnotationDelimiter Special
" }}}1

" vim:fdm=marker
