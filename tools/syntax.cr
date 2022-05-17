def choice(*xs)
  "\\%(" + xs.join("\\|") + "\\)"
end

def optional(re)
  "\\%(" + re + "\\)\\="
end

# Number patterns:
integer_suffix = %q<[ui]\%(8\|16\|32\|64\|128\)>
float_suffix = %q<f\%(32\|64\)>
exponent_suffix = %q<[eE][+-]\=\d\+\%(_\d\+\)*> + optional("_\\=" + float_suffix)

fraction = %q<\.\d\+\%(_\d\+\)*> + choice(
  float_suffix,
  exponent_suffix,
  '_' + choice(float_suffix, exponent_suffix)
) + "\\="

nonzero_re = %q<[1-9]\d*\%(_\d\+\)*> + choice(
  integer_suffix,
  float_suffix,
  exponent_suffix,
  '_' + choice(integer_suffix, float_suffix, exponent_suffix),
  fraction
) + "\\="

zero_re = '0' + choice(
  integer_suffix,
  float_suffix,
  '_' + choice(integer_suffix, float_suffix, exponent_suffix),
  fraction,
  %q<b[01]\+\%(_[01]\+\)*> + optional(integer_suffix),
  %q<o\o\+\%(_\o\+\)*> + optional(integer_suffix),
  %q<x\x\+\%(_\x\+\)*> + optional(integer_suffix)
) + "\\="

# This pattern helps to match all overloadable operators; these are also
# the only operators that can be referenced as symbols or used as
# method.
overloadable_operators = choice(
  %q[[+\-|^~%]],
  %q[\*\*\=],
  %q[\/\/\=],
  %q[=\%(==\=\|\~\)],
  %q[![=~]\=],
  %q[<\%(=>\=\|<\)\=],
  %q[>[>=]\=],
  %q[&\%([+-]\|\*\*\=\)\=],
  %q[\[][=?]\=]
)

# The syntax for PCRE escapes and groups is pretty complicated, so we're
# building it here:
pcre_escape = "\\\\" + choice(
  "c.",
  %q[\d\+],
  %q[o{\o\+}],
  %q[x\%(\x\x\|{\x\+}\)],
  %q[[pP]{\h\w*}],
  'g' + choice(
    %q[\d\+],
    %q[{\%(-\=\d\+\|\h\w*\)}],
    %q[<\%(-\=\d\+\|\h\w*\)>],
    %q['\%(-\=\d\+\|\h\w*\)']
  ),
  'k' + choice(
    %q[<\h\w*>],
    %q['\h\w*'],
    %q[{\h\w*}]
  )
)

pcre_group_modifier = '?' + choice(
  %q[<\h\w*>],
  %q['\h\w*'],
  'P' + choice(
    %q[<\h\w*>],
    %q[[>=]\h\w*]
  ),
  %q[[:|>=!]],
  %q[-\=[iJmsUx]\+:\=],
  %q[<[=!]],
  'R',
  %q[[+-]\=\d\+],
  %q[&\h\w*],
  '(' + choice(
    %q[[+-]\=\d\+],
    %q[<\h\w*>],
    %q['\h\w*'],
    %q[R\%(\d\+\|&\h\w*\)],
    %q[\h\w*]
  ) + ')',
  %q[C\d*]
)

puts <<-EOF
syn match crystalNumber /\\%#=1#{nonzero_re}\\>/ nextgroup=@crystalPostfix skipwhite
syn match crystalNumber /\\%#=1#{zero_re}\\>/ nextgroup=@crystalPostfix skipwhite
syn match crystalOperatorMethod /\\%#=1#{overloadable_operators}/ contained nextgroup=@crystalPostfix,@crystalArguments skipwhite
syn match crystalSymbol /\\%#=1:#{overloadable_operators}/ contains=crystalSymbolStart nextgroup=@crystalPostfix skipwhite
syn match crystalMethodDefinition /\\%#=1#{overloadable_operators}/ contained nextgroup=crystalMethodParameters,crystalTypeRestrictionOperator skipwhite
syn match crystalPCREEscape /\\%#=1#{pcre_escape}/ contained
syn match crystalPCREGroup matchgroup=crystalPCREMetaCharacter start=/\\%#=1(\\%(#{pcre_group_modifier}\\)\\=/ end=/\\%#=1)/ contained transparent
EOF
