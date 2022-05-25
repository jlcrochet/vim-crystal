" Vim syntax file
" Language: Crystal <crystal-lang.org>
" Author: Jeffrey Crochet <jlcrochet@hey.com>
" URL: https://github.com/jlcrochet/vim-crystal

if exists("b:current_syntax")
  finish
endif

let b:current_syntax = "crystal"

" Syntax {{{1
syn sync fromstart
syn iskeyword @,48-57,_,?,!,:

if get(b:, "is_ecrystal")
  syn cluster crystalTop contains=@crystal
else
  syn cluster crystalTop contains=TOP
endif

syn cluster crystalPostfix contains=crystalOperator,crystalMethodOperator,crystalTernaryOperator,crystalTypeRestrictionOperator,crystalRangeOperator,crystalNamespaceOperator,crystalPostfixKeyword,crystalComma
syn cluster crystalArguments contains=crystalFreshVariable,crystalNumber,crystalString,crystalStringArray,crystalCharacter,crystalCharacterError,crystalSymbol,crystalSymbolArray,crystalRegex,crystalCommand,crystalHeredoc,crystalHeredocSkip,crystalNamedTupleKey

" Comments {{{2
if get(b:, "is_ecrystal")
  syn match crystalComment /\%#=1#.\{-}\ze\%(-\=%>\)\=/
else
  let crystal_markdown_comments = get(g:, "crystal_markdown_comments", 1)

  if crystal_markdown_comments
    syn match crystalCommentStart /\%#=1#/ nextgroup=crystalInlineComment
    syn match crystalInlineComment /\%#=1.*/ contained

    syn match crystalCommentStart /\%#=1^\s*\zs#/ nextgroup=crystalCommentSpace

    syn match crystalCommentSpace /\%#=1\s*/ contained nextgroup=crystalComment,crystalSpecialComment,@crystalMarkdownLine
    syn match crystalCommentSpace /\%#=1 \{4}/ contained nextgroup=crystalMarkdownCodeLine
    syn match crystalCommentSpace /\%#=1\t/ contained nextgroup=crystalMarkdownCodeLine

    syn match crystalComment /\%#=1.*/ contained contains=crystalTodo,@crystalMarkdownInline

    syn keyword crystalSpecialComment :nodoc: :inherit: :ditto: contained

    hi def link crystalCommentStart crystalComment
    hi def link crystalInlineComment crystalComment
    hi def link crystalCommentSpace crystalComment
    hi def link crystalSpecialComment SpecialComment

    " Markdown {{{3
    " Inline syntax
    syn cluster crystalMarkdownInline contains=
          \ crystalMarkdownBold,crystalMarkdownItalic,crystalMarkdownBoldItalic,crystalMarkdownCode,crystalMarkdownEscape,
          \ crystalMarkdownLink,crystalMarkdownImage,crystalMarkdownRawLink

    syn region crystalMarkdownItalic matchgroup=crystalMarkdownItalicDelimiter start=/\%#=1\*/ end=/\%#=1\*/ contained contains=crystalMarkdownCode,crystalMarkdownEscape,crystalMarkdownRawLink oneline
    syn region crystalMarkdownBold matchgroup=crystalMarkdownBoldDelimiter start=/\%#=1\*\*/ end=/\%#=1\*\*/ contained contains=crystalMarkdownCode,crystalMarkdownEscape,crystalMarkdownRawLink oneline
    syn region crystalMarkdownBoldItalic matchgroup=crystalMarkdownBoldItalicDelimiter start=/\%#=1\*\*\*/ end=/\%#=1\*\*\*/ contained contains=crystalMarkdownCode,crystalMarkdownEscape,crystalMarkdownRawLink oneline

    syn region crystalMarkdownItalic matchgroup=crystalMarkdownItalicDelimiter start=/\%#=1\<_/ end=/\%#=1_\>/ contained contains=crystalMarkdownCode,crystalMarkdownEscape,crystalMarkdownRawLink oneline
    syn region crystalMarkdownBold matchgroup=crystalMarkdownBoldDelimiter start=/\%#=1\<__/ end=/\%#=1__\>/ contained contains=crystalMarkdownCode,crystalMarkdownEscape,crystalMarkdownRawLink oneline
    syn region crystalMarkdownBoldItalic matchgroup=crystalMarkdownBoldItalicDelimiter start=/\%#=1\<___/ end=/\%#=1___\>/ contained contains=crystalMarkdownCode,crystalMarkdownEscape,crystalMarkdownRawLink oneline

    syn region crystalMarkdownCode matchgroup=crystalMarkdownCodeDelimiter start=/\%#=1`/ end=/\%#=1`/ skip=/\%#=1\s`\{2,}\s/ contained oneline
    syn region crystalMarkdownCode matchgroup=crystalMarkdownCodeDelimiter start=/\%#=1``/ end=/\%#=1``/ skip=/\%#=1\s`\{3,}\s/ contained oneline
    syn region crystalMarkdownCode matchgroup=crystalMarkdownCodeDelimiter start=/\%#=1```/ end=/\%#=1```/ skip=/\%#=1\s`\{4,}\s/ contained oneline

    syn match crystalMarkdownEscape /\%#=1\\[\\`*_#+\-.!()[\]{}]/ contained

    syn region crystalMarkdownLink matchgroup=crystalMarkdownDelimiter start=/\%#=1\[/ end=/\%#=1]/ contained oneline contains=@crystalMarkdownInline nextgroup=crystalMarkdownURL,crystalMarkdownReference
    syn region crystalMarkdownURL matchgroup=crystalMarkdownDelimiter start=/\%#=1(/ end=/\%#=1)/ contained oneline
    syn region crystalMarkdownReference matchgroup=crystalMarkdownDelimiter start=/\%#=1\[/ end=/\%#=1]/ contained oneline

    syn match crystalMarkdownImage /\%#=1!/ contained nextgroup=crystalMarkdownLink

    syn region crystalMarkdownRawLink matchgroup=crystalMarkdownDelimiter start=/\%#=1<\ze\S.\{-}\%(:\/\/\|@\)/ end=/\%#=1>/ contained oneline

    " Line-based syntax
    syn cluster crystalMarkdownLine contains=
          \ crystalMarkdownCodeBlock,crystalMarkdownHeading,crystalMarkdownOrderedListItem,crystalMarkdownUnorderedListItem,
          \ crystalMarkdownHorizontalRule,crystalMarkdownBlockQuote

    syn region crystalMarkdownCodeBlock matchgroup=crystalMarkdownCodeDelimiter start=/\%#=1```.*/ end=/\%#=1^\s*#\s*\zs```$/ contained contains=crystalMarkdownCodeLineStart keepend
    syn region crystalMarkdownCodeBlock matchgroup=crystalMarkdownCodeDelimiter start=/\%#=1\~\~\~.*/ end=/\%#=1^\s*#\s*\zs\~\~\~$/ contained contains=crystalMarkdownCodeLineStart keepend

    syn match crystalMarkdownCodeLineStart /\%#=1^\s*\zs#/ contained

    syn match crystalMarkdownCodeLine /\%#=1.*/ contained

    if crystal_markdown_comments == 2
      syn region crystalMarkdownCodeBlock matchgroup=crystalMarkdownCodeDelimiter start=/\%#=1```\%(\s*crystal\)\=$/ end=/\%#=1^\s*#\s*\zs```$/ contained contains=crystalMarkdownCrystalCodeLineStart keepend
      syn region crystalMarkdownCodeBlock matchgroup=crystalMarkdownCodeDelimiter start=/\%#=1\~\~\~\%(\s*crystal\)\=$/ end=/\%#=1^\s*#\s*\zs\~\~\~$/ contained contains=crystalMarkdownCrystalCodeLineStart keepend

      syn match crystalMarkdownCrystalCodeLineStart /\%#=1^\s*\zs#/ contained nextgroup=crystalMarkdownCrystalCodeLine

      syn match crystalMarkdownCrystalCodeLine /\%#=1.*/ contained contains=TOP

      hi def link crystalMarkdownCrystalCodeLineStart crystalMarkdownCodeLineStart
    endif

    syn match crystalMarkdownHeading /\%#=1#\{1,6}\%(\s.*\)\=/ contained contains=@crystalMarkdownInline

    syn match crystalMarkdownOrderedListItem /\%#=1\d\+\.\%(\s.*\)\=/ contained nextgroup=crystalComment
    syn match crystalMarkdownUnorderedListItem /\%#=1[*+-]\s\@=/ contained nextgroup=crystalComment

    syn match crystalMarkdownHorizontalRule /\%#=1\*\%(\s*\*\)\{2,}$/ contained
    syn match crystalMarkdownHorizontalRule /\%#=1-\%(\s*-\)\{2,}$/ contained
    syn match crystalMarkdownHorizontalRule /\%#=1_\{3,}$/ contained

    syn match crystalMarkdownBlockQuote /\%#=1>/ contained nextgroup=@crystalMarkdownLine,crystalComment skipwhite

    " Highlighting
    hi def link crystalMarkdownDelimiter Delimiter
    hi crystalMarkdownItalic cterm=italic gui=italic
    hi crystalMarkdownBold cterm=bold gui=bold
    hi crystalMarkdownBoldItalic cterm=bold,italic gui=bold,italic
    hi def link crystalMarkdownItalicDelimiter crystalMarkdownItalic
    hi def link crystalMarkdownBoldDelimiter crystalMarkdownBold
    hi def link crystalMarkdownBoldItalicDelimiter crystalMarkdownBoldItalic
    hi def link crystalMarkdownCode String
    hi def link crystalMarkdownCodeDelimiter crystalMarkdownCode
    hi def link crystalMarkdownCodeLineStart crystalComment
    hi def link crystalMarkdownCodeLine crystalMarkdownCode
    hi def link crystalMarkdownCodeBlock crystalMarkdownCodeLine
    hi def link crystalMarkdownEscape PreProc
    hi crystalMarkdownLink cterm=underline gui=underline
    hi def link crystalMarkdownURL String
    hi def link crystalMarkdownReference Special
    hi def link crystalMarkdownRawLink crystalMarkdownLink
    hi def link crystalMarkdownImage Special
    hi def link crystalMarkdownHeading Title
    hi def link crystalMarkdownOrderedListItem Special
    hi def link crystalMarkdownUnorderedListItem Special
    hi def link crystalMarkdownHorizontalRule Special
    hi def link crystalMarkdownBlockQuote Special
    " }}}
  else
    syn match crystalComment /\%#=1#.*/ contains=crystalTodo
  endif

  syn match crystalTodo /\%#=1\<\%(BUG\|DEPRECATED\|WARNING\|EXPERIMENTAL\|FIXME\|NOTE\|OPTIMIZE\|TODO\)\w*/ contained

  syn match crystalShebang /\%#=1\%^#!.*/
  syn match crystalPragmaError /\%#=1#<loc:.*/
  syn match crystalPragma /\%#=1#<loc:\%(push\|pop\|".\{-}"\)>/

  hi def link crystalTodo Todo
  hi def link crystalShebang PreProc
  hi def link crystalPragmaError Error
  hi def link crystalPragma PreProc
endif

" Operators {{{2
syn match crystalUnaryOperator /\%#=1[+*!~&]/
syn match crystalUnaryOperator /\%#=1->\=/

syn match crystalOperator /\%#=1=\%(==\=\|[>~]\)\=/ contained
syn match crystalOperator /\%#=1![=~]/ contained
syn match crystalOperator /\%#=1<\%(<=\=\|=>\=\)\=/ contained
syn match crystalOperator /\%#=1>>\==\=/ contained
syn match crystalOperator /\%#=1+=\=/ contained
syn match crystalOperator /\%#=1-[=>]\=/ contained
syn match crystalOperator /\%#=1\*\*\==\=/ contained
syn match crystalOperator /\%#=1\// contained
" NOTE: Additional division operators are defined after /-style regexes
" in order to take precedence
syn match crystalOperator /\%#=1%=\=/ contained
syn match crystalOperator /\%#=1&\%(&=\=\|=\|+=\=\|-[=>]\=\|\*[*=]\=\)\=/ contained
syn match crystalOperator /\%#=1||\==\=/ contained
syn match crystalOperator /\%#=1\^=\=/ contained

syn region crystalTernaryOperator matchgroup=crystalOperator start=/\%#=1?/ end=/\%#=1:/ skip=/\%#=1:[:[:alpha:]_]/ contained oneline contains=TOP

syn match crystalMethodOperator /\%#=1\./ nextgroup=crystalVariableOrMethod,crystalOperatorMethod,crystalPseudoMethod skipwhite
" Generated by tools/syntax.cr:
syn match crystalOperatorMethod /\%#=1\%([+\-|^~%]\|\*\*\=\|\/\/\=\|=\%(==\=\|\~\)\|![=~]\=\|<\%(=>\=\|<\)\=\|>[>=]\=\|&\%([+-]\|\*\*\=\)\=\|\[][=?]\=\)/ contained nextgroup=@crystalPostfix,@crystalArguments skipwhite

syn match crystalRangeOperator /\%#=1\.\.\.\=/ nextgroup=crystalOperator,crystalPostfixKeyword skipwhite

syn match crystalTypeRestrictionOperator /\%#=1:/ contained nextgroup=@crystalTypes skipwhite skipempty

syn match crystalNamespaceOperator /\%#=1::/ nextgroup=crystalConstant,crystalVariableOrMethod

" Type grammar {{{2
syn cluster crystalTypes contains=crystalType,crystalTypeNamespaceOperator,crystalTypeTuple,crystalTypeProcOperator,crystalTypeGroup,crystalTypeSelf,crystalTypeNil,crystalTypeTypeof
syn cluster crystalTypesPostfix contains=crystalTypeModifier,crystalTypeComma,crystalTypeUnionOperator,crystalTypeProcOperator,crystalTypeHashOperator,crystalTypeArray,crystalAssignmentOperator

syn match crystalType /\%#=1\u\w*/ contained nextgroup=@crystalTypesPostfix,crystalTypeNamespaceOperator,crystalTypeGeneric skipwhite
syn match crystalType /\%#=1_\>/ contained nextgroup=@crystalTypesPostfix,crystalTypeNamespaceOperator,crystalTypeGeneric skipwhite

syn match crystalTypeNamespaceOperator /\%#=1::/ contained nextgroup=crystalType skipwhite skipempty

syn region crystalTypeTuple matchgroup=crystalDelimiter start=/\%#=1{/ end=/\%#=1}/ contained contains=@crystalTypes,crystalNamedTupleKey nextgroup=@crystalTypesPostfix,crystalTypeNamespaceOperator skipwhite

syn region crystalTypeGeneric matchgroup=crystalDelimiter start=/\%#=1(/ end=/\%#=1)/ contained contains=@crystalTypes,crystalNumber,crystalNamedTupleKey nextgroup=@crystalTypesPostfix skipwhite

syn match crystalTypeModifier /\%#=1[?*]\+/ contained nextgroup=@crystalTypesPostfix skipwhite
syn match crystalTypeModifier /\%#=1\./ contained nextgroup=crystalTypeModifierClass skipwhite skipempty
syn keyword crystalTypeModifierClass class contained nextgroup=@crystalTypesPostfix skipwhite
syn region crystalTypeArray matchgroup=crystalDelimiter start=/\%#=1\[/ end=/\%#=1\]/ contained contains=crystalNumber,crystalConstant nextgroup=@crystalTypesPostfix skipwhite

syn match crystalAssignmentOperator /\%#=1=/ contained

syn match crystalTypeUnionOperator /\%#=1|/ contained nextgroup=@crystalTypes skipwhite skipempty
syn match crystalTypeProcOperator /\%#=1->/ contained nextgroup=@crystalTypes skipwhite skipempty
syn match crystalTypeHashOperator /\%#=1=>/ contained nextgroup=@crystalTypes skipwhite skipempty

syn match crystalTypeComma /\%#=1,/ contained nextgroup=@crystalTypes skipwhite skipempty

syn region crystalTypeGroup matchgroup=crystalDelimiter start=/\%#=1(/ end=/\%#=1)/ contained contains=@crystalTypes nextgroup=@crystalTypesPostfix skipwhite

syn keyword crystalTypeSelf self contained nextgroup=@crystalTypesPostfix skipwhite
syn keyword crystalTypeNil nil contained nextgroup=@crystalTypesPostfix skipwhite

syn keyword crystalTypeTypeof typeof contained nextgroup=crystalTypeTypeofInvocation skipwhite skipempty
syn region crystalTypeTypeofInvocation matchgroup=crystalDelimiter start=/\%#=1(/ end=/\%#=1)/ contained contains=TOP nextgroup=@crystalTypesPostfix skipwhite

" Delimiters {{{2
syn match crystalDelimiter /\%#=1(/ nextgroup=crystalNamedTupleKey skipwhite skipempty
syn match crystalDelimiter /\%#=1)/ nextgroup=@crystalPostfix skipwhite

syn match crystalDelimiter /\%#=1\[/
syn match crystalDelimiter /\%#=1]?\=/ nextgroup=@crystalPostfix,crystalOf skipwhite
syn keyword crystalOf of contained nextgroup=@crystalTypes skipwhite skipempty

syn match crystalDelimiter /\%#=1{/ nextgroup=crystalNamedTupleKey,crystalBlockParameters skipwhite skipempty
syn match crystalDelimiter /\%#=1}/ nextgroup=@crystalPostfix,crystalOf skipwhite

syn match crystalComma /\%#=1,/ contained nextgroup=crystalNamedTupleKey,crystalOut skipwhite skipempty

syn match crystalBackslash /\%#=1\\/

" Identifiers {{{2
syn match crystalInstanceVariable /\%#=1@\h\w*/ nextgroup=@crystalPostfix skipwhite
syn match crystalClassVariable /\%#=1@@\h\w*/ nextgroup=@crystalPostfix skipwhite
syn match crystalFreshVariable /\%#=1%\h\w*/ nextgroup=@crystalPostfix skipwhite
syn match crystalExternalVariable /\%#=1\$\%([~?]\|\d\+?\=\|[[:lower:]_]\w*\)/ nextgroup=@crystalPostfix skipwhite

syn match crystalConstant /\%#=1\u\w*/ nextgroup=@crystalPostfix skipwhite
syn match crystalVariableOrMethod /\%#=1[[:lower:]_]\w*[?!]\=/ nextgroup=@crystalPostfix,@crystalArguments skipwhite
syn keyword crystalPseudoMethod is_a? as contained nextgroup=@crystalTypes skipwhite
syn keyword crystalPseudoMethod sizeof instance_sizeof nextgroup=@crystalTypes skipwhite

" Literals {{{2
" Keywords {{{3
syn keyword crystalNil nil nextgroup=@crystalPostfix skipwhite
syn keyword crystalBoolean true false nextgroup=@crystalPostfix skipwhite
syn keyword crystalSelf self nextgroup=@crystalPostfix skipwhite
syn keyword crystalSuper super nextgroup=@crystalPostfix,@crystalArguments skipwhite

" Numbers {{{3
" The following two patterns were generated by tools/syntax.cr:
syn match crystalNumber /\%#=1[1-9]\d*\%(_\d\+\)*\%([ui]\%(8\|16\|32\|64\|128\)\|f\%(32\|64\)\|[eE][+-]\=\d\+\%(_\d\+\)*\%(_\=f\%(32\|64\)\)\=\|_\%([ui]\%(8\|16\|32\|64\|128\)\|f\%(32\|64\)\|[eE][+-]\=\d\+\%(_\d\+\)*\%(_\=f\%(32\|64\)\)\=\)\|\.\d\+\%(_\d\+\)*\%(f\%(32\|64\)\|[eE][+-]\=\d\+\%(_\d\+\)*\%(_\=f\%(32\|64\)\)\=\|_\%(f\%(32\|64\)\|[eE][+-]\=\d\+\%(_\d\+\)*\%(_\=f\%(32\|64\)\)\=\)\)\=\)\=\>/ nextgroup=@crystalPostfix skipwhite
syn match crystalNumber /\%#=10\%([ui]\%(8\|16\|32\|64\|128\)\|f\%(32\|64\)\|_\%([ui]\%(8\|16\|32\|64\|128\)\|f\%(32\|64\)\|[eE][+-]\=\d\+\%(_\d\+\)*\%(_\=f\%(32\|64\)\)\=\)\|\.\d\+\%(_\d\+\)*\%(f\%(32\|64\)\|[eE][+-]\=\d\+\%(_\d\+\)*\%(_\=f\%(32\|64\)\)\=\|_\%(f\%(32\|64\)\|[eE][+-]\=\d\+\%(_\d\+\)*\%(_\=f\%(32\|64\)\)\=\)\)\=\|b[01]\+\%(_[01]\+\)*\%([ui]\%(8\|16\|32\|64\|128\)\)\=\|o\o\+\%(_\o\+\)*\%([ui]\%(8\|16\|32\|64\|128\)\)\=\|x\x\+\%(_\x\+\)*\%([ui]\%(8\|16\|32\|64\|128\)\)\=\)\=\>/ nextgroup=@crystalPostfix skipwhite

" Characters {{{3
syn match crystalCharacterError /\%#=1'.\{-}'/ nextgroup=@crystalPostfix skipwhite
syn match crystalCharacter /\%#=1'\%(\\\%(u\%(\x\{4}\|{\x\{1,6}}\)\|.\)\|.\)'/ contains=crystalCharacterEscape,crystalCharacterEscapeError nextgroup=@crystalPostfix skipwhite

syn match crystalCharacterEscapeError /\%#=1\\./ contained
syn match crystalCharacterEscape /\%#=1\\\%(u\%(\x\{4}\|{\x\{1,6}}\)\|['\\abefnrtv0]\)/ contained

" Strings {{{3
syn region crystalString matchgroup=crystalStringStart start=/\%#=1"/ matchgroup=crystalStringEnd end=/\%#=1"/ contains=crystalStringInterpolation,crystalStringEscape,crystalStringEscapeError nextgroup=@crystalPostfix skipwhite

syn region crystalString matchgroup=crystalStringStart start=/\%#=1%Q\=(/ matchgroup=crystalStringEnd end=/\%#=1)/ contains=crystalStringParentheses,crystalStringInterpolation,crystalStringEscape,crystalStringEscapeError nextgroup=@crystalPostfix skipwhite
syn region crystalStringParentheses matchgroup=crystalString start=/\%#=1(/ end=/\%#=1)/ transparent contained

syn region crystalString matchgroup=crystalStringStart start=/\%#=1%Q\=\[/ matchgroup=crystalStringEnd end=/\%#=1]/ contains=crystalStringSquareBrackets,crystalStringInterpolation,crystalStringEscape,crystalStringEscapeError nextgroup=@crystalPostfix skipwhite
syn region crystalStringSquareBrackets matchgroup=crystalString start=/\%#=1\[/ end=/\%#=1]/ transparent contained

syn region crystalString matchgroup=crystalStringStart start=/\%#=1%Q\={/ matchgroup=crystalStringEnd end=/\%#=1}/ contains=crystalStringCurlyBraces,crystalStringInterpolation,crystalStringEscape,crystalStringEscapeError nextgroup=@crystalPostfix skipwhite
syn region crystalStringCurlyBraces matchgroup=crystalString start=/\%#=1{/ end=/\%#=1}/ transparent contained

syn region crystalString matchgroup=crystalStringStart start=/\%#=1%Q\=</ matchgroup=crystalStringEnd end=/\%#=1>/ contains=crystalStringAngleBrackets,crystalStringInterpolation,crystalStringEscape,crystalStringEscapeError nextgroup=@crystalPostfix skipwhite
syn region crystalStringAngleBrackets matchgroup=crystalString start=/\%#=1</ end=/\%#=1>/ transparent contained

syn region crystalString matchgroup=crystalStringStart start=/\%#=1%Q\=|/ matchgroup=crystalStringEnd end=/\%#=1|/ contains=crystalStringInterpolation,crystalStringEscape,crystalStringEscapeError nextgroup=@crystalPostfix skipwhite

syn region crystalStringInterpolation matchgroup=crystalStringInterpolationDelimiter start=/\%#=1#{/ end=/\%#=1}/ contained contains=@crystalTop,crystalNestedBraces

syn match crystalStringEscape /\%#=1\\\_./ contained
syn match crystalStringEscapeError /\%#=1\\\%(x\x\=\|u\x\{,3}\)/ contained
syn match crystalStringEscape /\%#=1\\\%(\o\{1,3}\|x\x\x\|u\%(\x\{4}\|{\x\{1,6}\%(\s\x\{1,6}\)*}\)\)/ contained
syn match crystalStringEscapeError /\%#=1\\\o\{4,}/ contained

syn region crystalString matchgroup=crystalStringStart start=/\%#=1%q(/  matchgroup=crystalStringEnd end=/\%#=1)/ contains=crystalStringParentheses  nextgroup=@crystalPostfix skipwhite
syn region crystalString matchgroup=crystalStringStart start=/\%#=1%q\[/ matchgroup=crystalStringEnd end=/\%#=1]/ contains=crystalStringSquareBrackets nextgroup=@crystalPostfix skipwhite
syn region crystalString matchgroup=crystalStringStart start=/\%#=1%q{/  matchgroup=crystalStringEnd end=/\%#=1}/ contains=crystalStringCurlyBraces  nextgroup=@crystalPostfix skipwhite
syn region crystalString matchgroup=crystalStringStart start=/\%#=1%q</  matchgroup=crystalStringEnd end=/\%#=1>/ contains=crystalStringAngleBrackets  nextgroup=@crystalPostfix skipwhite
syn region crystalString matchgroup=crystalStringStart start=/\%#=1%q|/  matchgroup=crystalStringEnd end=/\%#=1|/ nextgroup=@crystalPostfix skipwhite

syn region crystalStringArray matchgroup=crystalStringArrayDelimiter start=/\%#=1%w(/ end=/\%#=1)/ contains=crystalStringParentheses,crystalStringParenthesisEscape nextgroup=@crystalPostfix skipwhite
syn match crystalStringParenthesisEscape /\%#=1\\[()[:space:]]/ contained

syn region crystalStringArray matchgroup=crystalStringArrayDelimiter start=/\%#=1%w\[/ end=/\%#=1]/ contains=crystalStringSquareBrackets,crystalStringSquareBracketEscape nextgroup=@crystalPostfix skipwhite
syn match crystalStringSquareBracketEscape /\%#=1\\[\[\][:space:]]/ contained

syn region crystalStringArray matchgroup=crystalStringArrayDelimiter start=/\%#=1%w{/ end=/\%#=1}/ contains=crystalStringCurlyBraces,crystalStringCurlyBraceEscape nextgroup=@crystalPostfix skipwhite
syn match crystalStringCurlyBraceEscape /\%#=1\\[{}[:space:]]/ contained

syn region crystalStringArray matchgroup=crystalStringArrayDelimiter start=/\%#=1%w</ end=/\%#=1>/ contains=crystalStringAngleBrackets,crystalStringAngleBracketEscape nextgroup=@crystalPostfix skipwhite
syn match crystalStringAngleBracketEscape /\%#=1\\[<>[:space:]]/ contained

syn region crystalStringArray matchgroup=crystalStringArrayDelimiter start=/\%#=1%w|/ end=/\%#=1|/ contains=crystalStringPipeEscape nextgroup=@crystalPostfix skipwhite
syn match crystalStringPipeEscape /\%#=1\\[|[:space:]]/ contained

" Here Documents {{{3
syn region crystalHeredoc matchgroup=crystalHeredocStart start=/\%#=1<<-\z(\w\+\)/ matchgroup=crystalHeredocEnd end=/\%#=1^\s*\z1$/ contains=crystalHeredocStartLine,crystalHeredocLine
syn match crystalHeredocStartLine /\%#=1.*/ contained contains=TOP nextgroup=crystalHeredocLine skipempty
syn match crystalHeredocLine /\%#=1^.*/ contained contains=crystalStringInterpolation,crystalStringEscape,crystalStringEscapeError nextgroup=crystalHeredocLine skipempty

syn region crystalHeredoc matchgroup=crystalHeredocStart start=/\%#=1<<-'\z(\w\+\)'/ matchgroup=crystalHeredocEnd end=/\%#=1^\s*\z1$/ contains=crystalHeredocStartLineRaw,crystalHeredocLineRaw
syn match crystalHeredocStartLineRaw /\%#=1.*/ contained contains=TOP nextgroup=crystalHeredocLineRaw skipempty
syn match crystalHeredocLineRaw /\%#=1^.*/ contained nextgroup=crystalHeredocLineRaw skipempty

syn region crystalHeredocSkip matchgroup=crystalHeredocStart start=/\%#=1<<-\('\=\)\w\+\1/ end=/\%#=1\ze<<-'\=\w/ contains=@crystalPostfix,@crystalArguments oneline nextgroup=crystalHeredoc,crystalHeredocSkip

" Symbols {{{3
syn match crystalSymbol /\%#=1:\h\w*[=?!]\=/ contains=crystalSymbolStart nextgroup=@crystalPostfix skipwhite
" Generated by tools/syntax.cr:
syn match crystalSymbol /\%#=1:\%([+\-|^~%]\|\*\*\=\|\/\/\=\|=\%(==\=\|\~\)\|![=~]\=\|<\%(=>\=\|<\)\=\|>[>=]\=\|&\%([+-]\|\*\*\=\)\=\|\[][=?]\=\)/ contains=crystalSymbolStart nextgroup=@crystalPostfix skipwhite

syn match crystalSymbolStart /\%#=1:/ contained

syn region crystalSymbol matchgroup=crystalSymbolStart start=/\%#=1:"/ matchgroup=crystalSymbolEnd end=/\%#=1"/ contains=crystalStringInterpolation,crystalStringEscape,crystalStringEscapeError nextgroup=@crystalPostfix skipwhite

syn region crystalSymbolArray matchgroup=crystalSymbolArrayDelimiter start=/\%#=1%i(/  end=/\%#=1)/ contains=crystalStringParentheses,crystalStringParenthesisEscape nextgroup=@crystalPostfix skipwhite
syn region crystalSymbolArray matchgroup=crystalSymbolArrayDelimiter start=/\%#=1%i\[/ end=/\%#=1]/ contains=crystalStringSquareBrackets,crystalStringSquareBracketEscape nextgroup=@crystalPostfix skipwhite
syn region crystalSymbolArray matchgroup=crystalSymbolArrayDelimiter start=/\%#=1%i{/  end=/\%#=1}/ contains=crystalStringCurlyBraces,crystalStringCurlyBraceEscape nextgroup=@crystalPostfix skipwhite
syn region crystalSymbolArray matchgroup=crystalSymbolArrayDelimiter start=/\%#=1%i</  end=/\%#=1>/ contains=crystalStringAngleBrackets,crystalStringAngleBracketEscape nextgroup=@crystalPostfix skipwhite
syn region crystalSymbolArray matchgroup=crystalSymbolArrayDelimiter start=/\%#=1%i|/  end=/\%#=1|/ contains=crystalStringPipeEscape nextgroup=@crystalPostfix skipwhite

syn match crystalNamedTupleKey /\%#=1[[:lower:]_]\w*[?!]\=:/ contained contains=crystalSymbolStart
syn match crystalNamedTupleKey /\%#=1\u\w*::\@!/ contained contains=crystalSymbolStart

" Regular Expressions {{{3
syn region crystalRegex matchgroup=crystalRegexStart start=/\%#=1\/\s\@!/ matchgroup=crystalRegexEnd end=/\%#=1\/[imx]*/ skip=/\%#=1\\\\\|\\\// oneline keepend contains=crystalStringInterpolation,@crystalPCRE nextgroup=@crystalPostfix skipwhite

" NOTE: These operators are defined here in order to take precedence
" over /-style regexes
syn match crystalOperator /\%#=1\/[/=]/ contained

syn region crystalRegex matchgroup=crystalRegexStart start=/\%#=1%r(/  matchgroup=crystalRegexEnd end=/\%#=1)[imx]*/ contains=crystalStringInterpolation,@crystalPCRE nextgroup=@crystalPostfix skipwhite
syn region crystalRegex matchgroup=crystalRegexStart start=/\%#=1%r\[/ matchgroup=crystalRegexEnd end=/\%#=1][imx]*/ contains=crystalStringInterpolation,@crystalPCRE nextgroup=@crystalPostfix skipwhite
syn region crystalRegex matchgroup=crystalRegexStart start=/\%#=1%r{/  matchgroup=crystalRegexEnd end=/\%#=1}[imx]*/ skip=/\%#=1{.\{-}}/ contains=crystalStringInterpolation,@crystalPCRE nextgroup=@crystalPostfix skipwhite
syn region crystalRegex matchgroup=crystalRegexStart start=/\%#=1%r</  matchgroup=crystalRegexEnd end=/\%#=1>[imx]*/ skip=/\%#=1<.\{-}>/ contains=crystalStringInterpolation,@crystalPCRE nextgroup=@crystalPostfix skipwhite
syn region crystalRegex matchgroup=crystalRegexStart start=/\%#=1%r|/  matchgroup=crystalRegexEnd end=/\%#=1|[imx]*/ contains=crystalStringInterpolation,@crystalPCRE nextgroup=@crystalPostfix skipwhite

" PCRE {{{4
syn cluster crystalPCRE contains=
      \ crystalPCREEscape,crystalPCRELiteral,crystalPCREMetaCharacter,crystalPCREClass,crystalPCREQuantifier,
      \ crystalPCREGroup,crystalPCREComment,crystalPCREControl

" The following two patterns were generated by tools/syntax.cr:
syn match crystalPCREEscape /\%#=1\\\%(c.\|\d\+\|o{\o\+}\|x\%(\x\x\|{\x\+}\)\|[pP]{\h\w*}\|g\%(\d\+\|{\%(-\=\d\+\|\h\w*\)}\|<\%(-\=\d\+\|\h\w*\)>\|'\%(-\=\d\+\|\h\w*\)'\)\|k\%(<\h\w*>\|'\h\w*'\|{\h\w*}\)\)/ contained
syn region crystalPCREGroup matchgroup=crystalPCREMetaCharacter start=/\%#=1(\%(?\%(<\h\w*>\|'\h\w*'\|P\%(<\h\w*>\|[>=]\h\w*\)\|[:|>=!]\|-\=[iJmsUx]\+:\=\|<[=!]\|R\|[+-]\=\d\+\|&\h\w*\|(\%([+-]\=\d\+\|<\h\w*>\|'\h\w*'\|R\%(\d\+\|&\h\w*\)\|\h\w*\))\|C\d*\)\)\=/ end=/\%#=1)/ contained transparent

syn region crystalPCRELiteral matchgroup=crystalPCREEscape start=/\%#=1\\Q/ end=/\%#=1\\E/ contained transparent contains=crystalRegexSlashEscape

syn match crystalPCREMetaCharacter /\%#=1[.^$|]/ contained

syn region crystalPCREClass matchgroup=crystalPCREMetaCharacter start=/\%#=1\[\^\=/ end=/\%#=1\]/ contained transparent contains=crystalPCREEscape,crystalPCREPOSIXClass
syn match crystalPCREPOSIXClass /\%#=1\[:\^\=\h\w*:\]/ contained

syn match crystalPCREQuantifier /\%#=1[?*+][+?]\=/ contained
syn match crystalPCREQuantifier /\%#=1{\d\+,\=\d*}[+?]\=/ contained

syn region crystalPCREComment matchgroup=crystalPCREMetaCharacter start=/\%#=1(?#/ end=/\%#=1)/ contained contains=crystalRegexSlashEscape

syn match crystalPCREControl /\%#=1(\*.\{-})/ contained

syn match crystalRegexSlashEscape /\%#=1\\\// contained

" Commands {{{3
syn region crystalCommand matchgroup=crystalCommandStart start=/\%#=1`/ matchgroup=crystalCommandEnd end=/\%#=1`/ contains=crystalStringInterpolation,crystalStringEscape,crystalStringEscapeError nextgroup=@crystalPostfix skipwhite

syn region crystalCommand matchgroup=crystalCommandStart start=/\%#=1%x(/  matchgroup=crystalCommandEnd end=/\%#=1)/ contains=crystalStringParentheses,crystalStringInterpolation,crystalStringEscape,crystalStringEscapeError nextgroup=@crystalPostfix skipwhite
syn region crystalCommand matchgroup=crystalCommandStart start=/\%#=1%x\[/ matchgroup=crystalCommandEnd end=/\%#=1]/ contains=crystalStringSquareBrackets,crystalStringInterpolation,crystalStringEscape,crystalStringEscapeError nextgroup=@crystalPostfix skipwhite
syn region crystalCommand matchgroup=crystalCommandStart start=/\%#=1%x{/  matchgroup=crystalCommandEnd end=/\%#=1}/ contains=crystalStringCurlyBraces,crystalStringInterpolation,crystalStringEscape,crystalStringEscapeError nextgroup=@crystalPostfix skipwhite
syn region crystalCommand matchgroup=crystalCommandStart start=/\%#=1%x</  matchgroup=crystalCommandEnd end=/\%#=1>/ contains=crystalStringAngleBrackets,crystalStringInterpolation,crystalStringEscape,crystalStringEscapeError nextgroup=@crystalPostfix skipwhite
syn region crystalCommand matchgroup=crystalCommandStart start=/\%#=1%x|/  matchgroup=crystalCommandEnd end=/\%#=1|/ contains=crystalStringInterpolation,crystalStringEscape,crystalStringEscapeError nextgroup=@crystalPostfix skipwhite

" Blocks {{{2
if get(g:, "crystal_simple_indent") || get(b:, "is_ecrystal")
  syn keyword crystalKeyword if unless case while until begin for else elsif when in ensure
  syn keyword crystalKeyword rescue nextgroup=crystalConstant skipwhite
  syn keyword crystalKeyword end nextgroup=@crystalPostfix skipwhite
  syn keyword crystalKeyword do nextgroup=crystalBlockParameters skipwhite

  syn keyword crystalKeyword def macro nextgroup=crystalMethodDefinition,crystalMethodReceiver,crystalMethodSelf skipwhite
  syn keyword crystalKeyword class struct lib annotation enum module union nextgroup=crystalTypeDefinition skipwhite

  syn keyword crystalKeyword abstract nextgroup=crystalKeywordNoBlock skipwhite
  syn keyword crystalKeyword private protected nextgroup=crystalConstant skipwhite

  syn keyword crystalKeyword alias nextgroup=crystalTypeAlias skipwhite

  syn keyword crystalKeywordNoBlock def contained nextgroup=crystalMethodDefinition,crystalMethodReceiver,crystalMethodSelf skipwhite
  syn keyword crystalKeywordNoBlock fun nextgroup=crystalLibMethodDefinition skipwhite

  hi def link crystalKeywordNoBlock crystalKeyword
else
  " NOTE: When definition blocks are highlighted, the following keywords
  " have to be matched with :syn-match instead of :syn-keyword to
  " prevent the block regions from being clobbered.

  syn keyword crystalKeywordError end else elsif when in ensure rescue then

  syn match crystalKeyword /\%#=1\<do\>/ nextgroup=crystalBlockParameters skipwhite contained containedin=crystalBlock
  syn region crystalBlock start=/\%#=1\<do\>/ matchgroup=crystalKeyword end=/\%#=1\<\.\@1<!end\>/ contains=TOP nextgroup=@crystalPostfix skipwhite

  syn region crystalBlock matchgroup=crystalKeyword start=/\%#=1\<\%(if\|unless\|case\|while\|until\|begin\)\>/ end=/\%#=1\<\.\@1<!end\>/ contains=TOP nextgroup=@crystalPostfix skipwhite
  syn keyword crystalKeyword else elsif when in ensure contained containedin=crystalBlock
  syn keyword crystalKeyword rescue contained containedin=crystalBlock nextgroup=crystalConstant skipwhite

  syn match crystalDefine /\%#=1\<\%(def\|macro\)\>/ nextgroup=crystalMethodDefinition,crystalMethodReceiver,crystalMethodSelf skipwhite contained containedin=crystalDefineBlock
  syn match crystalDefine /\%#=1\<\%(class\|struct\|lib\|annotation\|enum\|module\|union\)\>/ nextgroup=crystalTypeDefinition skipwhite contained containedin=crystalDefineBlock

  syn region crystalDefineBlock start=/\%#=1\<\%(def\|macro\|class\|struct\|lib\|annotation\|enum\|module\|union\)\>/ matchgroup=crystalDefine end=/\%#=1\<\.\@1<!end\>/ contains=TOP fold
  syn keyword crystalDefine else ensure contained containedin=crystalDefineBlock
  syn keyword crystalDefine rescue contained containedin=crystalDefineBlock nextgroup=crystalConstant skipwhite

  syn keyword crystalDefine abstract nextgroup=crystalDefineNoBlock skipwhite
  syn keyword crystalDefine private protected nextgroup=crystalDefineBlock,crystalConstant skipwhite

  syn keyword crystalDefine type alias nextgroup=crystalTypeAlias skipwhite

  syn keyword crystalDefineNoBlock def contained nextgroup=crystalMethodDefinition,crystalMethodReceiver,crystalMethodSelf skipwhite
  syn keyword crystalDefineNoBlock fun nextgroup=crystalLibMethodDefinition skipwhite

  syn keyword crystalMacroKeyword if unless else elsif begin for in do end contained containedin=crystalMacro

  hi def link crystalDefine Define
  hi def link crystalDefineNoBlock crystalDefine
  hi def link crystalMacroKeyword crystalKeyword
endif

syn match crystalTypeDefinition /\%#=1\u\w*/ contained nextgroup=crystalTypeNamespace,crystalInheritanceOperator skipwhite
syn match crystalTypeNamespace /\%#=1::/ contained nextgroup=crystalTypeDefinition
syn match crystalInheritanceOperator /\%#=1</ contained nextgroup=crystalConstant skipwhite

syn match crystalMethodDefinition /\%#=1[[:lower:]_]\w*[=?!]\=/ contained nextgroup=crystalMethodParameters,crystalTypeRestrictionOperator skipwhite
" Generated by tools/syntax.cr:
syn match crystalMethodDefinition /\%#=1\%([+\-|^~%]\|\*\*\=\|\/\/\=\|=\%(==\=\|\~\)\|![=~]\=\|<\%(=>\=\|<\)\=\|>[>=]\=\|&\%([+-]\|\*\*\=\)\=\|\[][=?]\=\)/ contained nextgroup=crystalMethodParameters,crystalTypeRestrictionOperator skipwhite
syn region crystalMethodParameters matchgroup=crystalDelimiter start=/\%#=1(/ end=/\%#=1)/ contained contains=TOP,crystalKeyword,crystalDefine,crystalBlock,crystalDefineBlock,crystalKeywordError nextgroup=crystalTypeRestrictionOperator skipwhite
syn keyword crystalOut out contained containedin=crystalMethodParameters
syn match crystalMethodReceiver /\%#=1\u\w*/ contained nextgroup=crystalMethodDot
syn keyword crystalMethodSelf self contained nextgroup=crystalMethodDot
syn match crystalMethodDot /\%#=1\./ contained nextgroup=crystalMethodDefinition

syn match crystalLibMethodDefinition /\%#=1[[:lower:]_]\w*[?!]\=/ contained nextgroup=crystalMethodParameters,crystalTypeRestrictionOperator,crystalMethodAssignmentOperator skipwhite
syn match crystalLibMethodDefinition /\%#=1\u\w*/ contained nextgroup=crystalMethodParameters,crystalTypeRestrictionOperator,crystalMethodAssignmentOperator skipwhite
syn match crystalMethodAssignmentOperator /\%#=1=/ contained nextgroup=crystalCFunctionName,crystalCFunctionStringName skipwhite
syn match crystalCFunctionName /\%#=1\h\w*/ contained nextgroup=crystalMethodParameters,crystalTypeRestrictionOperator skipwhite
syn region crystalCFunctionStringName matchgroup=crystalStringStart start=/\%#=1"/ end=/\%#=1"/ contained oneline nextgroup=crystalMethodParameters,crystalTypeRestrictionOperator skipwhite

" Miscellaneous {{{2
syn keyword crystalKeyword forall with
syn keyword crystalKeyword uninitialized nextgroup=@crystalTypes skipwhite

syn match crystalTypeAlias /\%#=1\u\w*/ contained nextgroup=crystalTypeAliasOperator skipwhite
syn match crystalTypeAliasOperator /\%#=1=/ contained nextgroup=@crystalTypes skipwhite skipempty

syn keyword crystalKeyword include extend nextgroup=crystalConstant skipwhite
syn keyword crystalKeyword return next break nextgroup=crystalPostfixKeyword skipwhite
syn keyword crystalKeyword require nextgroup=crystalString skipwhite

syn keyword crystalPostfixKeyword if unless rescue then contained

syn region crystalBlockParameters matchgroup=crystalDelimiter start=/\%#=1|/ end=/\%#=1|/ contained
syn match crystalBlockParameter /\%#=1[[:lower:]_]\w*/ contained containedin=crystalBlockParameters,crystalBlockParentheses
syn region crystalBlockParentheses matchgroup=crystalDelimiter start=/\%#=1(/ end=/\%#=1)/ contained containedin=crystalBlockParameters

syn region crystalNestedBraces start=/\%#=1{/ matchgroup=crystalDelimiter end=/\%#=1}/ contained transparent nextgroup=@crystalPostfix skipwhite

syn region crystalAnnotation matchgroup=crystalAnnotationDelimiter start=/\%#=1@\[/ end=/\%#=1]/ contains=@crystalTop,crystalNestedBrackets

syn region crystalNestedBrackets matchgroup=crystalDelimiter start=/\%#=1\[/ end=/\%#=1]?\=/ contained transparent nextgroup=@crystalPostfix

" Macros {{{2
syn region crystalMacro matchgroup=crystalMacroDelimiter start=/\%#=1\\\={{/ end=/\%#=1}}/ oneline contains=@crystalTop,crystalNestedBraces nextgroup=@crystalPostfix skipwhite
syn region crystalMacro matchgroup=crystalMacroDelimiter start=/\%#=1\\\={%/ end=/\%#=1%}/ oneline contains=TOP
" }}}2

" Highlighting {{{1
hi def link crystalComment Comment
hi def link crystalOperator Operator
hi def link crystalUnaryOperator crystalOperator
hi def link crystalMethodOperator crystalOperator
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
hi def link crystalSuper Constant
hi def link crystalNumber Number
hi def link crystalCharacter Character
hi def link crystalCharacterError Error
hi def link crystalCharacterEscape SpecialChar
hi def link crystalCharacterEscapeError crystalCharacterError
hi def link crystalString String
hi def link crystalStringStart crystalString
hi def link crystalStringEnd crystalStringStart
hi def link crystalStringEscape SpecialChar
hi def link crystalStringEscapeError Error
hi def link crystalStringInterpolationDelimiter PreProc
hi def link crystalStringParenthesisEscape crystalStringEscape
hi def link crystalStringSquareBracketEscape crystalStringEscape
hi def link crystalStringCurlyBraceEscape crystalStringEscape
hi def link crystalStringAngleBracketEscape crystalStringEscape
hi def link crystalStringPipeEscape crystalStringEscape
hi def link crystalStringArray crystalString
hi def link crystalStringArrayDelimiter crystalStringArray
hi def link crystalHeredocLine String
hi def link crystalHeredocLineRaw crystalHeredocLine
hi def link crystalHeredocStart crystalStringStart
hi def link crystalHeredocEnd crystalHeredocStart
hi def link crystalSymbol String
hi def link crystalSymbolStart crystalSymbol
hi def link crystalSymbolEnd crystalSymbolStart
hi def link crystalSymbolArray crystalSymbol
hi def link crystalSymbolArrayDelimiter crystalSymbolArray
hi def link crystalNamedTupleKey crystalSymbol
hi def link crystalRegex String
hi def link crystalRegexStart crystalRegex
hi def link crystalRegexEnd crystalRegexStart
hi def link crystalRegexSlashEscape crystalStringEscape
hi def link crystalPCREMetaCharacter SpecialChar
hi def link crystalPCREEscape crystalPCREMetaCharacter
hi def link crystalPCREQuantifier crystalPCREMetaCharacter
hi def link crystalPCREPOSIXClass crystalPCREMetaCharacter
hi def link crystalPCREComment crystalComment
hi def link crystalPCREControl crystalPCREMetaCharacter
hi def link crystalCommand String
hi def link crystalCommandStart crystalCommand
hi def link crystalCommandEnd crystalCommandStart
hi def link crystalKeyword Keyword
hi def link crystalKeywordError Error
hi def link crystalPostfixKeyword crystalKeyword
hi def link crystalMethodDefinition Function
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
hi def link crystalMethodAssignmentOperator crystalAssignmentOperator
hi def link crystalCFunctionStringName crystalString
hi def link crystalTypeRestrictionOperator crystalOperator
hi def link crystalType Type
hi def link crystalTypeOperator crystalOperator
hi def link crystalTypeNamespaceOperator crystalTypeOperator
hi def link crystalTypeModifier crystalTypeOperator
hi def link crystalTypeModifierClass crystalVariableOrMethod
hi def link crystalTypeUnionOperator crystalTypeOperator
hi def link crystalTypeProcOperator crystalTypeOperator
hi def link crystalTypeHashOperator crystalTypeOperator
hi def link crystalTypeSelf crystalSelf
hi def link crystalTypeNil crystalNil
hi def link crystalTypeTypeof crystalVariableOrMethod
hi def link crystalPseudoMethod crystalVariableOrMethod
hi def link crystalOut crystalKeyword
hi def link crystalOf crystalKeyword
" }}}

" vim:fdm=marker
