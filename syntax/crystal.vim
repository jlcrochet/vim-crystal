" Vim syntax file
" Language: Crystal <crystal-lang.org>
" Author: Jeffrey Crochet <jlcrochet91@pm.me>
" URL: https://github.com/jlcrochet/vim-crystal

if exists("b:current_syntax")
  finish
endif

let b:current_syntax = "crystal"

" Syntax <<<1
syn sync fromstart
syn iskeyword @,48-57,_,?,!,:,160-255

let s:no_expensive = get(g:, "crystal_simple_indent") || get(b:, "is_ecrystal")

if get(b:, "is_ecrystal")
  syn cluster crystalTop contains=@crystal
else
  syn cluster crystalTop contains=TOP
endif

syn cluster crystalPostfix contains=crystalOperator,crystalMethodOperator,crystalTernaryOperator,crystalRangeOperator,crystalPostfixKeyword,crystalComma,crystalBackslash,crystalSemicolon,crystalMacro

syn match crystalNamedTupleKey /\%#=1[^\x00-\x5E`\x7B-\x9F][^\x00-\x2F\x3A-\x40\x5B-\x5E`\x7B-\x9F]*[?!]\=/ contained nextgroup=crystalNamedTupleKeyDelimiter
syn match crystalNamedTupleKey /\%#=1\u[^\x00-\x2F\x3A-\x40\x5B-\x5E`\x7B-\x9F]*/ contained nextgroup=crystalNamedTupleKeyDelimiter

syn match crystalNamedTupleKeyDelimiter /\%#=1:/ contained nextgroup=@crystalRHS skipwhite skipempty

" Comments <<<2
if get(b:, "is_ecrystal")
  syn match crystalComment /\%#=1#.\{-}\ze\%(-\=%>\)\=/
else
  let s:crystal_markdown_comments = get(g:, "crystal_markdown_comments")

  if s:crystal_markdown_comments
    syn match crystalCommentStart /\%#=1#/ nextgroup=crystalInlineComment
    syn match crystalInlineComment /\%#=1.*/ contained

    syn match crystalCommentStart /\%#=1^\s*\zs#/ nextgroup=crystalCommentSpace

    syn match crystalCommentSpace /\%#=1\s*/ contained nextgroup=crystalComment,crystalMarkdownDirective,@crystalMarkdownLine
    syn match crystalCommentSpace /\%#=1 \{4}/ contained nextgroup=crystalMarkdownCodeLine
    syn match crystalCommentSpace /\%#=1\t/ contained nextgroup=crystalMarkdownCodeLine

    syn match crystalComment /\%#=1.*/ contained contains=@crystalMarkdownInline

    syn keyword crystalMarkdownDirective :nodoc: :inherit: :ditto: contained

    hi def link crystalCommentStart crystalComment
    hi def link crystalInlineComment crystalComment
    hi def link crystalCommentSpace crystalComment
    hi def link crystalMarkdownDirective SpecialComment

    " Markdown <<<3
    " Inline syntax
    syn cluster crystalMarkdownInline contains=
          \ crystalMarkdownBold,crystalMarkdownItalic,crystalMarkdownBoldItalic,crystalMarkdownCode,crystalMarkdownEscape,
          \ crystalMarkdownLink,crystalMarkdownImage,crystalMarkdownRawLink

    syn region crystalMarkdownItalic matchgroup=crystalMarkdownItalicDelimiter start=/\%#=1\*/ end=/\%#=1\*/ concealends contained contains=crystalMarkdownCode,crystalMarkdownEscape,crystalMarkdownRawLink oneline
    syn region crystalMarkdownBold matchgroup=crystalMarkdownBoldDelimiter start=/\%#=1\*\*/ end=/\%#=1\*\*/ concealends contained contains=crystalMarkdownCode,crystalMarkdownEscape,crystalMarkdownRawLink oneline
    syn region crystalMarkdownBoldItalic matchgroup=crystalMarkdownBoldItalicDelimiter start=/\%#=1\*\*\*/ end=/\%#=1\*\*\*/ concealends contained contains=crystalMarkdownCode,crystalMarkdownEscape,crystalMarkdownRawLink oneline

    syn region crystalMarkdownItalic matchgroup=crystalMarkdownItalicDelimiter start=/\%#=1\<_/ end=/\%#=1_\>/ concealends contained contains=crystalMarkdownCode,crystalMarkdownEscape,crystalMarkdownRawLink oneline
    syn region crystalMarkdownBold matchgroup=crystalMarkdownBoldDelimiter start=/\%#=1\<__/ end=/\%#=1__\>/ concealends contained contains=crystalMarkdownCode,crystalMarkdownEscape,crystalMarkdownRawLink oneline
    syn region crystalMarkdownBoldItalic matchgroup=crystalMarkdownBoldItalicDelimiter start=/\%#=1\<___/ end=/\%#=1___\>/ concealends contained contains=crystalMarkdownCode,crystalMarkdownEscape,crystalMarkdownRawLink oneline

    if s:crystal_markdown_comments == 2
      syn region crystalMarkdownCode matchgroup=crystalMarkdownCodeDelimiter start=/\%#=1`/ end=/\%#=1`/ skip=/\%#=1\s`\{2,}\s/ concealends contained oneline contains=@crystalRHS,crystalMarkdownInstanceMethodStart
      syn region crystalMarkdownCode matchgroup=crystalMarkdownCodeDelimiter start=/\%#=1``/ end=/\%#=1``/ skip=/\%#=1\s`\{3,}\s/ concealends contained oneline contains=@crystalRHS,crystalMarkdownInstanceMethodStart
      syn region crystalMarkdownCode matchgroup=crystalMarkdownCodeDelimiter start=/\%#=1```/ end=/\%#=1```/ skip=/\%#=1\s`\{4,}\s/ concealends contained oneline contains=@crystalRHS,crystalMarkdownInstanceMethodStart

      syn match crystalMarkdownInstanceMethodStart /\%#=1#/ contained nextgroup=crystalVariableOrMethod,crystalOperatorMethod

      hi def link crystalMarkdownInstanceMethodStart crystalMethodOperator
    else
      syn region crystalMarkdownCode matchgroup=crystalMarkdownCodeDelimiter start=/\%#=1`/ end=/\%#=1`/ skip=/\%#=1\s`\{2,}\s/ concealends contained oneline
      syn region crystalMarkdownCode matchgroup=crystalMarkdownCodeDelimiter start=/\%#=1``/ end=/\%#=1``/ skip=/\%#=1\s`\{3,}\s/ concealends contained oneline
      syn region crystalMarkdownCode matchgroup=crystalMarkdownCodeDelimiter start=/\%#=1```/ end=/\%#=1```/ skip=/\%#=1\s`\{4,}\s/ concealends contained oneline
    endif

    syn match crystalMarkdownEscape /\%#=1\\\\/ conceal cchar=\ contained
    syn match crystalMarkdownEscape /\%#=1\\\*/ conceal cchar=* contained
    syn match crystalMarkdownEscape /\%#=1\\_/ conceal cchar=_ contained
    syn match crystalMarkdownEscape /\%#=1\\`/ conceal cchar=` contained
    syn match crystalMarkdownEscape /\%#=1\\\[/ conceal cchar=[ contained
    syn match crystalMarkdownEscape /\%#=1\\]/ conceal cchar=] contained
    syn match crystalMarkdownEscape /\%#=1\\(/ conceal cchar=( contained
    syn match crystalMarkdownEscape /\%#=1\\)/ conceal cchar=) contained
    syn match crystalMarkdownEscape /\%#=1\\{/ conceal cchar={ contained
    syn match crystalMarkdownEscape /\%#=1\\}/ conceal cchar=} contained
    syn match crystalMarkdownEscape /\%#=1\\!/ conceal cchar=! contained
    syn match crystalMarkdownEscape /\%#=1\\ / conceal cchar=· contained
    syn match crystalMarkdownEscape /\%#=1\\\~/ conceal cchar=~ contained
    syn match crystalMarkdownEscape /\%#=1\\-/ conceal cchar=- contained
    syn match crystalMarkdownEscape /\%#=1\\>/ conceal cchar=> contained
    syn match crystalMarkdownEscape /\%#=1\\\./ conceal cchar=. contained

    syn region crystalMarkdownLink matchgroup=crystalMarkdownDelimiter start=/\%#=1\[/ end=/\%#=1]/ concealends contained oneline contains=@crystalMarkdownInline nextgroup=crystalMarkdownURL,crystalMarkdownReference
    syn region crystalMarkdownURL matchgroup=crystalMarkdownDelimiter start=/\%#=1(/ end=/\%#=1)/ conceal contained oneline
    syn region crystalMarkdownReference matchgroup=crystalMarkdownDelimiter start=/\%#=1\[/ end=/\%#=1]/ concealends contained oneline

    syn match crystalMarkdownImage /\%#=1!/ contained nextgroup=crystalMarkdownLink conceal

    syn region crystalMarkdownRawLink matchgroup=crystalMarkdownDelimiter start=/\%#=1<\ze\S.\{-}\%(:\/\/\|@\)/ end=/\%#=1>/ contained oneline concealends

    " Line-based syntax
    syn cluster crystalMarkdownLine contains=
        \ crystalMarkdownAdmonition,crystalMarkdownCodeBlock,crystalMarkdownHeading,crystalMarkdownOrderedListItem,
        \ crystalMarkdownUnorderedListItem,crystalMarkdownHorizontalRule,crystalMarkdownBlockQuote,
        \ crystalMarkdownReferenceDefinition

    syn match crystalMarkdownAdmonition /\%#=1\%(BUG\|DEPRECATED\|WARNING\|EXPERIMENTAL\|FIXME\|NOTE\|OPTIMIZE\|TODO\):\=/ contained nextgroup=crystalComment

    syn region crystalMarkdownCodeBlock matchgroup=crystalMarkdownCodeDelimiter start=/\%#=1```.*/ end=/\%#=1^\s*#\s*\zs```/ concealends contained contains=crystalMarkdownCodeLineStart keepend
    syn region crystalMarkdownCodeBlock matchgroup=crystalMarkdownCodeDelimiter start=/\%#=1\~\~\~.*/ end=/\%#=1^\s*#\s*\zs\~\~\~/ concealends contained contains=crystalMarkdownCodeLineStart keepend

    syn match crystalMarkdownCodeLineStart /\%#=1#/ contained nextgroup=crystalMarkdownCodeLine
    syn match crystalMarkdownCodeLine /\%#=1.*/ contained

    if s:crystal_markdown_comments == 2
      syn region crystalMarkdownCodeBlock matchgroup=crystalMarkdownCodeDelimiter start=/\%#=1```\%(\s*crystal\)\=\s*$/ end=/\%#=1^\s*#\s*\zs```/ concealends contained contains=crystalMarkdownCrystalCodeLineStart keepend
      syn region crystalMarkdownCodeBlock matchgroup=crystalMarkdownCodeDelimiter start=/\%#=1\~\~\~\%(\s*crystal\)\=\s*$/ end=/\%#=1^\s*#\s*\zs\~\~\~/ concealends contained contains=crystalMarkdownCrystalCodeLineStart keepend

      syn match crystalMarkdownCrystalCodeLineStart /\%#=1#/ contained nextgroup=crystalMarkdownCrystalCodeLine
      syn match crystalMarkdownCrystalCodeLine /\%#=1.*/ contained contains=TOP

      hi def link crystalMarkdownCrystalCodeLineStart crystalCommentStart
    endif

    syn match crystalMarkdownHeading /\%#=1#\{1,6}\%(\s.*\)\=/ contained contains=@crystalMarkdownInline

    syn match crystalMarkdownOrderedListItem /\%#=1\d\+\.\s\@=/ contained nextgroup=crystalComment
    syn match crystalMarkdownUnorderedListItem /\%#=1[*+-]\s\@=/ contained nextgroup=crystalComment

    syn match crystalMarkdownHorizontalRule /\%#=1\*\%(\s*\*\)\{2,}$/ contained
    syn match crystalMarkdownHorizontalRule /\%#=1-\%(\s*-\)\{2,}$/ contained
    syn match crystalMarkdownHorizontalRule /\%#=1_\{3,}$/ contained

    syn match crystalMarkdownBlockQuote /\%#=1>/ contained nextgroup=@crystalMarkdownLine,crystalComment skipwhite

    syn region crystalMarkdownReferenceDefinition matchgroup=crystalMarkdownDelimiter start=/\%#=1\[/ end=/\%#=1]:/ contained oneline nextgroup=crystalMarkdownReferenceURL skipwhite
    syn match crystalMarkdownReferenceURL /\%#=1\S\+/ contained nextgroup=crystalMarkdownReferenceTitle skipwhite
    syn match crystalMarkdownReferenceURL /\%#=1<\S\+>/ contained nextgroup=crystalMarkdownReferenceTitle skipwhite
    syn region crystalMarkdownReferenceTitle matchgroup=crystalMarkdownReferenceTitleDelimiter start=/\%#=1"/ end=/\%#=1"/ contained oneline
    syn region crystalMarkdownReferenceTitle matchgroup=crystalMarkdownReferenceTitleDelimiter start=/\%#=1'/ end=/\%#=1'/ contained oneline
    syn region crystalMarkdownReferenceTitle matchgroup=crystalMarkdownReferenceTitleDelimiter start=/\%#=1(/ end=/\%#=1)/ contained oneline

    " Highlighting
    hi def link crystalMarkdownDelimiter Delimiter
    hi crystalMarkdownItalic cterm=italic gui=italic
    hi crystalMarkdownBold cterm=bold gui=bold
    hi crystalMarkdownBoldItalic cterm=bold,italic gui=bold,italic
    hi def link crystalMarkdownItalicDelimiter crystalMarkdownDelimiter
    hi def link crystalMarkdownBoldDelimiter crystalMarkdownDelimiter
    hi def link crystalMarkdownBoldItalicDelimiter crystalMarkdownDelimiter
    hi def link crystalMarkdownCode String
    hi def link crystalMarkdownCodeDelimiter crystalMarkdownDelimiter
    hi def link crystalMarkdownCodeLineStart crystalCommentStart
    hi def link crystalMarkdownCodeLine crystalMarkdownCode
    hi def link crystalMarkdownEscape SpecialChar
    hi crystalMarkdownLink cterm=underline gui=underline
    hi def link crystalMarkdownURL String
    hi def link crystalMarkdownReference Special
    hi def link crystalMarkdownRawLink crystalMarkdownLink
    hi def link crystalMarkdownImage Special
    hi def link crystalMarkdownAdmonition Todo
    hi def link crystalMarkdownHeading Title
    hi def link crystalMarkdownOrderedListItem crystalMarkdownDelimiter
    hi def link crystalMarkdownUnorderedListItem crystalMarkdownDelimiter
    hi def link crystalMarkdownHorizontalRule crystalMarkdownDelimiter
    hi def link crystalMarkdownBlockQuote crystalMarkdownDelimiter
    hi def link crystalMarkdownReferenceDefinition Special
    hi def link crystalMarkdownReferenceURL crystalMarkdownURL
    hi def link crystalMarkdownReferenceTitle String
    hi def link crystalMarkdownReferenceTitleDelimiter crystalMarkdownDelimiter
    " >>>
  else
    syn match crystalComment /\%#=1#.*/
  endif

  syn match crystalPragmaError /\%#=1#<loc:.*/
  syn match crystalPragma /\%#=1#<loc:\%(push\|pop\|".\{-}"\)>/

  hi def link crystalPragmaError Error
  hi def link crystalPragma PreProc
endif

" Operators <<<2
syn cluster crystalRHS contains=
      \ crystalNumber,crystalString,crystalStringArray,crystalCharacter,
      \ crystalSymbol,crystalSymbolArray,crystalRegex,crystalCommand,crystalHeredoc,crystalHeredocSkip,
      \ crystalNil,crystalBoolean,crystalSelf,crystalKeyword,crystalBlock,
      \ crystalVariableOrMethod,crystalConstant,crystalFreshVariable,crystalInstanceVariable,crystalExternalVariable

syn match crystalUnaryOperator /\%#=1[+*!~]/ nextgroup=@crystalRHS skipwhite skipempty
syn match crystalUnaryOperator /\%#=1&/ nextgroup=@crystalRHS,crystalTypeRestrictionOperator skipwhite
syn match crystalUnaryOperator /\%#=1->\=/

syn match crystalOperator /\%#=1=\%(==\=\|[>~]\)\=/ contained nextgroup=@crystalRHS skipwhite skipempty
syn match crystalOperator /\%#=1![=~]/ contained nextgroup=@crystalRHS skipwhite skipempty
syn match crystalOperator /\%#=1<\%(<=\=\|=>\=\)\=/ contained nextgroup=@crystalRHS skipwhite skipempty
syn match crystalOperator /\%#=1>>\==\=/ contained nextgroup=@crystalRHS skipwhite skipempty
syn match crystalOperator /\%#=1+=\=/ contained nextgroup=@crystalRHS skipwhite skipempty
syn match crystalOperator /\%#=1-[=>]\=/ contained nextgroup=@crystalRHS skipwhite skipempty
syn match crystalOperator /\%#=1\*\*\==\=/ contained nextgroup=@crystalRHS skipwhite skipempty
syn match crystalOperator /\%#=1\// contained nextgroup=@crystalRHS skipwhite skipempty
" NOTE: Additional division operators are defined after /-style regexes
" in order to take precedence
syn match crystalOperator /\%#=1%=\=/ contained nextgroup=@crystalRHS skipwhite skipempty
syn match crystalOperator /\%#=1&\%(&=\=\|=\|+=\=\|-[=>]\=\|\*[*=]\=\)\=/ contained nextgroup=@crystalRHS skipwhite skipempty
syn match crystalOperator /\%#=1||\==\=/ contained nextgroup=@crystalRHS skipwhite skipempty
syn match crystalOperator /\%#=1\^=\=/ contained nextgroup=@crystalRHS skipwhite skipempty

syn region crystalTernaryOperator matchgroup=crystalOperator start=/\%#=1?/ end=/\%#=1\s\@1<=:/ skip=/\%#=1:\S/ oneline contained contains=TOP nextgroup=@crystalRHS skipwhite skipempty

syn match crystalMethodOperator /\%#=1\./ nextgroup=crystalVariableOrMethod,crystalOperatorMethod,crystalPseudoMethod skipwhite
syn match crystalOperatorMethod /\%#=1\%([+\-|^~%]\|\*\*\=\|\/\/\=\|=\%(==\=\|\~\)\|![=~]\=\|<\%(=>\=\|<\)\=\|>[>=]\=\|&\%([+-]\|\*\*\=\)\=\|\[][=?]\=\)/ contained nextgroup=@crystalPostfix,@crystalRHS,crystalNamedTupleKey skipwhite

syn match crystalRangeOperator /\%#=1\.\.\.\=/ nextgroup=crystalOperator,crystalPostfixKeyword,@crystalRHS skipwhite skipempty

syn match crystalTypeRestrictionOperator /\%#=1:/ contained nextgroup=@crystalTypes skipwhite skipempty

syn match crystalModuleOperator /\%#=1::/ nextgroup=crystalConstant,crystalVariableOrMethod

" Type grammar <<<2
syn cluster crystalTypes contains=crystalType,crystalTypeModuleOperator,crystalTypeTuple,crystalTypeProcOperator,crystalTypeGroup,crystalTypeSelf,crystalTypeNil,crystalTypeTypeof,crystalTypeSplat
syn cluster crystalTypesPostfix contains=crystalTypeModifier,crystalTypeComma,crystalTypeUnionOperator,crystalTypeProcOperator,crystalTypeHashOperator,crystalTypeArray,crystalAssignmentOperator

syn match crystalType /\%#=1\u[^\x00-\x2F\x3A-\x40\x5B-\x5E`\x7B-\x9F]*/ contained nextgroup=@crystalTypesPostfix,crystalTypeModuleOperator,crystalTypeGeneric skipwhite
syn match crystalType /\%#=1_\>/ contained nextgroup=@crystalTypesPostfix,crystalTypeModuleOperator,crystalTypeGeneric skipwhite

syn match crystalTypeModuleOperator /\%#=1::/ contained nextgroup=crystalType skipwhite skipempty

syn region crystalTypeTuple matchgroup=crystalDelimiter start=/\%#=1{/ end=/\%#=1}/ contained contains=@crystalTypes,crystalTypeTupleKey nextgroup=@crystalTypesPostfix,crystalTypeModuleOperator skipwhite
syn region crystalTypeGeneric matchgroup=crystalDelimiter start=/\%#=1(/ end=/\%#=1)/ contained contains=@crystalTypes,crystalNumber,crystalTypeTupleKey nextgroup=@crystalTypesPostfix skipwhite

syn match crystalTypeTupleKey /\%#=1\u[^\x00-\x2F\x3A-\x40\x5B-\x5E`\x7B-\x9F]*\ze::\@!/ contained nextgroup=crystalTypeRestrictionOperator skipwhite
syn match crystalTypeTupleKey /\%#=1[^\x00-\x5E`\x7B-\x9F][^\x00-\x2F\x3A-\x40\x5B-\x5E`\x7B-\x9F]*[?!]\=:\@=/ contained nextgroup=crystalTypeRestrictionOperator skipwhite

syn match crystalTypeModifier /\%#=1[?*]\+/ contained nextgroup=@crystalTypesPostfix skipwhite
syn match crystalTypeModifier /\%#=1\./ contained nextgroup=crystalTypeModifierClass skipwhite skipempty
syn keyword crystalTypeModifierClass class contained nextgroup=@crystalTypesPostfix skipwhite
syn region crystalTypeArray matchgroup=crystalDelimiter start=/\%#=1\[/ end=/\%#=1\]/ contained contains=crystalNumber,crystalConstant nextgroup=@crystalTypesPostfix skipwhite

syn match crystalAssignmentOperator /\%#=1=/ contained nextgroup=@crystalRHS skipwhite skipempty

syn match crystalTypeUnionOperator /\%#=1|/ contained nextgroup=@crystalTypes skipwhite skipempty
syn match crystalTypeProcOperator /\%#=1->/ contained nextgroup=@crystalTypes skipwhite skipempty
syn match crystalTypeHashOperator /\%#=1=>/ contained nextgroup=@crystalTypes skipwhite skipempty

syn match crystalTypeComma /\%#=1,/ contained nextgroup=@crystalTypes,crystalTypeTupleKey skipwhite skipempty

syn region crystalTypeGroup matchgroup=crystalDelimiter start=/\%#=1(/ end=/\%#=1)/ contained contains=@crystalTypes nextgroup=@crystalTypesPostfix skipwhite

syn keyword crystalTypeSelf self contained nextgroup=@crystalTypesPostfix skipwhite
syn keyword crystalTypeNil nil contained nextgroup=@crystalTypesPostfix skipwhite

syn keyword crystalTypeTypeof typeof contained nextgroup=crystalTypeTypeofInvocation skipwhite skipempty
syn region crystalTypeTypeofInvocation matchgroup=crystalDelimiter start=/\%#=1(/ end=/\%#=1)/ contained contains=TOP nextgroup=@crystalTypesPostfix skipwhite

syn match crystalTypeSplat /\%#=1\*/ contained nextgroup=@crystalTypes skipwhite

" Delimiters <<<2
syn match crystalDelimiter /\%#=1(/ nextgroup=@crystalRHS,crystalNamedTupleKey,crystalOut skipwhite skipempty
syn match crystalDelimiter /\%#=1)/ nextgroup=@crystalPostfix skipwhite

syn match crystalDelimiter /\%#=1\[/ nextgroup=@crystalRHS skipwhite skipempty
syn match crystalDelimiter /\%#=1]?\=/ nextgroup=@crystalPostfix,crystalOf skipwhite
syn keyword crystalOf of contained nextgroup=@crystalTypes skipwhite skipempty

syn match crystalDelimiter /\%#=1{/ nextgroup=crystalBlockParameters,@crystalRHS,crystalNamedTupleKey skipwhite skipempty
syn match crystalDelimiter /\%#=1}/ nextgroup=@crystalPostfix,crystalOf skipwhite

syn match crystalComma /\%#=1,/ contained containedin=crystalMethodParameters,crystalBlockParameters
syn match crystalComma /\%#=1,/ contained nextgroup=@crystalRHS,crystalNamedTupleKey,crystalOut skipwhite skipempty
syn match crystalBackslash /\%#=1\\/
syn match crystalSemicolon /\%#=1;/

" Identifiers <<<2
syn match crystalInstanceVariable /\%#=1@@\=\%([^\x00-\x40\x5B-\x5E`\x7B-\x9F]\|\\\={{.\{-}}}\)\%([^\x00-\x2F\x3A-\x40\x5B-\x5E`\x7B-\x9F]\+\|\\\={{.\{-}}}\)*/ nextgroup=@crystalPostfix,crystalTypeRestrictionOperator skipwhite
syn match crystalFreshVariable /\%#=1%[^\x00-\x40\x5B-\x5E`\x7B-\x9F][^\x00-\x2F\x3A-\x40\x5B-\x5E`\x7B-\x9F]*/ nextgroup=@crystalPostfix,crystalTypeRestrictionOperator skipwhite
syn match crystalExternalVariable /\%#=1\$\%(\%([^\x00-\x40\x5B-\x5E`\x7B-\x9F]\|\\\={{.\{-}}}\)\%([^\x00-\x2F\x3A-\x40\x5B-\x5E`\x7B-\x9F]\+\|\\\={{.\{-}}}\)*\|\d\+?\=\|[~?]\)/ nextgroup=@crystalPostfix,crystalTypeRestrictionOperator skipwhite
syn match crystalConstant /\%#=1\u[^\x00-\x2F\x3A-\x40\x5B-\x5E`\x7B-\x9F]*\ze\%(::\|\>\)/ nextgroup=@crystalPostfix,crystalModuleOperator skipwhite
syn match crystalVariableOrMethod /\%#=1[^\x00-\x5E`\x7B-\x9F][^\x00-\x2F\x3A-\x40\x5B-\x5E`\x7B-\x9F]*[?!]\=:\@!\>/ nextgroup=@crystalPostfix,@crystalRHS,crystalNamedTupleKey,crystalTypeRestrictionOperator skipwhite

syn keyword crystalPseudoMethod is_a? as contained nextgroup=@crystalTypes,crystalTypeInvocation skipwhite
syn keyword crystalPseudoMethod sizeof instance_sizeof nextgroup=@crystalTypes,crystalTypeInvocation skipwhite containedin=crystalTypeArray
syn region crystalTypeInvocation matchgroup=crystalDelimiter start=/\%#=1(/ end=/\%#=1)/ contained contains=@crystalTypes nextgroup=@crystalPostfix skipwhite

" Literals <<<2
" Keywords <<<3
syn keyword crystalNil nil nextgroup=@crystalPostfix skipwhite
syn keyword crystalBoolean true false nextgroup=@crystalPostfix skipwhite
syn keyword crystalSelf self nextgroup=@crystalPostfix skipwhite
syn keyword crystalSuper super nextgroup=@crystalPostfix,@crystalRHS,crystalNamedTupleKey skipwhite

" Numbers <<<3
syn match crystalNumber /\%#=1[1-9]\d*\%(_\d\+\)*\%([ui]\%(8\|16\|32\|64\|128\)\|f\%(32\|64\)\|[eE][+-]\=\d\+\%(_\d\+\)*\%(_\=f\%(32\|64\)\)\=\|_\%([ui]\%(8\|16\|32\|64\|128\)\|f\%(32\|64\)\|[eE][+-]\=\d\+\%(_\d\+\)*\%(_\=f\%(32\|64\)\)\=\)\|\.\d\+\%(_\d\+\)*\%(f\%(32\|64\)\|[eE][+-]\=\d\+\%(_\d\+\)*\%(_\=f\%(32\|64\)\)\=\|_\%(f\%(32\|64\)\|[eE][+-]\=\d\+\%(_\d\+\)*\%(_\=f\%(32\|64\)\)\=\)\)\=\)\=\>/ nextgroup=@crystalPostfix skipwhite
syn match crystalNumber /\%#=10\%([ui]\%(8\|16\|32\|64\|128\)\|f\%(32\|64\)\|_\%([ui]\%(8\|16\|32\|64\|128\)\|f\%(32\|64\)\|[eE][+-]\=\d\+\%(_\d\+\)*\%(_\=f\%(32\|64\)\)\=\)\|\.\d\+\%(_\d\+\)*\%(f\%(32\|64\)\|[eE][+-]\=\d\+\%(_\d\+\)*\%(_\=f\%(32\|64\)\)\=\|_\%(f\%(32\|64\)\|[eE][+-]\=\d\+\%(_\d\+\)*\%(_\=f\%(32\|64\)\)\=\)\)\=\>\|b[01]\+\%(_[01]\+\)*\%(_\=[ui]\%(8\|16\|32\|64\|128\)\)\=\|o\o\+\%(_\o\+\)*\%(_\=[ui]\%(8\|16\|32\|64\|128\)\)\=\|x\x\+\%(_\x\+\)*\%(_\=[ui]\%(8\|16\|32\|64\|128\)\)\=\)\=/ nextgroup=@crystalPostfix skipwhite

" Characters <<<3
syn region crystalCharacter matchgroup=crystalCharacterDelimiter start=/\%#=1'/ end=/\%#=1'/ contains=crystalCharacterEscape,crystalCharacterEscapeError nextgroup=@crystalPostfix skipwhite

syn match crystalCharacterEscapeError /\%#=1\\./ contained
syn match crystalCharacterEscape /\%#=1\\\%(u\%(\x\{4}\|{\x\{1,6}}\)\|['\\abefnrtv0]\)/ contained

" Strings <<<3
syn region crystalString matchgroup=crystalStringStart start=/\%#=1"/ matchgroup=crystalStringEnd end=/\%#=1"/ contains=crystalStringInterpolation,crystalStringEscape,crystalStringEscapeError nextgroup=@crystalPostfix,crystalNamedTupleKeyDelimiter skipwhite

syn region crystalString matchgroup=crystalStringStart start=/\%#=1%Q\=(/ matchgroup=crystalStringEnd end=/\%#=1)/ contains=crystalStringParentheses,crystalStringInterpolation,crystalStringEscape,crystalStringEscapeError nextgroup=@crystalPostfix,crystalNamedTupleKeyDelimiter skipwhite
syn region crystalStringParentheses matchgroup=crystalString start=/\%#=1(/ end=/\%#=1)/ transparent contained

syn region crystalString matchgroup=crystalStringStart start=/\%#=1%Q\=\[/ matchgroup=crystalStringEnd end=/\%#=1]/ contains=crystalStringSquareBrackets,crystalStringInterpolation,crystalStringEscape,crystalStringEscapeError nextgroup=@crystalPostfix,crystalNamedTupleKeyDelimiter skipwhite
syn region crystalStringSquareBrackets matchgroup=crystalString start=/\%#=1\[/ end=/\%#=1]/ transparent contained

syn region crystalString matchgroup=crystalStringStart start=/\%#=1%Q\={/ matchgroup=crystalStringEnd end=/\%#=1}/ contains=crystalStringCurlyBraces,crystalStringInterpolation,crystalStringEscape,crystalStringEscapeError nextgroup=@crystalPostfix,crystalNamedTupleKeyDelimiter skipwhite
syn region crystalStringCurlyBraces matchgroup=crystalString start=/\%#=1{/ end=/\%#=1}/ transparent contained

syn region crystalString matchgroup=crystalStringStart start=/\%#=1%Q\=</ matchgroup=crystalStringEnd end=/\%#=1>/ contains=crystalStringAngleBrackets,crystalStringInterpolation,crystalStringEscape,crystalStringEscapeError nextgroup=@crystalPostfix,crystalNamedTupleKeyDelimiter skipwhite
syn region crystalStringAngleBrackets matchgroup=crystalString start=/\%#=1</ end=/\%#=1>/ transparent contained

syn region crystalString matchgroup=crystalStringStart start=/\%#=1%Q\=|/ matchgroup=crystalStringEnd end=/\%#=1|/ contains=crystalStringInterpolation,crystalStringEscape,crystalStringEscapeError nextgroup=@crystalPostfix,crystalNamedTupleKeyDelimiter skipwhite

syn region crystalStringInterpolation matchgroup=crystalStringInterpolationDelimiter start=/\%#=1#{/ end=/\%#=1}/ contained contains=@crystalTop,crystalNestedBraces

syn match crystalStringEscape /\%#=1\\\_./ contained
syn match crystalStringEscapeError /\%#=1\\\%(x\x\=\|u\x\{,3}\)/ contained
syn match crystalStringEscape /\%#=1\\\%(\o\{1,3}\|x\x\x\|u\%(\x\{4}\|{\x\{1,6}\%(\s\x\{1,6}\)*}\)\)/ contained
syn match crystalStringEscapeError /\%#=1\\\o\{4,}/ contained

syn region crystalString matchgroup=crystalStringStart start=/\%#=1%q(/  matchgroup=crystalStringEnd end=/\%#=1)/ contains=crystalStringParentheses  nextgroup=@crystalPostfix,crystalNamedTupleKeyDelimiter skipwhite
syn region crystalString matchgroup=crystalStringStart start=/\%#=1%q\[/ matchgroup=crystalStringEnd end=/\%#=1]/ contains=crystalStringSquareBrackets nextgroup=@crystalPostfix,crystalNamedTupleKeyDelimiter skipwhite
syn region crystalString matchgroup=crystalStringStart start=/\%#=1%q{/  matchgroup=crystalStringEnd end=/\%#=1}/ contains=crystalStringCurlyBraces  nextgroup=@crystalPostfix,crystalNamedTupleKeyDelimiter skipwhite
syn region crystalString matchgroup=crystalStringStart start=/\%#=1%q</  matchgroup=crystalStringEnd end=/\%#=1>/ contains=crystalStringAngleBrackets  nextgroup=@crystalPostfix,crystalNamedTupleKeyDelimiter skipwhite
syn region crystalString matchgroup=crystalStringStart start=/\%#=1%q|/  matchgroup=crystalStringEnd end=/\%#=1|/ nextgroup=@crystalPostfix,crystalNamedTupleKeyDelimiter skipwhite

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

" Here Documents <<<3
syn region crystalHeredoc matchgroup=crystalHeredocStart start=/\%#=1<<-\z([^\x00-\x2F\x3A-\x40\x5B-\x5E`\x7B-\x9F]\+\)/ matchgroup=crystalHeredocEnd end=/\%#=1^\s*\z1$/ contains=crystalHeredocStartLine,crystalHeredocLine
syn match crystalHeredocStartLine /\%#=1.*/ contained contains=TOP nextgroup=crystalHeredocLine skipempty
syn match crystalHeredocLine /\%#=1^.*/ contained contains=crystalStringInterpolation,crystalStringEscape,crystalStringEscapeError nextgroup=crystalHeredocLine skipempty

syn region crystalHeredoc matchgroup=crystalHeredocStart start=/\%#=1<<-'\z([^\x00-\x2F\x3A-\x40\x5B-\x5E`\x7B-\x9F].\{-}\)'/ matchgroup=crystalHeredocEnd end=/\%#=1^\s*\z1$/ contains=crystalHeredocStartLineRaw,crystalHeredocLineRaw
syn match crystalHeredocStartLineRaw /\%#=1.*/ contained contains=TOP nextgroup=crystalHeredocLineRaw skipempty
syn match crystalHeredocLineRaw /\%#=1^.*/ contained nextgroup=crystalHeredocLineRaw skipempty

syn region crystalHeredocSkip matchgroup=crystalHeredocStart start=/\%#=1<<-\%([^\x00-\x2F\x3A-\x40\x5B-\x5E`\x7B-\x9F]\+\|'[^\x00-\x2F\x3A-\x40\x5B-\x5E`\x7B-\x9F].\{-}'\)/ end=/\%#=1\ze<<-/ contains=@crystalPostfix,@crystalRHS oneline nextgroup=crystalHeredoc,crystalHeredocSkip

" Symbols <<<3
syn match crystalSymbol /\%#=1:\%([^\x00-\x40\x5B-\x5E`\x7B-\x9F][^\x00-\x2F\x3A-\x40\x5B-\x5E`\x7B-\x9F]*[?!=]\=\|\%([+\-|^~%]\|\*\*\=\|\/\/\=\|=\%(==\=\|\~\)\|![=~]\=\|<\%(=>\=\|<\)\=\|>[>=]\=\|&\%([+-]\|\*\*\=\)\=\|\[][=?]\=\)\)/ contains=crystalSymbolStart nextgroup=@crystalPostfix skipwhite

syn match crystalSymbolStart /\%#=1:/ contained

syn region crystalSymbol matchgroup=crystalSymbolStart start=/\%#=1:"/ matchgroup=crystalSymbolEnd end=/\%#=1"/ contains=crystalStringInterpolation,crystalStringEscape,crystalStringEscapeError nextgroup=@crystalPostfix skipwhite

syn region crystalSymbolArray matchgroup=crystalSymbolArrayDelimiter start=/\%#=1%i(/  end=/\%#=1)/ contains=crystalStringParentheses,crystalStringParenthesisEscape nextgroup=@crystalPostfix skipwhite
syn region crystalSymbolArray matchgroup=crystalSymbolArrayDelimiter start=/\%#=1%i\[/ end=/\%#=1]/ contains=crystalStringSquareBrackets,crystalStringSquareBracketEscape nextgroup=@crystalPostfix skipwhite
syn region crystalSymbolArray matchgroup=crystalSymbolArrayDelimiter start=/\%#=1%i{/  end=/\%#=1}/ contains=crystalStringCurlyBraces,crystalStringCurlyBraceEscape nextgroup=@crystalPostfix skipwhite
syn region crystalSymbolArray matchgroup=crystalSymbolArrayDelimiter start=/\%#=1%i</  end=/\%#=1>/ contains=crystalStringAngleBrackets,crystalStringAngleBracketEscape nextgroup=@crystalPostfix skipwhite
syn region crystalSymbolArray matchgroup=crystalSymbolArrayDelimiter start=/\%#=1%i|/  end=/\%#=1|/ contains=crystalStringPipeEscape nextgroup=@crystalPostfix skipwhite

" Regular Expressions <<<3
syn region crystalRegex matchgroup=crystalRegexStart start=/\%#=1\/\s\@!/ matchgroup=crystalRegexEnd end=/\%#=1\/[imx]*/ skip=/\%#=1\\\\\|\\\// oneline keepend contains=crystalStringInterpolation,@crystalPCRE nextgroup=@crystalPostfix skipwhite

" NOTE: These operators are defined here in order to take precedence
" over /-style regexes
syn match crystalOperator /\%#=1\/[/=]/ contained nextgroup=@crystalRHS skipwhite skipempty

syn region crystalRegex matchgroup=crystalRegexStart start=/\%#=1%r(/  matchgroup=crystalRegexEnd end=/\%#=1)[imx]*/ contains=crystalStringInterpolation,@crystalPCRE nextgroup=@crystalPostfix skipwhite
syn region crystalRegex matchgroup=crystalRegexStart start=/\%#=1%r\[/ matchgroup=crystalRegexEnd end=/\%#=1][imx]*/ contains=crystalStringInterpolation,@crystalPCRE nextgroup=@crystalPostfix skipwhite
syn region crystalRegex matchgroup=crystalRegexStart start=/\%#=1%r{/  matchgroup=crystalRegexEnd end=/\%#=1}[imx]*/ skip=/\%#=1{.\{-}}/ contains=crystalStringInterpolation,@crystalPCRE nextgroup=@crystalPostfix skipwhite
syn region crystalRegex matchgroup=crystalRegexStart start=/\%#=1%r</  matchgroup=crystalRegexEnd end=/\%#=1>[imx]*/ skip=/\%#=1<.\{-}>/ contains=crystalStringInterpolation,@crystalPCRE nextgroup=@crystalPostfix skipwhite
syn region crystalRegex matchgroup=crystalRegexStart start=/\%#=1%r|/  matchgroup=crystalRegexEnd end=/\%#=1|[imx]*/ contains=crystalStringInterpolation,@crystalPCRE nextgroup=@crystalPostfix skipwhite

" PCRE <<<4
syn cluster crystalPCRE contains=
      \ crystalPCREEscape,crystalPCRELiteral,crystalPCREMetaCharacter,crystalPCREClass,crystalPCREQuantifier,
      \ crystalPCREGroup,crystalPCREComment,crystalPCREControl

syn match crystalPCREEscape /\%#=1\\\%(c.\|\d\+\|o{\o\+}\|x\%(\x\x\|{\x\+}\)\|[pP]{\h\w*}\|g\%(\d\+\|{\%(-\=\d\+\|\h\w*\)}\|<\%(-\=\d\+\|\h\w*\)>\|'\%(-\=\d\+\|\h\w*\)'\)\|k\%(<\h\w*>\|'\h\w*'\|{\h\w*}\)\|.\)/ contained
syn region crystalPCREGroup matchgroup=crystalPCREMetaCharacter start=/\%#=1(\%(?\%(<\h\w*>\|'\h\w*'\|P\%(<\h\w*>\|[>=]\h\w*\)\|[:|>=!]\|-\=[iJmsUx]\+:\=\|<[=!]\|R\|[+-]\=\d\+\|&\h\w*\|(\%([+-]\=\d\+\|<\h\w*>\|'\h\w*'\|R\%(\d\+\|&\h\w*\)\|\h\w*\))\|C\d*\)\)\=/ end=/\%#=1)/ contained transparent

syn region crystalPCRELiteral matchgroup=crystalPCREEscape start=/\%#=1\\Q/ end=/\%#=1\\E/ contained transparent contains=crystalRegexSlashEscape

syn match crystalPCREMetaCharacter /\%#=1[.^$|]/ contained

syn region crystalPCREClass matchgroup=crystalPCREMetaCharacter start=/\%#=1\[\^\=/ end=/\%#=1\]/ contained transparent contains=crystalPCREEscape,crystalPCREPOSIXClass
syn match crystalPCREPOSIXClass /\%#=1\[:\^\=\l\+:\]/ contained

syn match crystalPCREQuantifier /\%#=1[?*+][+?]\=/ contained
syn match crystalPCREQuantifier /\%#=1{\d\+,\=\d*}[+?]\=/ contained

syn region crystalPCREComment matchgroup=crystalPCREMetaCharacter start=/\%#=1(?#/ end=/\%#=1)/ contained contains=crystalRegexSlashEscape

syn match crystalPCREControl /\%#=1(\*.\{-})/ contained

syn match crystalRegexSlashEscape /\%#=1\\\// contained

" Commands <<<3
syn region crystalCommand matchgroup=crystalCommandStart start=/\%#=1`/ matchgroup=crystalCommandEnd end=/\%#=1`/ contains=crystalStringInterpolation,crystalStringEscape,crystalStringEscapeError nextgroup=@crystalPostfix skipwhite

syn region crystalCommand matchgroup=crystalCommandStart start=/\%#=1%x(/  matchgroup=crystalCommandEnd end=/\%#=1)/ contains=crystalStringParentheses,crystalStringInterpolation,crystalStringEscape,crystalStringEscapeError nextgroup=@crystalPostfix skipwhite
syn region crystalCommand matchgroup=crystalCommandStart start=/\%#=1%x\[/ matchgroup=crystalCommandEnd end=/\%#=1]/ contains=crystalStringSquareBrackets,crystalStringInterpolation,crystalStringEscape,crystalStringEscapeError nextgroup=@crystalPostfix skipwhite
syn region crystalCommand matchgroup=crystalCommandStart start=/\%#=1%x{/  matchgroup=crystalCommandEnd end=/\%#=1}/ contains=crystalStringCurlyBraces,crystalStringInterpolation,crystalStringEscape,crystalStringEscapeError nextgroup=@crystalPostfix skipwhite
syn region crystalCommand matchgroup=crystalCommandStart start=/\%#=1%x</  matchgroup=crystalCommandEnd end=/\%#=1>/ contains=crystalStringAngleBrackets,crystalStringInterpolation,crystalStringEscape,crystalStringEscapeError nextgroup=@crystalPostfix skipwhite
syn region crystalCommand matchgroup=crystalCommandStart start=/\%#=1%x|/  matchgroup=crystalCommandEnd end=/\%#=1|/ contains=crystalStringInterpolation,crystalStringEscape,crystalStringEscapeError nextgroup=@crystalPostfix skipwhite

" Blocks <<<2
if s:no_expensive
  syn keyword crystalKeyword if unless case select while until begin else elsif when in ensure
  syn keyword crystalKeyword rescue nextgroup=crystalConstant skipwhite
  syn keyword crystalKeyword end nextgroup=@crystalPostfix skipwhite
  syn keyword crystalKeyword do nextgroup=crystalBlockParameters skipwhite

  syn keyword crystalKeyword def macro nextgroup=crystalMethodDefinition,crystalMethodReceiver,crystalMethodSelf skipwhite
  syn keyword crystalKeyword class struct lib annotation enum module union nextgroup=crystalTypeDefinition,crystalTypeModule skipwhite

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

  syn match crystalKeyword /\%#=1\<do\>/ nextgroup=crystalBlockParameters skipwhite contained containedin=crystalBlock,crystalMarkdownCrystalBlock
  syn region crystalBlock start=/\%#=1\<do\>/ matchgroup=crystalKeyword end=/\%#=1\<\.\@1<!end\>/ contains=TOP nextgroup=@crystalPostfix skipwhite

  syn region crystalBlock matchgroup=crystalKeyword start=/\%#=1\<\%(if\|unless\|case\|select\|while\|until\|begin\)\>/ end=/\%#=1\<\.\@1<!end\>/ contains=TOP nextgroup=@crystalPostfix skipwhite
  syn keyword crystalKeyword else elsif when in ensure contained containedin=crystalBlock,crystalMarkdownCrystalBlock
  syn keyword crystalKeyword rescue contained containedin=crystalBlock,crystalMarkdownCrystalBlock nextgroup=crystalConstant skipwhite

  syn match crystalDefine /\%#=1\<\%(def\|macro\)\>/ nextgroup=crystalMethodDefinition,crystalMethodReceiver,crystalMethodSelf skipwhite contained containedin=crystalDefineBlock,crystalMarkdownCrystalDefineBlock
  syn match crystalDefine /\%#=1\<\%(class\|struct\|annotation\|enum\|module\|union\)\>/ nextgroup=crystalTypeDefinition,crystalTypeModule skipwhite contained containedin=crystalDefineBlock,crystalMarkdownCrystalDefineBlock
  syn match crystalDefine /\%#=1\<lib\>/ nextgroup=crystalTypeDefinition,crystalTypeModule skipwhite contained containedin=crystalLibDefineBlock,crystalMarkdownCrystalLibDefineBlock

  syn region crystalDefineBlock start=/\%#=1\<\%(def\|macro\|class\|struct\|annotation\|enum\|module\|union\)\>/ matchgroup=crystalDefine end=/\%#=1\<\.\@1<!end\>/ contains=TOP fold
  syn region crystalLibDefineBlock start=/\%#=1\<lib\>/ matchgroup=crystalDefine end=/\%#=1\<\.\@1<!end\>/ contains=TOP fold
  syn keyword crystalDefine else ensure contained containedin=crystalDefineBlock,crystalMarkdownCrystalDefineBlock
  syn keyword crystalDefine rescue contained containedin=crystalDefineBlock,crystalMarkdownCrystalDefineBlock nextgroup=crystalConstant skipwhite

  syn keyword crystalDefine abstract nextgroup=crystalDefineNoBlock skipwhite
  syn keyword crystalDefine private protected nextgroup=crystalDefineBlock,crystalLibDefineBlock,crystalConstant skipwhite

  syn keyword crystalDefine alias nextgroup=crystalTypeAlias skipwhite
  syn keyword crystalDefine type contained containedin=crystalLibDefineBlock,crystalMarkdownCrystalLibDefineBlock nextgroup=crystalTypeAlias skipwhite

  syn keyword crystalDefineNoBlock def contained nextgroup=crystalMethodDefinition,crystalMethodReceiver,crystalMethodSelf skipwhite
  syn keyword crystalDefineNoBlock fun nextgroup=crystalLibMethodDefinition skipwhite

  hi def link crystalDefine Define
  hi def link crystalDefineNoBlock crystalDefine

  if get(s:, "crystal_markdown_comments") == 2
    syn region crystalMarkdownCrystalBlock contained
        \ start=/\%#=1\<do\>/ matchgroup=crystalKeyword end=/\%#=1\<\.\@1<!end\>/
        \ contains=TOP,crystalBlock
        \ nextgroup=@crystalPostfix skipwhite
        \ containedin=crystalMarkdownCrystalCodeLine,crystalMarkdownCrystalBlock,crystalMarkdownCrystalDefineBlock
    syn region crystalMarkdownCrystalBlock contained
        \ start=/\%#=1\<\%(if\|unless\|case\|select\|while\|until\|begin\)\>/ matchgroup=crystalKeyword end=/\%#=1\<\.\@1<!end\>/
        \ contains=TOP,crystalBlock
        \ nextgroup=@crystalPostfix skipwhite
        \ containedin=crystalMarkdownCrystalCodeLine,crystalMarkdownCrystalBlock,crystalMarkdownCrystalDefineBlock
    syn region crystalMarkdownCrystalDefineBlock contained fold
        \ start=/\%#=1\<\%(def\|macro\|class\|struct\|annotation\|enum\|module\|union\)\>/ matchgroup=crystalDefine end=/\%#=1\<\.\@1<!end\>/
        \ contains=TOP,crystalDefineBlock
        \ containedin=crystalMarkdownCrystalCodeLine,crystalMarkdownCrystalBlock,crystalMarkdownCrystalDefineBlock
    syn region crystalMarkdownCrystalLibDefineBlock contained fold
        \ start=/\%#=1\<lib\>/ matchgroup=crystalDefine end=/\%#=1\<\.\@1<!end\>/
        \ contains=TOP,crystalLibDefineBlock
        \ containedin=crystalMarkdownCrystalCodeLine,crystalMarkdownCrystalBlock,crystalMarkdownCrystalDefineBlock

    syn match crystalMarkdownCrystalBlockContinuator /\%#=1#/ contained containedin=crystalMarkdownCrystalBlock,crystalMarkdownCrystalDefineBlock,crystalMarkdownCrystalLibDefineBlock

    hi def link crystalMarkdownCrystalBlockContinuator crystalMarkdownCrystalCodeLineStart
  endif
endif

syn match crystalTypeDefinition /\%#=1\%(\u\|\\\={{.\{-}}}\)\%([^\x00-\x2F\x3A-\x40\x5B-\x5E`\x7B-\x9F]\+\|\\\={{.\{-}}}\)*/ contained nextgroup=crystalTypeModule,crystalInheritanceOperator,crystalGeneric skipwhite
syn match crystalTypeModule /\%#=1::/ contained nextgroup=crystalTypeDefinition
syn match crystalInheritanceOperator /\%#=1</ contained nextgroup=crystalType skipwhite
syn region crystalGeneric matchgroup=crystalDelimiter start=/\%#=1(/ end=/\%#=1)/ contained contains=crystalParameterModifier,crystalType nextgroup=crystalInheritanceOperator skipwhite

syn match crystalMethodDefinition /\%#=1\%(\%([^\x00-\x5E`\x7B-\x9F]\|\\\={{.\{-}}}\)\%([^\x00-\x2F\x3A-\x40\x5B-\x5E`\x7B-\x9F]\+\|\\\={{.\{-}}}\)*[?!=]\=\|\%([+\-|^~%]\|\*\*\=\|\/\/\=\|=\%(==\=\|\~\)\|![=~]\=\|<\%(=>\=\|<\)\=\|>[>=]\=\|&\%([+-]\|\*\*\=\)\=\|\[][=?]\=\)\)/ contained nextgroup=crystalMethodParameters,crystalTypeRestrictionOperator skipwhite
syn region crystalMethodParameters matchgroup=crystalDelimiter start=/\%#=1(/ end=/\%#=1)/ contained contains=crystalParameter,crystalInstanceVariableParameter,crystalAnnotation,crystalParameterModifier,crystalOut nextgroup=crystalTypeRestrictionOperator skipwhite
syn match crystalParameter /\%#=1[^\x00-\x5E`\x7B-\x9F][^\x00-\x2F\x3A-\x40\x5B-\x5E`\x7B-\x9F]*/ contained nextgroup=crystalTypeRestrictionOperator,crystalParameter,crystalAssignmentOperator skipwhite
syn match crystalInstanceVariableParameter contained /\%#=1@@\=\%([^\x00-\x40\x5B-\x5E`\x7B-\x9F]\|\\\={{.\{-}}}\)\%([^\x00-\x2F\x3A-\x40\x5B-\x5E`\x7B-\x9F]\+\|\\\={{.\{-}}}\)*/ nextgroup=crystalTypeRestrictionOperator,crystalAssignmentOperator skipwhite
syn match crystalParameterModifier /\%#=1\*\*\=/ contained nextgroup=crystalParameter,crystalInstanceVariableParameter,crystalTypeRestrictionOperator skipwhite
syn match crystalParameterModifier /\%#=1&/ contained nextgroup=crystalParameter,crystalInstanceVariableParameter,crystalTypeRestrictionOperator skipwhite
syn keyword crystalOut out contained nextgroup=crystalParameter skipwhite
syn match crystalMethodReceiver /\%#=1\u[^\x00-\x2F\x3A-\x40\x5B-\x5E`\x7B-\x9F]*/ contained nextgroup=crystalMethodDot,crystalMethodModuleOperator
syn match crystalMethodModuleOperator /\%#=1::/ contained nextgroup=crystalMethodReceiver
syn keyword crystalMethodSelf self contained nextgroup=crystalMethodDot
syn match crystalMethodDot /\%#=1\./ contained nextgroup=crystalMethodDefinition

syn match crystalLibMethodDefinition /\%#=1\%([^\x00-\x5E`\x7B-\x9F]\|\\\={{.\{-}}}\)\%([^\x00-\x2F\x3A-\x40\x5B-\x5E`\x7B-\x9F]\+\|\\\={{.\{-}}}\)*/ contained nextgroup=crystalCFunctionParameters,crystalTypeRestrictionOperator,crystalMethodAssignmentOperator skipwhite
syn match crystalMethodAssignmentOperator /\%#=1=/ contained nextgroup=crystalCFunctionName,crystalCFunctionStringName skipwhite skipempty
syn match crystalCFunctionName /\%#=1\%([^\x00-\x40\x5B-\x5E`\x7B-\x9F]\|\\\={{.\{-}}}\)\%([^\x00-\x2F\x3A-\x40\x5B-\x5E`\x7B-\x9F]\+\|\\\={{.\{-}}}\)*/ contained nextgroup=crystalCFunctionParameters,crystalTypeRestrictionOperator skipwhite
syn region crystalCFunctionStringName matchgroup=crystalStringStart start=/\%#=1"/ end=/\%#=1"/ contained oneline nextgroup=crystalCFunctionParameters,crystalTypeRestrictionOperator skipwhite
syn region crystalCFunctionParameters matchgroup=crystalDelimiter start=/\%#=1(/ end=/\%#=1)/ contained contains=crystalParameter,crystalParameterModifier,crystalAnnotation,@crystalTypes nextgroup=crystalTypeRestrictionOperator skipwhite

" Miscellaneous <<<2
syn keyword crystalKeyword forall with
syn keyword crystalKeyword uninitialized nextgroup=@crystalTypes skipwhite

syn match crystalTypeAlias /\%#=1\%(\u\|\\\={{.\{-}}}\)\%([^\x00-\x2F\x3A-\x40\x5B-\x5E`\x7B-\x9F]\+\|\\\={{.\{-}}}\)*/ contained nextgroup=crystalTypeAliasOperator,crystalTypeAliasModuleOperator skipwhite
syn match crystalTypeAliasOperator /\%#=1=/ contained nextgroup=@crystalTypes skipwhite skipempty
syn match crystalTypeAliasModuleOperator /\%#=1::/ contained nextgroup=crystalTypeAlias skipwhite

syn keyword crystalKeyword include extend nextgroup=@crystalTypes skipwhite
syn keyword crystalKeyword return yield next break nextgroup=crystalPostfixKeyword skipwhite
syn keyword crystalKeyword require nextgroup=crystalString skipwhite

syn keyword crystalPostfixKeyword if unless rescue then contained

syn region crystalBlockParameters matchgroup=crystalDelimiter start=/\%#=1|/ end=/\%#=1|/ contained
syn match crystalBlockParameter /\%#=1[^\x00-\x5E`\x7B-\x9F][^\x00-\x2F\x3A-\x40\x5B-\x5E`\x7B-\x9F]*/ contained containedin=crystalBlockParameters,crystalBlockParentheses
syn region crystalBlockParentheses matchgroup=crystalDelimiter start=/\%#=1(/ end=/\%#=1)/ contained containedin=crystalBlockParameters

syn region crystalNestedBraces start=/\%#=1{/ matchgroup=crystalDelimiter end=/\%#=1}/ contained transparent nextgroup=@crystalPostfix skipwhite

syn region crystalAnnotation matchgroup=crystalAnnotationDelimiter start=/\%#=1@\[/ end=/\%#=1]/ contains=@crystalTop,crystalNestedBrackets

syn region crystalNestedBrackets matchgroup=crystalDelimiter start=/\%#=1\[/ end=/\%#=1]?\=/ contained transparent nextgroup=@crystalPostfix

" Macros <<<2
syn region crystalMacro matchgroup=crystalMacroDelimiter start=/\%#=1\\\={%/ end=/\%#=1%}/ contains=TOP
syn region crystalMacro matchgroup=crystalMacroDelimiter start=/\%#=1\\\={{/ end=/\%#=1}}/ contains=@crystalTop,crystalNestedBraces nextgroup=@crystalPostfix skipwhite
syn region crystalEmbeddedMacro matchgroup=crystalMacroDelimiter start=/\%#=1\\\={{/ end=/\%#=1}}/ contains=@crystalTop,crystalNestedBraces
      \ contained containedin=
      \ crystalString,crystalSymbol,crystalRegex,crystalCommand,crystalStringArray,crystalSymbolArray,crystalHeredocLine,crystalHeredocLineRaw,crystalCFunctionStringName,
      \ crystalInstanceVariable,crystalExternalVariable,crystalTypeDefinition,crystalMethodDefinition,crystalLibMethodDefinition,crystalCFunctionName,crystalTypeAlias,
      \ crystalTypeInvocation,crystalMethodParameters,crystalTypeArray

syn keyword crystalMacroKeyword if unless else elsif begin for do end verbatim contained containedin=crystalMacro,crystalEmbeddedMacro
" >>>2

" Highlighting <<<1
hi def link crystalComment Comment
hi def link crystalOperator Operator
hi def link crystalUnaryOperator crystalOperator
hi def link crystalMethodOperator crystalOperator
hi def link crystalRangeOperator crystalOperator
hi def link crystalModuleOperator crystalOperator
hi def link crystalDelimiter Delimiter
hi def link crystalInstanceVariable Identifier
hi def link crystalExternalVariable Identifier
hi def link crystalConstant Identifier
hi def link crystalNil Constant
hi def link crystalBoolean Boolean
hi def link crystalSelf Constant
hi def link crystalSuper Constant
hi def link crystalNumber Number
hi def link crystalCharacter Character
hi def link crystalCharacterDelimiter crystalDelimiter
hi def link crystalCharacterEscape SpecialChar
hi def link crystalCharacterEscapeError Error
hi def link crystalString String
hi def link crystalStringStart crystalDelimiter
hi def link crystalStringEnd crystalStringStart
hi def link crystalStringEscape SpecialChar
hi def link crystalStringEscapeError Error
hi def link crystalStringInterpolationDelimiter crystalDelimiter
hi def link crystalStringParenthesisEscape crystalStringEscape
hi def link crystalStringSquareBracketEscape crystalStringEscape
hi def link crystalStringCurlyBraceEscape crystalStringEscape
hi def link crystalStringAngleBracketEscape crystalStringEscape
hi def link crystalStringPipeEscape crystalStringEscape
hi def link crystalStringArray crystalString
hi def link crystalStringArrayDelimiter crystalDelimiter
hi def link crystalHeredocLine String
hi def link crystalHeredocLineRaw crystalHeredocLine
hi def link crystalHeredocStart crystalStringStart
hi def link crystalHeredocEnd crystalHeredocStart
hi def link crystalSymbol String
hi def link crystalSymbolStart crystalDelimiter
hi def link crystalSymbolEnd crystalSymbolStart
hi def link crystalSymbolArray crystalSymbol
hi def link crystalSymbolArrayDelimiter crystalDelimiter
hi def link crystalNamedTupleKey crystalSymbol
hi def link crystalRegex String
hi def link crystalRegexStart crystalDelimiter
hi def link crystalRegexEnd crystalRegexStart
hi def link crystalRegexSlashEscape crystalStringEscape
hi def link crystalPCREMetaCharacter SpecialChar
hi def link crystalPCREEscape crystalPCREMetaCharacter
hi def link crystalPCREQuantifier crystalPCREMetaCharacter
hi def link crystalPCREPOSIXClass crystalPCREMetaCharacter
hi def link crystalPCREComment crystalComment
hi def link crystalPCREControl crystalPCREMetaCharacter
hi def link crystalCommand String
hi def link crystalCommandStart crystalDelimiter
hi def link crystalCommandEnd crystalCommandStart
hi def link crystalKeyword Keyword
hi def link crystalKeywordError Error
hi def link crystalPostfixKeyword crystalKeyword
hi def link crystalMacroKeyword crystalKeyword
hi def link crystalMethodDefinition Function
hi def link crystalLibMethodDefinition crystalMethodDefinition
hi def link crystalMethodReceiver crystalConstant
hi def link crystalMethodModuleOperator crystalModuleOperator
hi def link crystalMethodSelf crystalSelf
hi def link crystalMethodDot crystalOperator
hi def link crystalTypeDefinition Typedef
hi def link crystalTypeAlias crystalTypeDefinition
hi def link crystalTypeModule crystalModuleOperator
hi def link crystalInheritanceOperator crystalOperator
hi def link crystalMacroDelimiter PreProc
hi def link crystalFreshVariable Identifier
hi def link crystalAnnotationDelimiter crystalDelimiter
hi def link crystalBlockParameter crystalVariableOrMethod
hi def link crystalAssignmentOperator crystalOperator
hi def link crystalMethodAssignmentOperator crystalAssignmentOperator
hi def link crystalCFunctionStringName crystalString
hi def link crystalTypeRestrictionOperator crystalOperator
hi def link crystalType Type
hi def link crystalTypeOperator crystalOperator
hi def link crystalTypeModuleOperator crystalTypeOperator
hi def link crystalTypeModifier crystalTypeOperator
hi def link crystalTypeModifierClass crystalVariableOrMethod
hi def link crystalTypeUnionOperator crystalTypeOperator
hi def link crystalTypeProcOperator crystalTypeOperator
hi def link crystalTypeHashOperator crystalTypeOperator
hi def link crystalTypeSelf crystalSelf
hi def link crystalTypeNil crystalNil
hi def link crystalTypeTypeof crystalVariableOrMethod
hi def link crystalPseudoMethod crystalVariableOrMethod
hi def link crystalOf crystalKeyword
hi def link crystalParameterModifier crystalOperator
hi def link crystalTypeSplat crystalTypeOperator
hi def link crystalTypeAliasModuleOperator crystalModuleOperator
hi def link crystalNamedTupleKeyDelimiter crystalDelimiter
hi def link crystalInstanceVariableParameter crystalInstanceVariable
hi def link crystalOut crystalKeyword
hi def link crystalTypeTupleKey crystalNamedTupleKey
hi def link crystalComma crystalDelimiter
hi def link crystalTypeComma crystalComma
hi def link crystalBackslash crystalDelimiter
hi def link crystalTypeAliasOperator crystalOperator
hi def link crystalSemicolon crystalDelimiter
" >>>

" vim:foldmethod=marker:foldmarker=<<<,>>>
