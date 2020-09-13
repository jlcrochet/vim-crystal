" Vim syntax file
" Language: Crystal <crystal-lang.org>
" Author: Jeffrey Crochet <jlcrochet@pm.me>
" URL: https://github.com/jlcrochet/vim-crystal

if get(b:, "current_syntax")
  finish
endif

let b:current_syntax = "crystal"

" Syntax {{{1
let s:overloadable_operators = '\%(+\|-\|\*\*\=\|\/\/\=\|=\%(==\=\|\~\)\|![=~]\=\|<\%(<\|=>\=\)\=\|>[>=]\=\|&\%(+\|-\|\*\*\=\)\=\||\|\^\|\~\|%\|\[][=?]\=\)'

syn cluster crystalTop contains=TOP

syn region crystalComment start=/\%#=1#/ end=/\%#=1\_$/ display oneline contains=crystalTodo
syn keyword crystalTodo TODO NOTE XXX FIXME HACK TBD contained

syn region crystalShebang start=/\%#=1\%^#!/ end=/\%#=1\_$/ display oneline

" Identifiers {{{2
syn match crystalVariableOrMethod /\%#=1[[:lower:]_]\w*[?!]\=/ display nextgroup=crystalBinaryOperator,crystalTypeDeclarationOperator,crystalNamedTupleKey,crystalRegex,crystalString skipwhite
syn match crystalInstanceVariable /\%#=1@\h\w*/ display nextgroup=crystalBinaryOperator,crystalTypeDeclarationOperator skipwhite
syn match crystalClassVariable /\%#=1@@\h\w*/ display nextgroup=crystalBinaryOperator,crystalTypeDeclarationOperator skipwhite
syn match crystalGlobalVariable /\%#=1\$\%([~?[:digit:]]\|\h\w*\)/ display nextgroup=crystalBinaryOperator skipwhite

syn match crystalConstant /\%#=1\u\w*/ display nextgroup=crystalBinaryOperator,crystalNamespaceOperator,crystalGeneric skipwhite
syn region crystalGeneric matchgroup=crystalDelimiter start=/\%#=1(/ end=/\%#=1)/ display contained contains=crystalType,crystalTypeGroup,crystalTypeof

" NOTE: This pattern is for matching variable declarations in specific
" regions.
syn match crystalDeclarator /\%#=1[[:lower:]_]\w*/ display contained nextgroup=crystalTypeDeclarationOperator,crystalAssignmentOperator skipwhite
syn match crystalDeclarator /\%#=1@\h\w*/ display contained nextgroup=crystalTypeDeclarationOperator,crystalAssignmentOperator skipwhite

" Operators {{{2
syn match crystalUnaryOperator /\%#=1[!~+-]/ display

syn match crystalMethodOperator /\%#=1\./ display nextgroup=crystalVariableOrMethod,crystalOperatorMethod
execute 'syn match crystalOperatorMethod /\%#=1'.s:overloadable_operators.'/ display contained nextgroup=crystalBinaryOperator'

syn match crystalRangeOperator /\%#=1\.\.\.\=/ display

" NOTE: Operators involving `/` are *not* included in this pattern; they
" are defined later in the "Regular Expressions" section.
syn match crystalBinaryOperator /\%#=1\%(=\%(==\=\|[>~]\)\|![=~]\|<\%(=>\=\|<=\=\)\=\|>>\==\=\|+=\=\|-=\=\|\*\*\==\=\|%=\=\|&\%(&=\=\|=\|+=\=\|-=\=\|\*[*=]\=\|\)||\==\=\|^=\=\)/ display contained
syn region crystalBinaryOperator matchgroup=crystalBinaryOperator start=/\%#=1\[/ end=/\%#=1]?\=/ display transparent contained nextgroup=crystalBinaryOperator skipwhite

" NOTE: Assignment operators are already included in the
" `crystalBinaryOperator` group above; this is defined separately for
" use in places where *only* an assignment operator is allowed.
syn match crystalAssignmentOperator /\%#=1=/ display contained nextgroup=@crystalTop skipwhite

" Type Declarations {{{3
syn match crystalTypeDeclarationOperator /\%#=1:\ze\s\+/ display contained nextgroup=crystalType,crystalTypeGroup,crystalTypeof
syn match crystalType /\%#=1\u\w*/ display contained nextgroup=crystalTypeGroup,crystalTypePointer,crystalTypeNullable,crystalTypeUnion,crystalTypeLambda,crystalTypeNamespace,crystalAssignmentOperator skipwhite
syn keyword crystalTypeSelf self contained nextgroup=crystalTypeUnion,crystalTypeLambda,crystalAssignmentOperator skipwhite
syn region crystalTypeGroup matchgroup=crystalDelimiter start=/\%#=1(/ end=/\%#=1)/ display contained contains=crystalType,crystalTypeGroup,crystalTypeSelf,crystalTypeOf,crystalTypeTuple,crystalNamedTupleKey nextgroup=crystalTypePointer,crystalTypeNullable,crystalTypeUnion,crystalTypeLambda,crystalTypeRocket,crystalAssignmentOperator skipwhite
syn region crystalTypeTuple matchgroup=crystalDelimiter start=/\%#=1{/ end=/\%#=1}/ display contained contains=crystalType,crystalTypeGroup,crystalTypeSelf,crystalTypeOf,crystalTypeTuple,crystalNamedTupleKey nextgroup=crystalTypeUnion,crystalTypeLambda,crystalTypeRocket skipwhite
syn keyword crystalTypeof typeof nextgroup=crystalTypeofArgument skipwhite
syn region crystalTypeofArgument matchgroup=crystalDelimiter start=/\%#=1(/ end=/\%#=1)/ display contained contains=TOP nextgroup=crystalTypePointer,crystalTypeNullable,crystalTypeUnion skipwhite
syn match crystalTypePointer /\%#=1\*\+/ display contained nextgroup=crystalTypeUnion,crystalTypeLambda,crystalTypeRocket skipwhite
syn match crystalTypeNullable /\%#=1?/ display contained nextgroup=crystalTypeUnion,crystalTypeLambda,crystalTypeRocket skipwhite
syn match crystalTypeUnion /\%#=1|/ display contained nextgroup=crystalType,crystalTypeGroup,crystalTypeof,crystalTypeSelf skipwhite
syn match crystalTypeLambda /\%#=1->/ display contained nextgroup=crystalType,crystalTypeGroup,crystalTypeTuple,crystalTypeof,crystalTypeSelf skipwhite
syn match crystalTypeRocket /\%#=1=>/ display contained nextgroup=crystalType,crystalTypeGroup,crystalTypeTuple,crystalTypeof,crystalTypeSelf skipwhite
syn match crystalTypeNamespace /\%#=1::/ display contained nextgroup=crystalType
" }}}3

" NOTE: This is called a "binary" operator for the sake of convenience,
" but it actually refers to the `?:` ternary operator.
syn region crystalBinaryOperator matchgroup=crystalBinaryOperator start=/\%#=1?/ end=/\%#=1:/ display transparent contained

syn match crystalNamespaceOperator /\%#=1::/ display nextgroup=crystalVariableOrMethod,crystalConstant

" Literals {{{2
syn keyword crystalNil nil nextgroup=crystalBinaryOperator skipwhite
syn keyword crystalBoolean true false nextgroup=crystalBinaryOperator skipwhite
syn keyword crystalSelf self nextgroup=crystalBinaryOperator skipwhite

" Numbers {{{3
function s:or(...)
  return '\%('.join(a:000, '\|').'\)'
endfunction

function s:optional(re)
  return '\%('.a:re.'\)\='
endfunction

let s:zero = '0\%(_[[:digit:]_]*\)\='
let s:decimal = '[1-9][[:digit:]_]*'
let s:fraction = '\.\d[[:digit:]_]*'
let s:binary = '0b[01_]*'
let s:octal = '0o[0-7_]*'
let s:hexadecimal = '0x[[:xdigit:]_]*'

let s:integer_suffix = '[ui]\%(8\|16\|32\|64\|128\)'
let s:float_suffix = 'f\%(8\|16\|32\|64\|128\)'
let s:exponent_suffix = '[eE]_*[+-]\=\d[[:digit:]_]*'

let s:syn_match_template = 'syn match crystalNumber /\%%#=1%s/ display nextgroup=crystalBinaryOperator skipwhite'

let s:optional_re = s:or(
      \ s:integer_suffix,
      \ s:float_suffix,
      \ s:exponent_suffix . s:optional(s:float_suffix),
      \ s:fraction . s:optional(s:exponent_suffix) . s:optional(s:float_suffix)
      \ ) . '\='

let s:zero_re = s:zero . s:optional_re
let s:decimal_re = s:decimal . s:optional_re
let s:binary_re = s:binary . s:optional(s:integer_suffix)
let s:octal_re = s:octal . s:optional(s:integer_suffix)
let s:hexadecimal_re = s:hexadecimal . s:optional(s:integer_suffix)

execute printf(s:syn_match_template, s:zero_re)
execute printf(s:syn_match_template, s:decimal_re)
execute printf(s:syn_match_template, s:binary_re)
execute printf(s:syn_match_template, s:octal_re)
execute printf(s:syn_match_template, s:hexadecimal_re)

delfunction s:or
delfunction s:optional

unlet
      \ s:zero s:decimal s:fraction s:binary s:octal s:hexadecimal
      \ s:integer_suffix s:float_suffix s:exponent_suffix s:optional_re
      \ s:zero_re s:decimal_re s:binary_re s:octal_re s:hexadecimal_re

" Characters {{{3
syn match crystalCharacter /\%#=1'\%(\\\%(u\%(\x\{4}\|{\x\{1,6}}\)\|['\\abefnrtv0]\)\|.\)'/ display contains=crystalCharacterEscape nextgroup=crystalBinaryOperator skipwhite
syn match crystalCharacterEscape /\%#=1\\\%(u\%(\x\{4}\|{\x\{1,6}}\)\|['\\abefnrtv0]\)/ display contained

" Delimiters {{{3
syn match crystalDelimiter /\%#=1(/ display
syn match crystalDelimiter /\%#=1)/ display nextgroup=crystalBinaryOperator skipwhite

syn match crystalDelimiter /\%#=1\[/ display
syn match crystalDelimiter /\%#=1]/  display nextgroup=crystalBinaryOperator,crystalOf skipwhite
syn keyword crystalOf of contained nextgroup=crystalType,crystalTypeGroup,crystalTypeof skipwhite

syn match crystalDelimiter /\%#=1{/ display nextgroup=crystalBlockParameters,crystalNamedTupleKey skipwhite skipnl
syn match crystalDelimiter /\%#=1}/ display nextgroup=crystalBinaryOperator skipwhite

syn match crystalDelimiter /\%#=1,/ display nextgroup=crystalNamedTupleKey skipwhite skipnl

" Strings {{{3
syn region crystalString start=/\%#=1"/ end=/\%#=1"/ display contains=crystalStringInterpolation,crystalStringEscape nextgroup=crystalBinaryOperator skipwhite

syn region crystalString start=/\%#=1%Q\=(/ end=/\%#=1)/ display contains=crystalStringParentheses,crystalStringInterpolation,crystalStringEscape nextgroup=crystalBinaryOperator skipwhite
syn region crystalStringParentheses start=/\%#=1(/ end=/\%#=1)/ display transparent contained contains=crystalStringParentheses,crystalStringInterpolation,crystalStringEscape

syn region crystalString start=/\%#=1%Q\=\[/ end=/\%#=1]/ display contains=crystalStringParentheses,crystalStringInterpolation,crystalStringEscape nextgroup=crystalBinaryOperator skipwhite
syn region crystalStringSquareBrackets start=/\%#=1\[/ end=/\%#=1]/ display transparent contained contains=crystalStringSquareBrackets,crystalStringInterpolation,crystalStringEscape

syn region crystalString start=/\%#=1%Q\={/ end=/\%#=1}/ display contains=crystalStringCurlyBraces,crystalStringInterpolation,crystalStringEscape nextgroup=crystalBinaryOperator skipwhite
syn region crystalStringCurlyBraces start=/\%#=1{/ end=/\%#=1}/ display transparent contained contains=crystalStringCurlyBraces,crystalStringInterpolation,crystalStringEscape

syn region crystalString start=/\%#=1%Q\=</ end=/\%#=1>/ display contains=crystalStringAngleBrackets,crystalStringInterpolation,crystalStringEscape nextgroup=crystalBinaryOperator skipwhite
syn region crystalStringAngleBrackets start=/\%#=1</ end=/\%#=1>/ display transparent contained contains=crystalStringAngleBrackets,crystalStringInterpolation,crystalStringEscape

syn region crystalString start=/\%#=1%Q\=|/ end=/\%#=1|/ display contains=crystalStringInterpolation,crystalStringEscape nextgroup=crystalBinaryOperator skipwhite

syn region crystalStringInterpolation matchgroup=crystalStringInterpolationDelimiter start=/\%#=1#{/ end=/\%#=1}/ display contained contains=TOP
syn match crystalStringEscape /\%#=1\\\%(\d\{1,3}\|x\x\x\|u\%(\x\{4}\|{\x\{1,6}\%(\s\x\{1,6}\)*}\)\|\_.\)/ display contained

" Raw Strings {{{3
syn region crystalString start=/\%#=1%q(/  end=/\%#=1)/ skip=/\%#=1(.\{-})/  display nextgroup=crystalBinaryOperator skipwhite
syn region crystalString start=/\%#=1%q\[/ end=/\%#=1]/ skip=/\%#=1\[.\{-}]/ display nextgroup=crystalBinaryOperator skipwhite
syn region crystalString start=/\%#=1%q{/  end=/\%#=1}/ skip=/\%#=1{.\{-}}/  display nextgroup=crystalBinaryOperator skipwhite
syn region crystalString start=/\%#=1%q</  end=/\%#=1>/ skip=/\%#=1<.\{-}>/  display nextgroup=crystalBinaryOperator skipwhite
syn region crystalString start=/\%#=1%q|/  end=/\%#=1|/ display nextgroup=crystalBinaryOperator skipwhite

" String Arrays {{{3
syn region crystalString start=/\%#=1%w(/ end=/\%#=1)/ display contains=crystalStringArrayParentheses,crystalStringParenthesisEscape nextgroup=crystalBinaryOperator skipwhite
syn region crystalStringArrayParentheses start=/\%#=1(/ end=/\%#=1)/ display transparent contained contains=crystalStringArrayParentheses,crystalStringParenthesisEscape
syn match crystalStringParenthesisEscape /\%#=1\\[()[:space:]]/ display contained

syn region crystalString start=/\%#=1%w\[/ end=/\%#=1]/ display contains=crystalStringArraySquareBrackets,crystalStringSquareBracketEscape nextgroup=crystalBinaryOperator skipwhite
syn region crystalStringArraySquareBrackets start=/\%#=1\[/ end=/\%#=1]/ display transparent contained contains=crystalStringArraySquareBrackets,crystalStringSquareBracketEscape
syn match crystalStringSquareBracketEscape /\%#=1\\[\[\][:space:]]/ display contained

syn region crystalString start=/\%#=1%w{/ end=/\%#=1}/ display contains=crystalStringArrayCurlyBraces,crystalStringCurlyBraceEscape nextgroup=crystalBinaryOperator skipwhite
syn region crystalStringArrayCurlyBraces start=/\%#=1{/ end=/\%#=1}/ display transparent contained contains=crystalStringArrayCurlyBraces,crystalStringCurlyBraceEscape
syn match crystalStringCurlyBraceEscape /\%#=1\\[{}[:space:]]/ display contained

syn region crystalString start=/\%#=1%w</ end=/\%#=1>/ display contains=crystalStringArrayAngleBrackets,crystalStringAngleBracketEscape nextgroup=crystalBinaryOperator skipwhite
syn region crystalStringArrayAngleBrackets start=/\%#=1</ end=/\%#=1>/ display transparent contained contains=crystalStringArrayAngleBrackets,crystalStringAngleBracketEscape
syn match crystalStringAngleBracketEscape /\%#=1\\[<>[:space:]]/ display contained

syn region crystalString start=/\%#=1%w|/ end=/\%#=1|/ display contains=crystalStringPipeEscape nextgroup=crystalBinaryOperator skipwhite
syn match crystalStringPipeEscape /\%#=1\\[|[:space:]]/ display contained

" Here Documents {{{3
syn region crystalHeredoc matchgroup=crystalHeredocDelimiter start=/\%#=1<<-\z(\w\+\)/ end=/\%#=1\_^\s*\z1\>/ display transparent keepend contains=@crystalTop,crystalHeredocLine nextgroup=crystalBinaryOperator skipwhite
syn region crystalHeredocLine start=/\%#=1\_^/ end=/\%#=1\_$/ display oneline contained contains=crystalStringInterpolation,crystalStringEscape

syn region crystalHeredoc matchgroup=crystalHeredocDelimiter start=/\%#=1<<-'\z(\w[[:alnum:][:blank:]_]*\)'/ end=/\%#=1\_^\s*\z1/ display transparent keepend contains=@crystalTop,crystalHeredocLineRaw nextgroup=crystalBinaryOperator skipwhite
syn region crystalHeredocLineRaw start=/\%#=1\_^/ end=/\%#=1\_$/ display oneline contained

" Symbols {{{3
syn match crystalSymbol /\%#=1:\h\w*[?!]\=/ display nextgroup=crystalBinaryOperator skipwhite
execute 'syn match crystalSymbol /\%#=1'.s:overloadable_operators.'/ display nextgroup=crystalBinaryOperator skipwhite'

syn region crystalSymbol start=/\%#=1:"/ end=/\%#=1"/ display contains=crystalStringEscape nextgroup=crystalBinaryOperator skipwhite

syn region crystalSymbol start=/\%#=1%i(/  end=/\%#=1)/ display contains=crystalStringArrayParentheses,crystalStringParenthesisEscape nextgroup=crystalBinaryOperator skipwhite
syn region crystalSymbol start=/\%#=1%i\[/ end=/\%#=1]/ display contains=crystalStringArraySquareBrackets,crystalStringSquareBracketEscape nextgroup=crystalBinaryOperator skipwhite
syn region crystalSymbol start=/\%#=1%i{/  end=/\%#=1}/ display contains=crystalStringArrayCurlyBraces,crystalStringCurlyBraceEscape nextgroup=crystalBinaryOperator skipwhite
syn region crystalSymbol start=/\%#=1%i</  end=/\%#=1>/ display contains=crystalStringArrayAngleBrackets,crystalStringAngleBracketEscape nextgroup=crystalBinaryOperator skipwhite
syn region crystalSymbol start=/\%#=1%i|/  end=/\%#=1|/ display contains=crystalStringPipeEscape nextgroup=crystalBinaryOperator skipwhite

syn match crystalNamedTupleKey /\%#=1[[:lower:]_]\w*[?!]\=:/he=e-1 display contained
syn match crystalNamedTupleKey /\%#=1\u\w*::\@!/he=e-1 display contained

" Regular Expressions {{{3
syn match crystalBinaryOperator /\%#=1\// display contained

syn region crystalRegex start=/\%#=1\// end=/\%#=1\/[imx]*/ display oneline contains=crystalStringInterpolation,crystalStringEscape,@crystalPCRE nextgroup=crystalBinaryOperator skipwhite

syn match crystalBinaryOperator /\%#=1\/[/=]/ display contained

syn region crystalRegex start=/\%#=1%r(/  end=/\%#=1)/ display contains=crystalStringParentheses,crystalStringInterpolation,crystalStringEscape,@crystalPCRE nextgroup=crystalBinaryOperator skipwhite
syn region crystalRegex start=/\%#=1%r\[/ end=/\%#=1]/ display contains=crystalStringSquareBrackets,crystalStringInterpolation,crystalStringEscape,@crystalPCRE nextgroup=crystalBinaryOperator skipwhite
syn region crystalRegex start=/\%#=1%r{/  end=/\%#=1}/ display contains=crystalStringCurlyBraces,crystalStringInterpolation,crystalStringEscape,@crystalPCRE nextgroup=crystalBinaryOperator skipwhite
syn region crystalRegex start=/\%#=1%r</  end=/\%#=1>/ display contains=crystalStringAngleBrackets,crystalStringInterpolation,crystalStringEscape,@crystalPCRE nextgroup=crystalBinaryOperator skipwhite
syn region crystalRegex start=/\%#=1%r|/  end=/\%#=1|/ display contains=crystalStringInterpolation,crystalStringEscape,@crystalPCRE nextgroup=crystalBinaryOperator skipwhite

" PCRE {{{4
syn region crystalRegexClass matchgroup=crystalRegexSpecial start=/\%#=1\[\^\=/ end=/\%#=1]/ display oneline contained contains=crystalRegexEscape,crystalRegexPOSIXClass
syn match crystalRegexPOSIXClass /\%#=1\[\^\=:\%(alnum\|alpha\|ascii\|blank\|cntrl\|digit\|graph\|lower\|print\|punct\|space\|upper\|word\|xdigit\):]/ display contained
syn region crystalRegexGroup matchgroup=crystalRegexSpecial start=/\%#=1(\%(?\%([:>|=!]\|<[=!]\|P\%(<\h\w*>\|[&=]\=\h\w*\)\)\|R\|\d\+\|(.\{-})|\)\=/ end=/\%#=1)/ display transparent oneline contained
syn region crystalRegexComment start=/\%#=1(#/ end=/\%#=1)/ display oneline contained
syn match crystalRegexEscape /\%#=1\\[dDsSwWAZbBG]/ display contained
syn region crystalRegexEscape matchgroup=crystalRegexEscape start=/\%#=1\\Q/ end=/\%#=1\\E/ display oneline contained
syn match crystalRegexCapturedGroup /\%#=1\\\%(\d\+\|g\%({\w\+}\|<\w\+>\)\)/ display contained
syn match crystalRegexBranchDelimiter /\%#=1|/ display contained
syn match crystalRegexQuantifier /\%#=1[*+?]/ display contained
syn region crystalRegexQuantifier start=/\%#=1{/ end=/\%#=1}/ display oneline contained
syn match crystalRegexFlags /\%#=1(?[imx]*)/ display contained

syn cluster crystalPCRE contains=
      \ crystalRegexClass,crystalRegexGroup,crystalRegexComment,crystalRegexEscape,crystalRegexCapturedGroup,
      \ crystalRegexBranchDelimiter,crystalRegexQuantifier,crystalRegexFlags

" Commands {{{3
syn region crystalCommand start=/\%#=1`/ end=/\%#=1`/ display contains=crystalStringInterpolation,crystalStringEscape nextgroup=crystalBinaryOperator skipwhite

syn region crystalCommand start=/\%#=1%x(/  end=/\%#=1)/ display contains=crystalStringParentheses,crystalStringInterpolation,crystalStringEscape nextgroup=crystalBinaryOperator skipwhite
syn region crystalCommand start=/\%#=1%x\[/ end=/\%#=1]/ display contains=crystalStringSquareBrackets,crystalStringInterpolation,crystalStringEscape nextgroup=crystalBinaryOperator skipwhite
syn region crystalCommand start=/\%#=1%x{/  end=/\%#=1}/ display contains=crystalStringCurlyBraces,crystalStringInterpolation,crystalStringEscape nextgroup=crystalBinaryOperator skipwhite
syn region crystalCommand start=/\%#=1%x</  end=/\%#=1>/ display contains=crystalStringAngleBrackets,crystalStringInterpolation,crystalStringEscape nextgroup=crystalBinaryOperator skipwhite
syn region crystalCommand start=/\%#=1%r|/  end=/\%#=1|/ display contains=crystalStringInterpolation,crystalStringEscape nextgroup=crystalBinaryOperator skipwhite

" Blocks and Procs {{{3
syn keyword crystalKeyword do nextgroup=crystalBlockParameters skipwhite
syn region crystalBlockParameters matchgroup=crystalDelimiter start=/\%#=1|/ end=/\%#=1|/ display oneline contained contains=crystalDeclarator,crystalParameterModifier

syn match crystalProcOperator /\%#=1->/ display nextgroup=crystalParameters skipwhite
syn region crystalParameters matchgroup=crystalDelimiter start=/\%#=1(/ end=/\%#=1)/ display contained contains=crystalDeclarator,crystalParameterModifier nextgroup=crystalTypeDeclarationOperator skipwhite

syn match crystalParameterModifier /\%#=1\*\*\=/ display contained nextgroup=crystalDeclarator
syn match crystalParameterModifier /\%#=1&/ display contained nextgroup=crystalDeclarator
" }}}3

" Definitions {{{2
syn keyword crystalKeyword def macro nextgroup=crystalMethodDefinition skipwhite
syn match crystalMethodDefinition /\%#=1\%(self\.\)\=[[:lower:]_]\w*/ display contained contains=crystalMethodSelf nextgroup=crystalParameters skipwhite
syn keyword crystalMethodSelf self contained

syn keyword crystalKeyword class struct nextgroup=crystalTypeDefinition skipwhite
syn match crystalTypeDefinition /\%#=1\u\w*/ display contained nextgroup=crystalTypeDefinitionNamespace,crystalGeneric
syn match crystalTypeDefinitionNamespace /\%#=1::/ display contained nextgroup=crystalTypeDefinition

syn keyword crystalKeyword lib annotation enum module nextgroup=crystalNamespaceDefinition skipwhite
syn match crystalNamespaceDefinition /\%#=1\u\w*/ display contained nextgroup=crystalNamespaceDefinitionNamespace
syn match crystalNamespaceDefinitionNamespace /\%#=1::/ display contained nextgroup=crystalNamespaceDefinition

" Miscellaneous Keywords {{{2
syn keyword crystalKeyword
      \ if elsif else end return next break raise case when in then
      \ while until

syn keyword crystalKeyword require nextgroup=crystalString skipwhite

syn keyword crystalKeyword nextgroup=crystalDeclarator skipwhite
      \ getter setter property class_getter class_setter class_property
" }}}2

unlet s:overloadable_operators

" Highlighting {{{1
" }}}1

" vim:fdm=marker
