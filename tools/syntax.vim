function s:choice(...)
  return '\%('..a:000->join('\|')..'\)'
endfunction

function s:optional(re)
  return '\%('..a:re..'\)\='
endfunction

" Number patterns:
let s:integer_suffix = '[ui]\%(8\|16\|32\|64\|128\)'
let s:float_suffix = 'f\%(32\|64\)'
let s:exponent_suffix = '[eE][+-]\=\d\+\%(_\d\+\)*'..s:optional('_\='..s:float_suffix)

let s:fraction = '\.\d\+\%(_\d\+\)*'..s:choice(
      \ s:float_suffix,
      \ s:exponent_suffix,
      \ "_"..s:choice(s:float_suffix, s:exponent_suffix)
      \ )..'\=\>'

let s:nonzero_re = '[1-9]\d*\%(_\d\+\)*'..s:choice(
      \ s:integer_suffix,
      \ s:float_suffix,
      \ s:exponent_suffix,
      \ "_"..s:choice(s:integer_suffix, s:float_suffix, s:exponent_suffix),
      \ s:fraction
      \ )..'\=\>'

let s:zero_re = "0"..s:choice(
      \ s:integer_suffix,
      \ s:float_suffix,
      \ "_"..s:choice(s:integer_suffix, s:float_suffix, s:exponent_suffix),
      \ s:fraction,
      \ 'b[01]\+\%(_[01]\+\)*'..s:optional(s:integer_suffix),
      \ 'o\o\+\%(_\o\+\)*'..s:optional(s:integer_suffix),
      \ 'x\x\+\%(_\x\+\)*'..s:optional(s:integer_suffix)
      \ )..'\='

" This pattern helps to match all overloadable operators; these are also
" the only operators that can be referenced as symbols or used as
" method.
let s:overloadable_operators = s:choice(
      \ '[+\-|^~%]',
      \ '\*\*\=',
      \ '\/\/\=',
      \ '=\%(==\=\|\~\)',
      \ '![=~]\=',
      \ '<\%(=>\=\|<\)\=',
      \ '>[>=]\=',
      \ '&\%([+-]\|\*\*\=\)\=',
      \ '\[][=?]\='
      \ )

" The syntax for PCRE escapes and groups is pretty complicated, so we're
" buildilng it here:
let s:pcre_escape = '\\'..s:choice(
      \ "c.",
      \ '\d\+',
      \ 'o{\o\+}',
      \ 'x\%(\x\x\|{\x\+}\)',
      \ '[pP]{\h\w*}',
      \ 'g'..s:choice(
      \   '\d\+',
      \   '{\%(-\=\d\+\|\h\w*\)}',
      \   '<\%(-\=\d\+\|\h\w*\)>',
      \   '''\%(-\=\d\+\|\h\w*\)'''
      \ ),
      \ 'k'..s:choice(
      \   '<\h\w*>',
      \   '''\h\w*''',
      \   '{\h\w*}'
      \ )
      \ )

let s:pcre_group_modifier = "?"..s:choice(
      \ '<\h\w*>',
      \ '''\h\w*''',
      \ 'P'..s:choice(
      \   '<\h\w*>',
      \   '[>=]\h\w*'
      \ ),
      \ '[:|>=!]',
      \ '-\=[iJmsUx]\+:\=',
      \ '<[=!]',
      \ 'R',
      \ '[+-]\=\d\+',
      \ '&\h\w*',
      \ '('..s:choice(
      \   '[+-]\=\d\+',
      \   '<\h\w*>',
      \   '''\h\w*''',
      \   'R\%(\d\+\|&\h\w*\)',
      \   '\h\w*'
      \ ) + ')',
      \ 'C\d*'
      \ )

let g:crystal_number_nonzero = printf('syn match crystalNumber /\%%#=1%s/ nextgroup=@crystalPostfix skipwhite', s:nonzero_re)
let g:crystal_number_zero = printf('syn match crystalNumber /\%%#=1%s/ nextgroup=@crystalPostfix skipwhite', s:zero_re)
let g:crystal_operator_method = printf('syn match crystalOperatorMethod /\%%#=1%s/ contained nextgroup=@crystalPostfix,@crystalArguments skipwhite', s:overloadable_operators)
let g:crystal_symbol = printf('syn match crystalSymbol /\%%#=1:%s/ contains=crystalSymbolStart nextgroup=@crystalPostfix skipwhite', s:overloadable_operators)
let g:crystal_method_definition = printf('syn match crystalMethodDefinition /\%%#=1%s/ contained nextgroup=crystalMethodParameters,crystalTypeRestrictionOperator skipwhite', s:overloadable_operators)
let g:crystal_pcre_escape = printf('syn match crystalPCREEscape /\%%#=1%s/ contained', s:pcre_escape)
let g:crystal_pcre_group = printf('syn region crystalPCREGroup matchgroup=crystalPCREMetaCharacter start=/\%%#=1(\%(%s\)\=/ end=/\%%#=1)/ contained transparent', s:pcre_group_modifier)

delfunction s:choice
delfunction s:optional
unlet s:integer_suffix s:float_suffix s:exponent_suffix s:fraction s:nonzero_re s:zero_re s:overloadable_operators s:pcre_escape s:pcre_group_modifier
