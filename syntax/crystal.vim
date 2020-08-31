" Vim syntax file
" Language: Crystal <crystal-lang.org>
" Author: Jeffrey Crochet <jlcrochet@pm.me>
" URL: https://github.com/jlcrochet/vim-crystal

" TODO
" * Make sure that named tuple keys only occur after methods, commas,
" and inside method definitions
" * Introduce alternate : as type declaration operator

if exists('b:current_syntax')
  finish
endif

" Top-level groups {{{1
syn cluster crystalTop contains=TOP

syn region crystalComment start=/#/ end=/\_$/ display oneline contains=crystalTodo,crystalSharpBang

syn match crystalVariableOrMethod   /\%#=1\<\%(\l\|_\)\w*[?!]\=/ display nextgroup=crystalBinaryOperator,crystalBracketOperator,crystalParentheses,crystalBrace,crystalCapturedBlock,crystalSymbol,crystalString,crystalRegexp,crystalHeredoc skipwhite
syn match crystalConstant           /\%#=1\u\w*/ display nextgroup=crystalBinaryOperator,crystalBracketOperator skipwhite
syn match crystalGlobalVariable     /\%#=1\$\h\w*/ display nextgroup=crystalBinaryOperator,crystalBracketOperator skipwhite
syn match crystalInstanceVariable   /\%#=1@\h\w*/ display nextgroup=crystalBinaryOperator,crystalBracketOperator skipwhite
syn match crystalClassVariable      /\%#=1@@\h\w*/ display nextgroup=crystalBinaryOperator,crystalBracketOperator skipwhite
syn match crystalPredefinedVariable /\%#=1\$[~?[:digit:]]/ display nextgroup=crystalBinaryOperator,crystalBracketOperator skipwhite
syn match crystalFreshVariable      /\%#=1%\%(\l\|_\)\w*/ display contained nextgroup=crystalBinaryOperator,crystalBracketOperator skipwhite

" Unary operators
syn match crystalUnaryOperator /\%#=1!/ display
syn match crystalUnaryOperator /\%#=1\~/ display
syn match crystalUnaryOperator /\%#=1+/ display
syn match crystalUnaryOperator /\%#=1-/ display
syn match crystalUnaryOperator /\%#=1&+/ display
syn match crystalUnaryOperator /\%#=1&-/ display
syn match crystalUnaryOperator /\%#=1\*\*\=/ display

" Binary operators
syn match crystalBinaryOperator /\%#=1||\==\=/ display contained
syn match crystalBinaryOperator /\%#=1=\%(==\=\|\~\)\=/ display contained
syn match crystalBinaryOperator /\%#=1\/\/\==\=/ display contained
syn match crystalBinaryOperator /\%#=1+=\=/ display contained
syn match crystalBinaryOperator /\%#=1-[=>]\=/ display contained
syn match crystalBinaryOperator /\%#=1::\=/ display contained
syn match crystalBinaryOperator /\%#=1?/ display contained
syn match crystalBinaryOperator /\%#=1&\%(=\|&=\=\|+=\=\|-=\=\|\*\*\==\=\)\=/ display contained
syn match crystalBinaryOperator /\%#=1![=~]/ display contained
syn match crystalBinaryOperator /\%#=1\^=\=/ display contained
syn match crystalBinaryOperator /\%#=1\*\*\==\=/ display contained
syn match crystalBinaryOperator /\%#=1<\%(<=\=\|=>\=\)\=/ display contained
syn match crystalBinaryOperator /\%#=1>>\==\=/ display contained
syn match crystalBinaryOperator /\%#=1%=\=/ display contained
syn match crystalBinaryOperator /\%#=1\.\.\.\=/ display contained

syn match crystalDotOperator /\./ display nextgroup=crystalVariableOrMethod

syn match crystalCapturedBlock /\%#=1&\%(\l\|_\)\w*/ display nextgroup=crystalBinaryOperator,crystalBracketOperator skipwhite
syn match crystalCapturedBlock /\%#=1&\./ display contains=crystalDotOperator nextgroup=crystalVariableOrMethod,crystalBinaryOperator skipwhite

syn region crystalParentheses matchgroup=crystalParenthesis start=/(/ end=/)/ display contains=TOP nextgroup=crystalBinaryOperator,crystalBracketOperator,crystalBrace skipwhite

syn region crystalArray matchgroup=crystalBracket start=/\[/ end=/]/ display contains=TOP nextgroup=crystalBinaryOperator,crystalBracketOperator skipwhite

syn region crystalBracketOperator matchgroup=crystalBinaryOperator start=/\[/ end=/]?\=/ display contained contains=TOP nextgroup=crystalBinaryOperator,crystalBracketOperator skipwhite

function s:or(...)
  return '\%('.join(a:000, '\|').'\)'
endfunction

function s:optional(re)
  return '\%('.a:re.'\)\='
endfunction

let s:zero = '0_*[[:digit:]_]*'
let s:decimal = '[1-9][[:digit:]_]*'
let s:fraction = '\.\d[[:digit:]_]*'
let s:binary = '0b[01_]*'
let s:octal = '0o[0-7_]*'
let s:hexadecimal = '0x[[:xdigit:]_]*'

let s:integer_suffix = '[ui]\%(8\|16\|32\|64\|128\)'
let s:float_suffix = 'f\%(8\|16\|32\|64\|128\)'
let s:exponent_suffix = '[eE]_*[+-]\=\d[[:digit:]_]*'

let s:syn_match_template = 'syn match crystalNumber /\%%#=1%s/ display nextgroup=crystalBinaryOperator,crystalDotOperator,crystalBracketOperator skipwhite'

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

syn keyword crystalBoolean true false nextgroup=crystalBinaryOperator,crystalBracketOperator skipwhite

syn keyword crystalPseudoVariable self nil __DIR__ __FILE__ __LINE__ __END_LINE__ nextgroup=crystalBinaryOperator,crystalBracketOperator skipwhite

syn match crystalCharLiteral /'\%(\\\%(\o\{1,3}\|x\x\{1,2}\|u\x\{4}\|u{\x\{1,6}}\|.\)\|.\)'/ display contains=crystalEscapeSequence nextgroup=crystalBinaryOperator,crystalBracketOperator skipwhite

syn region crystalString start=/"/ end=/"/ display contains=crystalEscapeSequence,crystalStringInterpolation nextgroup=crystalBinaryOperator,crystalBracketOperator skipwhite

syn region crystalString matchgroup=crystalString start=/\%#=1%q(/  end=/)/  display contains=crystalStringNestedRawParentheses    nextgroup=crystalBinaryOperator,crystalBracketOperator skipwhite
syn region crystalString matchgroup=crystalString start=/\%#=1%q{/  end=/}/  display contains=crystalStringNestedRawBraces         nextgroup=crystalBinaryOperator,crystalBracketOperator skipwhite
syn region crystalString matchgroup=crystalString start=/\%#=1%q</  end=/>/  display contains=crystalStringNestedRawAngleBrackets  nextgroup=crystalBinaryOperator,crystalBracketOperator skipwhite
syn region crystalString matchgroup=crystalString start=/\%#=1%q\[/ end=/\]/ display contains=crystalStringNestedRawSquareBrackets nextgroup=crystalBinaryOperator,crystalBracketOperator skipwhite
syn region crystalString matchgroup=crystalString start=/\%#=1%q|/  end=/|/  display                                               nextgroup=crystalBinaryOperator,crystalBracketOperator skipwhite

syn region crystalString matchgroup=crystalString start=/\%#=1%[wi](/  end=/)/  display contains=crystalStringNestedParentheses    nextgroup=crystalBinaryOperator,crystalBracketOperator skipwhite
syn region crystalString matchgroup=crystalString start=/\%#=1%[wi]{/  end=/}/  display contains=crystalStringNestedBraces         nextgroup=crystalBinaryOperator,crystalBracketOperator skipwhite
syn region crystalString matchgroup=crystalString start=/\%#=1%[wi]</  end=/>/  display contains=crystalStringNestedAngleBrackets  nextgroup=crystalBinaryOperator,crystalBracketOperator skipwhite
syn region crystalString matchgroup=crystalString start=/\%#=1%[wi]\[/ end=/\]/ display contains=crystalStringNestedSquareBrackets nextgroup=crystalBinaryOperator,crystalBracketOperator skipwhite
syn region crystalString matchgroup=crystalString start=/\%#=1%[wi]|/  end=/|/  display                                            nextgroup=crystalBinaryOperator,crystalBracketOperator skipwhite

syn region crystalString matchgroup=crystalString start=/\%#=1%[Qx]\=(/  end=/)/  display contains=crystalEscapeSequence,crystalStringInterpolation,crystalStringNestedParentheses    nextgroup=crystalBinaryOperator,crystalBracketOperator skipwhite
syn region crystalString matchgroup=crystalString start=/\%#=1%[Qx]\={/  end=/}/  display contains=crystalEscapeSequence,crystalStringInterpolation,crystalStringNestedBraces         nextgroup=crystalBinaryOperator,crystalBracketOperator skipwhite
syn region crystalString matchgroup=crystalString start=/\%#=1%[Qx]\=</  end=/>/  display contains=crystalEscapeSequence,crystalStringInterpolation,crystalStringNestedAngleBrackets  nextgroup=crystalBinaryOperator,crystalBracketOperator skipwhite
syn region crystalString matchgroup=crystalString start=/\%#=1%[Qx]\=\[/ end=/\]/ display contains=crystalEscapeSequence,crystalStringInterpolation,crystalStringNestedSquareBrackets nextgroup=crystalBinaryOperator,crystalBracketOperator skipwhite
syn region crystalString matchgroup=crystalString start=/\%#=1%[Qx]\=|/  end=/|/  display contains=crystalEscapeSequence,crystalStringInterpolation                                   nextgroup=crystalBinaryOperator,crystalBracketOperator skipwhite

syn match crystalSymbol /\%#=1:\h\w*[?!]\=/ display nextgroup=crystalBinaryOperator,crystalBracketOperator skipwhite
syn match crystalSymbol /\%#=1:\%(+\|-\|\*\*\=\|\/\/\=\|=\%(==\=\|\~\)\|![=~]\=\|<\%(<\|=>\=\)\=\|>[>=]\=\|&\%(+\|-\|\*\*\=\)\=\||\|\^\|\~\|%\|\[][=?]\=\)/ display nextgroup=crystalBinaryOperator,crystalBracketOperator skipwhite

syn region crystalSymbol start=/\%#=1:"/ end=/"/ display contains=crystalEscapeSequence,crystalStringInterpolation nextgroup=crystalBinaryOperator,crystalBracketOperator skipwhite

syn match crystalNamedTupleKey /\%#=1\h\w*:/he=e-1 display

syn region crystalRegexp start=/\%#=1\/\/\@!=\@!/ end=/\%#=1\/[imx]*/ display oneline contains=@crystalInsideRegexp nextgroup=crystalBinaryOperator,crystalBracketOperator skipwhite

syn region crystalRegexp matchgroup=crystalRegexp start=/\%#=1%r(/  end=/)[imx]*/  display contains=@crystalInsideRegexp nextgroup=crystalBinaryOperator,crystalBracketOperator skipwhite
syn region crystalRegexp matchgroup=crystalRegexp start=/\%#=1%r\[/ end=/\][imx]*/ display contains=@crystalInsideRegexp nextgroup=crystalBinaryOperator,crystalBracketOperator skipwhite
syn region crystalRegexp matchgroup=crystalRegexp start=/\%#=1%r{/  end=/}[imx]*/  display contains=@crystalInsideRegexp,crystalRegexpNestedBraces nextgroup=crystalBinaryOperator,crystalBracketOperator skipwhite
syn region crystalRegexp matchgroup=crystalRegexp start=/\%#=1%r</  end=/>[imx]*/  display contains=@crystalInsideRegexp,crystalRegexpNestedAngleBrackets nextgroup=crystalBinaryOperator,crystalBracketOperator skipwhite
syn region crystalRegexp matchgroup=crystalRegexp start=/\%#=1%r|/  end=/|[imx]*/  display contains=@crystalInsideRegexp nextgroup=crystalBinaryOperator,crystalBracketOperator skipwhite

syn region crystalTuple matchgroup=crystalBrace start=/{/ end=/}/ display contains=TOP nextgroup=crystalBinaryOperator,crystalBracketOperator skipwhite

" NOTE: These come after crystalTuple specifically so that they won't
" get clobbered by it
syn region crystalMacroTag matchgroup=crystalMacroDelimiter start=/\%#=1\\\={%/ end=/%}/ display contains=@crystalTop,crystalFreshVariable,crystalMacroKeyword containedin=ALL
syn region crystalMacroTag matchgroup=crystalMacroDelimiter start=/\%#=1\\\={{/ end=/}}/ display contains=@crystalTop,crystalFreshVariable containedin=ALL nextgroup=crystalBinaryOperator,crystalBracketOperator skipwhite

syn region crystalHeredoc matchgroup=crystalHeredocStart start=/\%#=1<<-\z(\w\+\)/   matchgroup=crystalHeredocEnd end=/\z1/ display transparent keepend contains=@crystalTop,crystalHeredocLine    nextgroup=crystalBinaryOperator,crystalBracketOperator skipwhite
syn region crystalHeredoc matchgroup=crystalHeredocStart start=/\%#=1<<-'\z(\w\+\)'/ matchgroup=crystalHeredocEnd end=/\z1/ display transparent keepend contains=@crystalTop,crystalHeredocLineRaw nextgroup=crystalBinaryOperator,crystalBracketOperator skipwhite
syn region crystalHeredocLine    start=/\_^/ end=/\_$/ display oneline contained contains=crystalEscapeSequence,crystalStringInterpolation
syn region crystalHeredocLineRaw start=/\_^/ end=/\_$/ display oneline contained

syn keyword crystalDefine alias

syn keyword crystalAccess private protected abstract

syn keyword crystalInclude include extend require

syn keyword crystalControl return yield raise

syn keyword crystalSpecialMethod typeof pointerof sizeof instance_sizeof

syn keyword crystalOf of

syn keyword crystalForall forall

syn region crystalLinkAttribute matchgroup=crystalLinkAttributeDelimiter start=/\%#=1@\[/ end=/]/ display oneline contains=TOP

" Block keywords {{{1
syn keyword crystalConditional if unless case else elsif when then in

syn keyword crystalRepeat while until

syn keyword crystalControl begin rescue ensure end

syn match crystalBrace /{/ display contained nextgroup=crystalBlockParameterList skipwhite
syn match crystalBrace /}/ display nextgroup=crystalBinaryOperator,crystalBracketOperator skipwhite
syn keyword crystalDo do nextgroup=crystalBlockParameterList skipwhite
syn region crystalBlockParameterList start=/|/ end=/|/ display contained oneline contains=crystalBlockParameter
syn match crystalBlockParameter /\%(\l\|_\)\w*/ display contained

syn keyword crystalDefine def fun macro nextgroup=crystalMethodDefinition skipwhite
syn match crystalMethodDefinition /\%#=1\%(\<\%(self\|\u\w*\)\.\)\=\%(\l\|_\)\w*[?!=]\=/ display contained contains=crystalPseudoVariable nextgroup=crystalParentheses skipwhite
syn match crystalMethodDefinition /\%#=1+\|-\|\*\*\=\|\/\/\=\|=\%(==\=\|\~\)\|![=~]\=\|<\%(<\|=>\=\)\=\|>[>=]\=\|&\%(+\|-\|\*\*\=\)\=\||\|\^\|\~\|%\|\[][=?]\=/ display contained nextgroup=crystalParentheses skipwhite

syn keyword crystalDefine class struct module lib union enum annotation nextgroup=crystalConstantDefinition skipwhite
syn match crystalConstantDefinition /\%#=1\%(::\)\=\u\w*\%(::\u\w*\)*/ display contained nextgroup=crystalParentheses skipwhite

syn keyword crystalAttribute getter setter property class_getter class_setter class_property nextgroup=crystalAttributeModifier
syn match crystalAttributeModifier /[!?]/ display contained

" Contained groups {{{1
syn keyword crystalTodo TODO NOTE FIXME OPTIMIZE XXX TBD HACK contained
syn region crystalSharpBang start=/\%^#!/ end=/\_$/ display oneline contained

syn keyword crystalMacroKeyword if else elsif for in begin end contained

syn match crystalEscapeSequence /\\\%(\o\{1,3}\|x\x\{1,2}\|u\x\{4}\|u{\x\{1,6}}\|.\)/ display contained

syn region crystalStringInterpolation matchgroup=crystalStringInterpolationDelimiter start=/#{/ end=/}/ display oneline contained contains=TOP

syn region crystalStringNestedParentheses    start=/\%#=1(/  end=/)/  display transparent contained
syn region crystalStringNestedSquareBrackets start=/\%#=1\[/ end=/\]/ display transparent contained
syn region crystalStringNestedBraces         start=/\%#=1{/  end=/}/  display transparent contained
syn region crystalStringNestedAngleBrackets  start=/\%#=1</  end=/>/  display transparent contained

syn region crystalStringNestedRawParentheses    start=/\%#=1(/  end=/)/  display transparent contained
syn region crystalStringNestedRawSquareBrackets start=/\%#=1\[/ end=/\]/ display transparent contained
syn region crystalStringNestedRawBraces         start=/\%#=1{/  end=/}/  display transparent contained
syn region crystalStringNestedRawAngleBrackets  start=/\%#=1</  end=/>/  display transparent contained

" Cluster for special groups inside of regular expressions {{{2
" TODO: Some of these patterns are really slow
syn region crystalRegexpComment    matchgroup=crystalRegexpSpecial   start=/(?#/ skip=/\\)/ end=/)/ display contained oneline
syn region crystalRegexpParens     matchgroup=crystalRegexpSpecial   start=/(\%(?:\|?<\=[=!]\|?>\|?<[a-z_]\w*>\|?[imx]*-[imx]*:\=\|\%(?#\)\@!\)/ skip=/\\)/ end=/)/ display contained transparent contains=@crystalInsideRegexp
syn region crystalRegexpBrackets   matchgroup=crystalRegexpCharClass start=/\[\^\=/ skip=/\\\]/ end=/\]/ display contained transparent contains=crystalEscapeSequence,crystalRegexpEscape,crystalRegexpCharClass oneline
syn match  crystalRegexpCharClass  /\\[DdHhSsWw]/ contained display
syn match  crystalRegexpCharClass  /\[:\^\=\%(alnum\|alpha\|ascii\|blank\|cntrl\|digit\|graph\|lower\|print\|punct\|space\|upper\|xdigit\):\]/ display contained
syn match  crystalRegexpEscape     /\\[].*?+^$|\\\/(){}[]/ display contained
syn match  crystalRegexpQuantifier /[*?+][?+]\=/ contained display
syn match  crystalRegexpQuantifier /{\d\+\%(,\d*\)\=}?\=/ contained display
syn match  crystalRegexpAnchor     /[$^]\|\\[ABbGZz]/ contained display
syn match  crystalRegexpDot        /\./ contained display
syn match  crystalRegexpSpecial    /|/  contained display
syn match  crystalRegexpSpecial    /\\[1-9]\d\=\d\@!/ contained display
syn match  crystalRegexpSpecial    /\\w<\%([a-z_]\w*\|-\=\d\+\)\%([+-]\d\+\)\=>/ contained display
syn match  crystalRegexpSpecial    /\\w'\%([a-z_]\w*\|-\=\d\+\)\%([+-]\d\+\)\='/ contained display
syn match  crystalRegexpSpecial    /\\g<\%([a-z_]\w*\|-\=\d\+\)>/ contained display
syn match  crystalRegexpSpecial    /\\g'\%([a-z_]\w*\|-\=\d\+\)'/ contained display

" NOTE: These are *not* included in the cluster because they only appear
" in certain kinds of regex regions.
syn region crystalRegexpNestedBraces        start=/{/ end=/}/ display transparent contained
syn region crystalRegexpNestedAngleBrackets start=/</ end=/>/ display transparent contained

syn cluster crystalInsideRegexp contains=
      \ crystalRegexpSpecial,crystalRegexpDot,crystalRegexpAnchor,crystalRegexpQuantifier,
      \ crystalRegexpEscape,crystalRegexpCharClass,crystalRegexpBrackets,crystalRegexpParens,
      \ crystalRegexpComment,crystalEscapeSequence
" }}}2

" Default highlighting {{{1
hi def link crystalComment                      Comment
hi def link crystalTodo                         Todo
hi def link crystalConstant                     Constant
hi def link crystalGlobalVariable               Identifier
hi def link crystalPredefinedVariable           Identifier
hi def link crystalPredefinedConstant           Constant
hi def link crystalNumber                       Number
hi def link crystalBoolean                      Boolean
hi def link crystalPseudoVariable               Constant
hi def link crystalCharLiteral                  Character
hi def link crystalString                       String
hi def link crystalSymbol                       String
hi def link crystalRegexp                       String
hi def link crystalHeredocLine                  crystalString
hi def link crystalHeredocLineRaw               crystalHeredocLine
hi def link crystalHeredocStart                 crystalHeredocLine
hi def link crystalHeredocEnd                   crystalHeredocStart
hi def link crystalOperator                     Operator
hi def link crystalDotOperator                  crystalOperator
hi def link crystalConditional                  Conditional
hi def link crystalRepeat                       Repeat
hi def link crystalMacroKeyword                 Keyword
hi def link crystalOf                           Keyword
hi def link crystalForall                       Keyword
hi def link crystalControl                      Statement
hi def link crystalDo                           Keyword
hi def link crystalDefine                       Statement
hi def link crystalMethodDefinition             Typedef
hi def link crystalConstantDefinition           Typedef
hi def link crystalRegexpSpecial                SpecialChar
hi def link crystalRegexpDot                    crystalRegexpSpecial
hi def link crystalRegexpAnchor                 crystalRegexpSpecial
hi def link crystalRegexpQuantifier             crystalRegexpSpecial
hi def link crystalRegexpEscape                 crystalRegexpSpecial
hi def link crystalRegexpCharClass              crystalRegexpSpecial
hi def link crystalRegexpBrackets               crystalRegexpSpecial
hi def link crystalRegexpParens                 crystalRegexpSpecial
hi def link crystalRegexpComment                crystalComment
hi def link crystalEscapeSequence               SpecialChar
hi def link crystalStringInterpolationDelimiter PreProc
hi def link crystalMacroDelimiter               PreProc
hi def link crystalFreshVariable                Identifier
hi def link crystalAttribute                    Statement
hi def link crystalAttributeModifier            Statement
hi def link crystalAccess                       Keyword
hi def link crystalSpecialMethod                Function
hi def link crystalInclude                      Statement
hi def link crystalSharpBang                    PreProc
hi def link crystalInstanceVariable             Identifier
hi def link crystalClassVariable                Identifier
hi def link crystalLinkAttributeDelimiter       PreProc
hi def link crystalNamedTupleKey                crystalSymbol

" }}}

let b:current_syntax = 'crystal'

" vim:fdm=marker
