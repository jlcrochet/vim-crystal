" Vim syntax file
" Language: Crystal <crystal-lang.org>
" Author: Jeffrey Crochet <jlcrochet@pm.me>
" URL: https://github.com/jlcrochet/vim-crystal

if exists("b:current_syntax")
  finish
endif

if get(g:, "crystal_fold")
  setlocal foldmethod=syntax
endif

" Syntax {{{1
syn iskeyword @,48-57,_,?,!

if get(b:, "is_ecrystal")
  syn cluster crystalTop contains=@crystal
else
  syn cluster crystalTop contains=TOP
endif

syn cluster crystalPostfix contains=crystalOperator,crystalRangeOperator,crystalPostfixKeyword,crystalComma
syn cluster crystalArguments contains=crystalFreshVariable,crystalNumber,crystalString,crystalSymbol,crystalRegex,crystalCommand,crystalHeredoc,crystalHeredocSkip,crystalNamedTupleKey

" Comments {{{2
if get(b:, "is_ecrystal")
  syn region crystalComment matchgroup=crystalCommentDelimiter start=/\%#=1#/ end=/\%#=1\%($\|\ze-\=%>\)/ oneline contains=crystalTodo
else
  syn region crystalComment matchgroup=crystalCommentDelimiter start=/\%#=1#/ end=/\%#=1$/ oneline contains=crystalTodo
endif

syn keyword crystalTodo BUG DEPRECATED FIXME NOTE WARNING OPTIMIZE TODO XXX TBD contained

syn region crystalShebang start=/\%#=1\%^#!/ end=/\%#=1$/ oneline

syn region crystalPragma start=/\%#=1#<loc:/ end=/\%#=1>/ oneline

" Operators {{{2
syn match crystalUnaryOperator /\%#=1[+*!~&?]/
syn match crystalUnaryOperator /\%#=1->\=/

syn match crystalOperator /\%#=1=\%(==\=\|[>~]\)\=/ contained
syn match crystalOperator /\%#=1![=~]/ contained
syn match crystalOperator /\%#=1<\%(<=\=\|=>\=\)\=/ contained
syn match crystalOperator /\%#=1>>\==\=/ contained
syn match crystalOperator /\%#=1+=\=/ contained
syn match crystalOperator /\%#=1-[=>]\=/ contained
syn match crystalOperator /\%#=1\*\*\==\=/ contained
syn match crystalOperator /\%#=1[/:]/ contained
" NOTE: Additional division operators are defined after /-style regexes
" in order to take precedence
syn match crystalOperator /\%#=1?/ contained nextgroup=crystalAssignmentOperator skipwhite
syn match crystalAssignmentOperator /\%#=1=/ contained
syn match crystalOperator /\%#=1%=\=/ contained
syn match crystalOperator /\%#=1&\%(&=\=\|=\|+=\=\|-[=>]\=\|\*[*=]\=\|\)\=/ contained
syn match crystalOperator /\%#=1||\==\=/ contained
syn match crystalOperator /\%#=1\^=\=/ contained

syn match crystalOperator /\%#=1\./ nextgroup=crystalVariableOrMethod,crystalOperatorMethod skipwhite
execute 'syn match crystalOperatorMethod /\%#=1'.g:crystal#syntax#overloadable_operators.'/ contained nextgroup=@crystalPostfix,@crystalArguments skipwhite'

syn match crystalRangeOperator /\%#=1\.\.\.\=/ nextgroup=crystalOperator,crystalPostfixKeyword skipwhite

syn match crystalNamespaceOperator /\%#=1::/ nextgroup=crystalConstant,crystalVariableOrMethod

" Delimiters {{{2
syn match crystalDelimiter /\%#=1(/ nextgroup=crystalNamedTupleKey skipwhite skipnl
syn match crystalDelimiter /\%#=1)/ nextgroup=@crystalPostfix skipwhite

syn match crystalDelimiter /\%#=1\[/
syn match crystalDelimiter /\%#=1]?\=/ nextgroup=@crystalPostfix skipwhite

syn match crystalDelimiter /\%#=1{/ nextgroup=crystalNamedTupleKey,crystalBlockParameters skipwhite skipnl
syn match crystalDelimiter /\%#=1}/ nextgroup=@crystalPostfix skipwhite

syn match crystalComma /\%#=1,/ contained nextgroup=crystalNamedTupleKey skipwhite skipnl

syn match crystalBackslash /\%#=1\\/

" Identifiers {{{2
syn match crystalInstanceVariable /\%#=1@\h\w*/ nextgroup=@crystalPostfix skipwhite
syn match crystalClassVariable /\%#=1@@\h\w*/ nextgroup=@crystalPostfix skipwhite
syn match crystalFreshVariable /\%#=1%\h\w*/ nextgroup=@crystalPostfix skipwhite
syn match crystalExternalVariable /\%#=1\$\%([~?]\|\d\+?\=\|[[:lower:]_]\w*\)/ nextgroup=@crystalPostfix skipwhite

syn match crystalConstant /\%#=1\u\w*/ nextgroup=@crystalPostfix,crystalNamespaceOperator skipwhite
syn match crystalVariableOrMethod /\%#=1[[:lower:]_]\w*[=?!]\=/ nextgroup=@crystalPostfix,@crystalArguments skipwhite

" Literals {{{2
syn keyword crystalNil nil nextgroup=@crystalPostfix skipwhite
syn keyword crystalBoolean true false nextgroup=@crystalPostfix skipwhite
syn keyword crystalSelf self nextgroup=@crystalPostfix skipwhite

" Numbers {{{3
execute g:crystal#syntax#numbers

" Characters {{{3
syn match crystalCharacterStart /\%#=1'/ nextgroup=crystalCharacter,crystalCharacterEscape,crystalCharacterEscapeError
syn match crystalCharacterEnd /\%#=1'/ contained nextgroup=@crystalPostfix skipwhite

syn match crystalCharacter /\%#=1./ contained nextgroup=crystalCharacterEnd,crystalCharacterExtraError
syn match crystalCharacterExtraError /\%#=1[^']\+/ contained nextgroup=crystalCharacterEnd
syn match crystalCharacterEscapeError /\%#=1\\./ contained nextgroup=crystalCharacterEnd,crystalCharacterExtraError
syn match crystalCharacterEscape /\%#=1\\\%(u\%(\x\{4}\|{\x\{1,6}}\)\|['\\abefnrtv0]\)/ contained nextgroup=crystalCharacterEnd,crystalCharacterExtraError

syn match crystalCharacterError /\%#=1''/ nextgroup=@crystalPostfix skipwhite

" Strings {{{3
syn region crystalString matchgroup=crystalStringDelimiter start=/\%#=1"/ end=/\%#=1"/ contains=crystalStringInterpolation,crystalStringEscape,crystalStringEscapeError nextgroup=@crystalPostfix skipwhite

syn region crystalString matchgroup=crystalStringDelimiter start=/\%#=1%Q\=(/ end=/\%#=1)/ contains=crystalStringParentheses,crystalStringInterpolation,crystalStringEscape,crystalStringEscapeError nextgroup=@crystalPostfix skipwhite
syn region crystalStringParentheses matchgroup=crystalString start=/\%#=1(/ end=/\%#=1)/ transparent contained

syn region crystalString matchgroup=crystalStringDelimiter start=/\%#=1%Q\=\[/ end=/\%#=1]/ contains=crystalStringSquareBrackets,crystalStringInterpolation,crystalStringEscape,crystalStringEscapeError nextgroup=@crystalPostfix skipwhite
syn region crystalStringSquareBrackets matchgroup=crystalString start=/\%#=1\[/ end=/\%#=1]/ transparent contained

syn region crystalString matchgroup=crystalStringDelimiter start=/\%#=1%Q\={/ end=/\%#=1}/ contains=crystalStringCurlyBraces,crystalStringInterpolation,crystalStringEscape,crystalStringEscapeError nextgroup=@crystalPostfix skipwhite
syn region crystalStringCurlyBraces matchgroup=crystalString start=/\%#=1{/ end=/\%#=1}/ transparent contained

syn region crystalString matchgroup=crystalStringDelimiter start=/\%#=1%Q\=</ end=/\%#=1>/ contains=crystalStringAngleBrackets,crystalStringInterpolation,crystalStringEscape,crystalStringEscapeError nextgroup=@crystalPostfix skipwhite
syn region crystalStringAngleBrackets matchgroup=crystalString start=/\%#=1</ end=/\%#=1>/ transparent contained

syn region crystalString matchgroup=crystalStringDelimiter start=/\%#=1%Q\=|/ end=/\%#=1|/ contains=crystalStringInterpolation,crystalStringEscape,crystalStringEscapeError nextgroup=@crystalPostfix skipwhite

syn region crystalStringInterpolation matchgroup=crystalStringInterpolationDelimiter start=/\%#=1#{/ end=/\%#=1}/ contained contains=@crystalTop,crystalNestedBraces

syn match crystalStringEscape /\%#=1\\\_./ contained
syn match crystalStringEscapeError /\%#=1\\\%(x\x\=\|u\x\{,3}\)/ contained
syn match crystalStringEscape /\%#=1\\\%(\o\{1,3}\|x\x\x\|u\%(\x\{4}\|{\x\{1,6}\%(\s\x\{1,6}\)*}\)\)/ contained
syn match crystalStringEscapeError /\%#=1\\\%(\o\{4,}\)/ contained

syn region crystalString matchgroup=crystalStringDelimiter start=/\%#=1%q(/  end=/\%#=1)/ contains=crystalStringParentheses  nextgroup=@crystalPostfix skipwhite
syn region crystalString matchgroup=crystalStringDelimiter start=/\%#=1%q\[/ end=/\%#=1]/ contains=crystalStringSquareBrackets nextgroup=@crystalPostfix skipwhite
syn region crystalString matchgroup=crystalStringDelimiter start=/\%#=1%q{/  end=/\%#=1}/ contains=crystalStringCurlyBraces  nextgroup=@crystalPostfix skipwhite
syn region crystalString matchgroup=crystalStringDelimiter start=/\%#=1%q</  end=/\%#=1>/ contains=crystalStringAngleBrackets  nextgroup=@crystalPostfix skipwhite
syn region crystalString matchgroup=crystalStringDelimiter start=/\%#=1%q|/  end=/\%#=1|/ nextgroup=@crystalPostfix skipwhite

syn region crystalString matchgroup=crystalStringDelimiter start=/\%#=1%w(/ end=/\%#=1)/ contains=crystalStringParentheses,crystalStringParenthesisEscape nextgroup=@crystalPostfix skipwhite
syn match crystalStringParenthesisEscape /\%#=1\\[()[:space:]]/ contained

syn region crystalString matchgroup=crystalStringDelimiter start=/\%#=1%w\[/ end=/\%#=1]/ contains=crystalStringSquareBrackets,crystalStringSquareBracketEscape nextgroup=@crystalPostfix skipwhite
syn match crystalStringSquareBracketEscape /\%#=1\\[\[\][:space:]]/ contained

syn region crystalString matchgroup=crystalStringDelimiter start=/\%#=1%w{/ end=/\%#=1}/ contains=crystalStringCurlyBraces,crystalStringCurlyBraceEscape nextgroup=@crystalPostfix skipwhite
syn match crystalStringCurlyBraceEscape /\%#=1\\[{}[:space:]]/ contained

syn region crystalString matchgroup=crystalStringDelimiter start=/\%#=1%w</ end=/\%#=1>/ contains=crystalStringAngleBrackets,crystalStringAngleBracketEscape nextgroup=@crystalPostfix skipwhite
syn match crystalStringAngleBracketEscape /\%#=1\\[<>[:space:]]/ contained

syn region crystalString matchgroup=crystalStringDelimiter start=/\%#=1%w|/ end=/\%#=1|/ contains=crystalStringPipeEscape nextgroup=@crystalPostfix skipwhite
syn match crystalStringPipeEscape /\%#=1\\[|[:space:]]/ contained

" Here Documents {{{3
syn region crystalHeredoc matchgroup=crystalHeredocStart start=/\%#=1<<-\z(\w\+\)/ matchgroup=crystalHeredocEnd end=/\%#=1^\s*\z1$/ transparent contains=crystalHeredocStartLine,crystalHeredocLine
syn region crystalHeredocStartLine start=/\%#=1/ end=/\%#=1$/ contained oneline transparent keepend contains=TOP nextgroup=crystalHeredocLine skipnl
syn region crystalHeredocLine start=/\%#=1^/ end=/\%#=1$/ contained oneline contains=crystalStringInterpolation,crystalStringEscape,crystalStringEscapeError nextgroup=crystalHeredocLine skipnl

syn region crystalHeredoc matchgroup=crystalHeredocStart start=/\%#=1<<-'\z(\w\+\)'/ matchgroup=crystalHeredocEnd end=/\%#=1^\s*\z1$/ transparent contains=crystalHeredocStartLineRaw,crystalHeredocLineRaw
syn region crystalHeredocStartLineRaw start=/\%#=1/ end=/\%#=1$/ contained oneline transparent keepend contains=TOP nextgroup=crystalHeredocLineRaw skipnl
syn region crystalHeredocLineRaw start=/\%#=1^/ end=/\%#=1$/ oneline contained nextgroup=crystalHeredocLineRaw skipnl

syn region crystalHeredocSkip matchgroup=crystalHeredocStart start=/\%#=1<<-\('\=\)\w\+\1/ end=/\%#=1\ze<<-'\=\w/ transparent oneline nextgroup=crystalHeredoc,crystalHeredocSkip

" Symbols {{{3
syn match crystalSymbol /\%#=1:\h\w*[=?!]\=/ contains=crystalSymbolDelimiter nextgroup=@crystalPostfix skipwhite
execute 'syn match crystalSymbol /\%#=1:'.g:crystal#syntax#overloadable_operators.'/ contains=crystalSymbolDelimiter nextgroup=@crystalPostfix skipwhite'

syn match crystalSymbolDelimiter /\%#=1:/ contained

syn region crystalSymbol matchgroup=crystalSymbolDelimiter start=/\%#=1:"/ end=/\%#=1"/ contains=crystalStringInterpolation,crystalStringEscape,crystalStringEscapeError nextgroup=@crystalPostfix skipwhite

syn region crystalSymbol matchgroup=crystalSymbolDelimiter start=/\%#=1%i(/  end=/\%#=1)/ contains=crystalStringParentheses,crystalStringParenthesisEscape nextgroup=@crystalPostfix skipwhite
syn region crystalSymbol matchgroup=crystalSymbolDelimiter start=/\%#=1%i\[/ end=/\%#=1]/ contains=crystalStringSquareBrackets,crystalStringSquareBracketEscape nextgroup=@crystalPostfix skipwhite
syn region crystalSymbol matchgroup=crystalSymbolDelimiter start=/\%#=1%i{/  end=/\%#=1}/ contains=crystalStringCurlyBraces,crystalStringCurlyBraceEscape nextgroup=@crystalPostfix skipwhite
syn region crystalSymbol matchgroup=crystalSymbolDelimiter start=/\%#=1%i</  end=/\%#=1>/ contains=crystalStringAngleBrackets,crystalStringAngleBracketEscape nextgroup=@crystalPostfix skipwhite
syn region crystalSymbol matchgroup=crystalSymbolDelimiter start=/\%#=1%i|/  end=/\%#=1|/ contains=crystalStringPipeEscape nextgroup=@crystalPostfix skipwhite

syn match crystalNamedTupleKey /\%#=1[[:lower:]_]\w*[?!]\=:/he=e-1 contained contains=crystalSymbolDelimiter
syn match crystalNamedTupleKey /\%#=1\u\w*::\@!/he=e-1 contained contains=crystalSymbolDelimiter

" Regular Expressions {{{3
syn region crystalRegex matchgroup=crystalRegexDelimiter start=/\%#=1\// end=/\%#=1\/[imx]*/ skip=/\%#=1\\\\\|\\\// oneline keepend contains=crystalStringInterpolation,crystalStringEscape,crystalStringEscapeError,@crystalPCRE nextgroup=@crystalPostfix skipwhite

" NOTE: These operators are defined here in order to take precedence
" over /-style regexes
syn match crystalOperator /\%#=1\/\ze\s/ contained
syn match crystalOperator /\%#=1\/[/=]/ contained

syn region crystalRegex matchgroup=crystalRegexDelimiter start=/\%#=1%r(/  end=/\%#=1)[imx]*/ contains=crystalStringInterpolation,crystalStringEscape,crystalStringEscapeError,@crystalPCRE nextgroup=@crystalPostfix skipwhite
syn region crystalRegex matchgroup=crystalRegexDelimiter start=/\%#=1%r\[/ end=/\%#=1][imx]*/ contains=crystalStringInterpolation,crystalStringEscape,crystalStringEscapeError,@crystalPCRE nextgroup=@crystalPostfix skipwhite
syn region crystalRegex matchgroup=crystalRegexDelimiter start=/\%#=1%r{/  end=/\%#=1}[imx]*/ skip=/\%#=1{.\{-}}/ contains=crystalStringInterpolation,crystalStringEscape,crystalStringEscapeError,@crystalPCRE nextgroup=@crystalPostfix skipwhite
syn region crystalRegex matchgroup=crystalRegexDelimiter start=/\%#=1%r</  end=/\%#=1>[imx]*/ skip=/\%#=1<.\{-}>/ contains=crystalStringInterpolation,crystalStringEscape,crystalStringEscapeError,@crystalPCRE nextgroup=@crystalPostfix skipwhite
syn region crystalRegex matchgroup=crystalRegexDelimiter start=/\%#=1%r|/  end=/\%#=1|[imx]*/ contains=crystalStringInterpolation,crystalStringEscape,crystalStringEscapeError,@crystalPCRE nextgroup=@crystalPostfix skipwhite

" PCRE {{{4
syn cluster crystalPCRE contains=
      \ crystalRegexMetacharacter,crystalRegexClass,crystalRegexGroup,crystalRegexComment,
      \ crystalRegexEscape,crystalRegexCapturedGroup,crystalRegexQuantifier

syn match crystalRegexMetacharacter /\%#=1[.^$|]/ contained
syn match crystalRegexQuantifier /\%#=1[*+?]/ contained
syn match crystalRegexQuantifier /\%#=1{\d*,\=\d*}/ contained
syn region crystalRegexClass matchgroup=crystalRegexMetacharacter start=/\%#=1\[\^\=/ end=/\%#=1]/ oneline transparent contained contains=crystalRegexEscape,crystalRegexPOSIXClass
syn match crystalRegexPOSIXClass /\%#=1\[\^\=:\%(alnum\|alpha\|ascii\|blank\|cntrl\|digit\|graph\|lower\|print\|punct\|space\|upper\|word\|xdigit\):]/ contained
syn region crystalRegexGroup matchgroup=crystalRegexMetacharacter start=/\%#=1(\%(?\%([:>|=!]\|<\%([=!]\|\h\w*>\)\|[imx]\+\)\)\=/ end=/\%#=1)/ transparent contained
syn region crystalRegexComment start=/\%#=1(#/ end=/\%#=1)/ contained
syn region crystalRegexEscape matchgroup=crystalRegexMetacharacter start=/\%#=1\\Q/ end=/\%#=1\\E/ transparent contained contains=crystalRegexSlashEscape
syn match crystalRegexSlashEscape /\%#=1\\\// contained
syn match crystalRegexEscape /\%#=1\\[pP]{\h\w*}/ contained
syn match crystalRegexCapturedGroup /\%#=1\\\%(\d\+\|g\%({\w\+}\|<\w\+>\)\)/ contained

" Commands {{{3
syn region crystalCommand matchgroup=crystalCommandDelimiter start=/\%#=1`/ end=/\%#=1`/ contains=crystalStringInterpolation,crystalStringEscape,crystalStringEscapeError nextgroup=@crystalPostfix skipwhite

syn region crystalCommand matchgroup=crystalCommandDelimiter start=/\%#=1%x(/  end=/\%#=1)/ contains=crystalStringParentheses,crystalStringInterpolation,crystalStringEscape,crystalStringEscapeError nextgroup=@crystalPostfix skipwhite
syn region crystalCommand matchgroup=crystalCommandDelimiter start=/\%#=1%x\[/ end=/\%#=1]/ contains=crystalStringSquareBrackets,crystalStringInterpolation,crystalStringEscape,crystalStringEscapeError nextgroup=@crystalPostfix skipwhite
syn region crystalCommand matchgroup=crystalCommandDelimiter start=/\%#=1%x{/  end=/\%#=1}/ contains=crystalStringCurlyBraces,crystalStringInterpolation,crystalStringEscape,crystalStringEscapeError nextgroup=@crystalPostfix skipwhite
syn region crystalCommand matchgroup=crystalCommandDelimiter start=/\%#=1%x</  end=/\%#=1>/ contains=crystalStringAngleBrackets,crystalStringInterpolation,crystalStringEscape,crystalStringEscapeError nextgroup=@crystalPostfix skipwhite
syn region crystalCommand matchgroup=crystalCommandDelimiter start=/\%#=1%x|/  end=/\%#=1|/ contains=crystalStringInterpolation,crystalStringEscape,crystalStringEscapeError nextgroup=@crystalPostfix skipwhite

" Blocks {{{2
if get(g:, "crystal_simple_indent") || get(b:, "is_ecrystal")
  syn keyword crystalKeyword if unless case while until begin for else ensure
  syn keyword crystalKeyword rescue nextgroup=crystalConstant skipwhite
  syn keyword crystalKeyword end nextgroup=@crystalPostfix skipwhite
  syn keyword crystalKeyword do nextgroup=crystalBlockParameters skipwhite

  syn keyword crystalKeyword def macro nextgroup=crystalMethodDefinition,crystalMethodReceiver,crystalMethodSelf skipwhite
  syn keyword crystalKeyword class struct lib annotation enum module union nextgroup=crystalTypeDefinition skipwhite

  syn keyword crystalKeyword abstract nextgroup=crystalKeywordNoBlock skipwhite
  syn keyword crystalKeyword private protected nextgroup=crystalConstant skipwhite

  syn keyword crystalKeyword type alias nextgroup=crystalTypeAlias skipwhite

  syn keyword crystalKeywordNoBlock def contained nextgroup=crystalMethodDefinition,crystalMethodReceiver,crystalMethodSelf skipwhite
  syn keyword crystalKeywordNoBlock fun nextgroup=crystalLibMethodDefinition skipwhite
else
  " NOTE: When definition blocks are highlighted, the following keywords
  " have to be matched with :syn-match instead of :syn-keyword to
  " prevent the block regions from being clobbered.

  syn region crystalBlock matchgroup=crystalKeyword start=/\%#=1\<\%(if\|unless\|case\|while\|until\|begin\)\>/ end=/\%#=1\<\.\@1<!end:\@!\>/ contains=@crystalTop,crystalBlockControl nextgroup=@crystalPostfix skipwhite
  syn keyword crystalBlockControl else ensure contained
  syn keyword crystalBlockControl rescue contained nextgroup=crystalConstant skipwhite

  syn match crystalKeyword /\%#=1\<do\>/ nextgroup=crystalBlockParameters skipwhite contained containedin=crystalBlock
  syn region crystalBlock start=/\%#=1\<do\>/ matchgroup=crystalKeyword end=/\%#=1\<\.\@1<!end:\@!\>/ contains=@crystalTop,crystalBlockControl nextgroup=@crystalPostfix skipwhite

  syn match crystalDefine /\%#=1\<\%(def\|macro\)\>/ nextgroup=crystalMethodDefinition,crystalMethodReceiver,crystalMethodSelf skipwhite contained containedin=crystalDefineBlock
  syn match crystalDefine /\%#=1\<\%(class\|struct\|lib\|annotation\|enum\|module\|union\)\>/ nextgroup=crystalTypeDefinition skipwhite contained containedin=crystalDefineBlock

  syn region crystalDefineBlock start=/\%#=1\<\%(def\|macro\|class\|struct\|lib\|annotation\|enum\|module\|union\)\>/ matchgroup=crystalDefine end=/\%#=1\<\.\@1<!end:\@!\>/ contains=@crystalTop,crystalDefineBlockControl fold
  syn keyword crystalDefineBlockControl else ensure contained
  syn keyword crystalDefineBlockControl rescue contained nextgroup=crystalConstant skipwhite

  syn keyword crystalDefine abstract nextgroup=crystalDefineNoBlock skipwhite
  syn keyword crystalDefine private protected nextgroup=crystalDefineBlock,crystalConstant skipwhite

  syn keyword crystalDefine type alias nextgroup=crystalTypeAlias skipwhite

  syn keyword crystalDefineNoBlock def contained nextgroup=crystalMethodDefinition,crystalMethodReceiver,crystalMethodSelf skipwhite
  syn keyword crystalDefineNoBlock fun nextgroup=crystalMethodDefinition,crystalMethodReceiver,crystalMethodSelf skipwhite

  syn keyword crystalKeyword if unless else begin for do end contained containedin=crystalMacro
endif

syn match crystalTypeDefinition /\%#=1\u\w*/ contained nextgroup=crystalTypeNamespace,crystalInheritanceOperator skipwhite
syn match crystalTypeNamespace /\%#=1::/ contained nextgroup=crystalTypeDefinition
syn match crystalInheritanceOperator /\%#=1</ contained nextgroup=crystalConstant skipwhite

syn match crystalMethodDefinition /\%#=1[[:lower:]_]\w*[=?!]\=/ contained nextgroup=crystalMethodParameters,crystalMethodTypeOperator skipwhite
execute 'syn match crystalMethodDefinition /\%#=1'.g:crystal#syntax#overloadable_operators.'/ contained nextgroup=crystalMethodParameters,crystalMethodTypeOperator skipwhite'
syn region crystalMethodParameters matchgroup=crystalDelimiter start=/\%#=1(/ end=/\%#=1)/ contained contains=TOP,crystalKeyword,crystalDefine,crystalBlock,crystalDefineBlock nextgroup=crystalMethodTypeOperator skipwhite
syn keyword crystalKeyword out
syn match crystalMethodTypeOperator /\%#=1:/ contained
syn match crystalMethodReceiver /\%#=1\u\w*/ contained nextgroup=crystalMethodDot
syn keyword crystalMethodSelf self contained nextgroup=crystalMethodDot
syn match crystalMethodDot /\%#=1\./ contained nextgroup=crystalMethodDefinition

syn match crystalLibMethodDefinition /\%#=1[[:lower:]_]\w*[?!]\=/ contained nextgroup=crystalMethodParameters,crystalMethodTypeOperator,crystalMethodAssignmentOperator skipwhite
syn match crystalLibMethodDefinition /\%#=1\u\w*/ contained nextgroup=crystalMethodParameters,crystalMethodTypeOperator,crystalMethodAssignmentOperator skipwhite
syn match crystalMethodAssignmentOperator /\%#=1=/ contained nextgroup=crystalCFunctionName,crystalCFunctionStringName skipwhite
syn match crystalCFunctionName /\%#=1\h\w*/ contained nextgroup=crystalMethodParameters skipwhite
syn region crystalCFunctionStringName matchgroup=crystalStringDelimiter start=/\%#=1"/ end=/\%#=1"/ contained oneline nextgroup=crystalMethodParameters skipwhite

" Miscellaneous {{{2
syn keyword crystalKeyword elsif when in then uninitialized forall of with

syn match crystalTypeAlias /\%#=1\u\w*/ contained nextgroup=crystalAssignmentOperator skipwhite

syn keyword crystalKeyword include extend nextgroup=crystalConstant skipwhite
syn keyword crystalKeyword return next break nextgroup=crystalPostfixKeyword skipwhite
syn keyword crystalKeyword require nextgroup=crystalString skipwhite

syn keyword crystalPostfixKeyword if unless contained

syn region crystalBlockParameters matchgroup=crystalDelimiter start=/\%#=1|/ end=/\%#=1|/ contained
syn match crystalBlockParameter /\%#=1[[:lower:]_]\w*/ contained containedin=crystalBlockParameters
syn region crystalBlockParameters matchgroup=crystalDelimiter start=/\%#=1(/ end=/\%#=1)/ contained containedin=crystalBlockParameters

syn region crystalNestedBraces start=/\%#=1{/ matchgroup=crystalDelimiter end=/\%#=1}/ contained transparent nextgroup=@crystalPostfix skipwhite

syn region crystalAnnotation matchgroup=crystalAnnotationDelimiter start=/\%#=1@\[/ end=/\%#=1]/ oneline contains=@crystalTop,crystalNestedBrackets

syn region crystalNestedBrackets matchgroup=crystalDelimiter start=/\%#=1\[/ end=/\%#=1]?\=/ contained oneline transparent nextgroup=@crystalPostfix

" Macros {{{2
syn region crystalMacro matchgroup=crystalMacroDelimiter start=/\%#=1\\\={{/ end=/\%#=1}}/ oneline containedin=ALLBUT,crystalComment,crystalString contains=@crystalTop,crystalNestedBraces nextgroup=@crystalPostfix,crystalNamespaceOperator skipwhite
syn region crystalMacro matchgroup=crystalMacroDelimiter start=/\%#=1\\\={{/ end=/\%#=1}}/ oneline contained containedin=crystalString contains=@crystalTop,crystalNestedBraces
syn region crystalMacro matchgroup=crystalMacroDelimiter start=/\%#=1\\\={%/ end=/\%#=1%}/ oneline containedin=ALLBUT,crystalComment,crystalString contains=TOP
" }}}2

" Synchronization {{{1
syn sync fromstart

" Highlighting {{{1
hi def link crystalComment Comment
hi def link crystalCommentDelimiter crystalComment
hi def link crystalTodo Todo
hi def link crystalShebang PreProc
hi def link crystalPragma PreProc
hi def link crystalOperator Operator
hi def link crystalUnaryOperator crystalOperator
hi def link crystalRangeOperator crystalOperator
hi def link crystalNamespaceOperator crystalOperator
hi def link crystalDelimiter Delimiter
hi def link crystalInstanceVariable Identifier
hi def link crystalClassVariable Identifier
hi def link crystalExternalVariable Identifier
hi def link crystalConstant Identifier
hi def link crystalNil Constant
hi def link crystalBoolean Boolean
hi def link crystalSelf Constant
hi def link crystalNumber Number
hi def link crystalCharacter Character
hi def link crystalCharacterStart crystalCharacter
hi def link crystalCharacterEnd crystalCharacterStart
hi def link crystalCharacterError Error
hi def link crystalCharacterExtraError crystalCharacterError
hi def link crystalCharacterEscape SpecialChar
hi def link crystalCharacterEscapeError crystalCharacterError
hi def link crystalString String
hi def link crystalStringDelimiter crystalString
hi def link crystalStringEscape SpecialChar
hi def link crystalStringEscapeError Error
hi def link crystalStringInterpolationDelimiter PreProc
hi def link crystalStringParenthesisEscape crystalStringEscape
hi def link crystalStringSquareBracketEscape crystalStringEscape
hi def link crystalStringCurlyBraceEscape crystalStringEscape
hi def link crystalStringAngleBracketEscape crystalStringEscape
hi def link crystalStringPipeEscape crystalStringEscape
hi def link crystalHeredocLine String
hi def link crystalHeredocLineRaw crystalHeredocLine
hi def link crystalHeredocStart crystalStringDelimiter
hi def link crystalHeredocEnd crystalHeredocStart
hi def link crystalSymbol String
hi def link crystalSymbolDelimiter crystalSymbol
hi def link crystalNamedTupleKey crystalSymbol
hi def link crystalRegex String
hi def link crystalRegexDelimiter crystalRegex
hi def link crystalRegexMetacharacter SpecialChar
hi def link crystalRegexPOSIXClass crystalRegexMetacharacter
hi def link crystalRegexComment Comment
hi def link crystalRegexEscape SpecialChar
hi def link crystalRegexSlashEscape crystalRegexEscape
hi def link crystalRegexCapturedGroup crystalRegexMetacharacter
hi def link crystalRegexQuantifier crystalRegexMetacharacter
hi def link crystalCommand String
hi def link crystalCommandDelimiter crystalCommand
hi def link crystalKeyword Keyword
hi def link crystalKeywordNoBlock crystalKeyword
hi def link crystalPostfixKeyword crystalKeyword
hi def link crystalDefine Define
hi def link crystalDefineNoBlock crystalDefine
hi def link crystalBlockControl crystalKeyword
hi def link crystalDefineBlockControl crystalDefine
hi def link crystalMethodDefinition Typedef
hi def link crystalLibMethodDefinition crystalMethodDefinition
hi def link crystalMethodReceiver crystalConstant
hi def link crystalMethodSelf crystalSelf
hi def link crystalMethodDot crystalOperator
hi def link crystalTypeDefinition Typedef
hi def link crystalTypeAlias crystalTypeDefinition
hi def link crystalTypeNamespace crystalNamespaceOperator
hi def link crystalInheritanceOperator crystalOperator
hi def link crystalMacroDelimiter PreProc
hi def link crystalFreshVariable Identifier
hi def link crystalAnnotationDelimiter PreProc
hi def link crystalBlockParameter crystalVariableOrMethod
hi def link crystalAssignmentOperator crystalOperator
hi def link crystalMethodTypeOperator crystalOperator
hi def link crystalMethodAssignmentOperator crystalAssignmentOperator
hi def link crystalCFunctionStringName crystalString
" }}}1

" vim:fdm=marker
