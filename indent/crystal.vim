" Vim indent file
" Language: Crystal <crystal-lang.org>
" Author: Jeffrey Crochet <jlcrochet@pm.me>
" URL: https://github.com/jlcrochet/vim-crystal

if get(b:, "did_indent")
  finish
endif

let b:did_indent = 1

setlocal indentkeys=0),0],0},0.,0=..,o,O,!^F
let &indentkeys ..= "," .. g:crystal#indent#dedent_words

if has("nvim-0.5")
  lua require "get_crystal_indent"
  setlocal indentexpr=v:lua.get_crystal_indent()
  finish
endif

setlocal indentexpr=GetCrystalIndent()

if exists("*GetCrystalIndent")
  finish
endif

" Helpers {{{
let s:multiline_regions = #{
      \ crystalString: 1,
      \ crystalStringEscape: 1,
      \ crystalStringInterpolationDelimiter: 1,
      \ crystalStringParenthesisEscape: 1,
      \ crystalStringSquareBracketEscape: 1,
      \ crystalStringCurlyBraceEscape: 1,
      \ crystalStringAngleBracketEscape: 1,
      \ crystalStringPipeEscape: 1,
      \ crystalStringEnd: 1,
      \ crystalSymbol: 1,
      \ crystalSymbolEnd: 1,
      \ crystalRegex: 1,
      \ crystalRegexEnd: 1,
      \ crystalPCREEscape: 1,
      \ crystalPCREGroup: 1,
      \ crystalPCRELiteral: 1,
      \ crystalPCREMetaCharacter: 1,
      \ crystalPCREClass: 1,
      \ crystalPCREQuantifier: 1,
      \ crystalPCREComment: 1,
      \ crystalPCREControl: 1,
      \ crystalRegexSlashEscape: 1,
      \ crystalCommand: 1,
      \ crystalCommandEnd: 1,
      \ crystalHeredocLine: 1,
      \ crystalHeredocLineRaw: 1,
      \ crystalHeredocEnd: 1
      \ }

let s:block_start_re = '\C\v<%(if|unless|case|begin|for|while|until|do)>'
let s:block_middle_re = '\C\v<%(else|elsif|when|in|ensure|rescue)>'

let s:define_block_start_re = '\C\v<%(def|macro|class|struct|lib|annotation|enum|module|union)>'
let s:define_block_middle_re = '\C\v<%(else|ensure|rescue)>'

let s:all_start_re = '\C\v<%(if|unless|case|begin|for|while|until|do|def|macro|class|struct|lib|annotation|enum|module|union)>'

let s:skip_bracket = 'synID(line("."), col("."), 0)->synIDattr("name") !~# ''^crystal\%(StringArray\|SymbolArray\)\=Delimiter$'''
let s:skip_keyword = 'synID(line("."), col("."), 0)->synIDattr("name") !~# ''^crystal\%(Macro\)\=Keyword$'''
let s:skip_define = 'synID(line("."), col("."), 0)->synIDattr("name") !=# "crystalDefine"'
let s:skip_all = 'synID(line("."), col("."), 0)->synIDattr("name") !~# ''^crystal\%(Keyword\|MacroKeyword\|Define\)$'''

function s:is_operator(char, idx, lnum)
  if a:char =~# '[%&*+\-/<?^~]'
    return synID(a:lnum, a:idx + 1, 0)->synIDattr("name") ==# "crystalOperator"
  elseif a:char ==# ":"
    return synID(a:lnum, a:idx + 1, 0)->synIDattr("name") =~# '^crystal\%(TypeRestriction\)\=Operator$'
  elseif a:char ==# "="
    return synID(a:lnum, a:idx + 1, 0)->synIDattr("name") =~# '^crystal\%(Assignment\|MethodAssignment\|TypeAlias\)\=Operator$'
  elseif a:char ==# ">"
    return synID(a:lnum, a:idx + 1, 0)->synIDattr("name") =~# '^crystal\%(TypeHash\)\=Operator$'
  elseif a:char ==# "|"
    return synID(a:lnum, a:idx + 1, 0)->synIDattr("name") =~# '^crystal\%(TypeUnion\)\=Operator$'
  endif
endfunction

" 0 = no continuation
" 1 = hanging operator or backslash
" 2 = hanging postfix keyword
" 3 = comma
" 4 = opening bracket
" 5 = named tuple key delimiter
function s:ends_with_line_continuator(lnum)
  let line = getline(a:lnum)
  let [char, idx, next_idx] = line->matchstrpos('\S')

  let last_idx = idx

  while idx != -1
    if char ==# "#"
      if synID(a:lnum, next_idx, 0)->synIDattr("name") ==# "crystalLineComment"
        break
      endif
    else
      let [word, _, offset] = line->matchstrpos('^\l\+', idx)

      if offset != -1
        let next_idx = offset
      endif
    endif

    let last_idx = idx

    let [char, idx, next_idx] = line->matchstrpos('\S', next_idx)
  endwhile

  let last_char = line[last_idx]

  if last_char ==# '\'
    return 1
  elseif last_char ==# ","
    return 3
  elseif last_char ==# ":"
    let syngroup = synID(a:lnum, last_idx + 1, 0)->synIDattr("name")

    if syngroup ==# "crystalOperator" || syngroup ==# "crystalTypeRestrictionOperator"
      return 1
    elseif syngroup ==# "crystalSymbolStart"
      return 5
    endif
  elseif last_char ==# "(" || last_char ==# "[" || last_char ==# "{"
    if synID(a:lnum, last_idx + 1, 0)->synIDattr("name") =~# '^crystal\%(StringArray\|SymbolArray\)\=Delimiter$'
      return 4
    endif
  elseif last_char ==# "|"
    let syngroup = synID(a:lnum, last_idx + 1, 0)->synIDattr("name")

    if syngroup ==# "crystalOperator" || syngroup ==# "crystalTypeUnionOperator"
      return 1
    elseif syngroup ==# "crystalDelimiter"
      return 4
    endif
  elseif last_char ==# "i"
    if line->match('\C^if[[:alnum:]_?!:]\@!', last_idx) != -1
      return 2
    endif
  elseif last_char ==# "r"
    if line->match('\C^rescue[[:alnum:]_?!:]\@!', last_idx) != -1 && synID(a:lnum, last_idx + 1, 0)->synIDattr("name") ==# "crystalPostfixKeyword"
      return 2
    endif
  elseif last_char ==# "u"
    if line->match('\C^unless[[:alnum:]_?!:]\@!', last_idx) != -1
      return 2
    endif
  elseif s:is_operator(last_char, last_idx, a:lnum)
    return 1
  endif
endfunction

function s:get_msl(lnum)
  let prev_lnum = prevnonblank(a:lnum - 1)

  if prev_lnum == 0
    return a:lnum
  endif

  let start_lnum = prev_lnum

  while s:multiline_regions->get(synID(start_lnum, 1, 0)->synIDattr("name"))
    let start_lnum = prevnonblank(start_lnum - 1)
  endwhile

  let continuation = 0

  let start_line = getline(start_lnum)
  let [start_first_char, start_first_idx, start_first_col] = start_line->matchstrpos('\S')

  if start_first_char ==# "."
    if start_line[start_first_col] !=# "."
      let continuation = 6
    endif
  endif

  let prev_lnum = prevnonblank(start_lnum - 1)

  if prev_lnum == 0
    return start_lnum
  endif

  if !continuation
    let continuation = s:ends_with_line_continuator(prev_lnum)

    if continuation == 4
      return start_lnum
    endif
  endif

  while continuation
    let start_lnum = prev_lnum

    while s:multiline_regions->get(synID(start_lnum, 1, 0)->synIDattr("name"))
      let start_lnum = prevnonblank(start_lnum - 1)
    endwhile

    let continuation = 0

    let start_line = getline(start_lnum)
    let [start_first_char, start_first_idx, start_first_col] = start_line->matchstrpos('\S')

    if start_first_char ==# "."
      if start_line[start_first_col] !=# "."
        let continuation = 6
      endif
    endif

    let prev_lnum = prevnonblank(start_lnum - 1)

    if prev_lnum == 0
      return start_lnum
    endif

    if !continuation
      let continuation = s:ends_with_line_continuator(prev_lnum)

      if continuation == 4
        return start_lnum
      endif
    endif
  endwhile

  return start_lnum
endfunction
" }}}

" GetCrystalIndent {{{
if get(g:, "crystal_simple_indent")
  " Simple {{{
  function GetCrystalIndent() abort
    if s:multiline_regions->get(synID(v:lnum, 1, 0)->synIDattr("name"))
      return -1
    endif

    let prev_lnum = prevnonblank(v:lnum - 1)

    if prev_lnum == 0
      return 0
    endif

    " Check the current line for a closing bracket or dedenting keyword:
    let line = getline(v:lnum)
    let [first_char, first_idx, first_col] = line->matchstrpos('\S')

    let shift = 0
    let has_dedent = 0
    let continuation = 0

    if first_char ==# ")" || first_char ==# "]" || first_char ==# "}"
      let shift -= 1
      let has_dedent = 1
    elseif first_char ==# "."
      if line[first_col] !=# "."
        let continuation = 6
      endif
    elseif line->match('\C^\%(\\\={%\s*\)\=\%(end\|else\|elsif\|when\|in\|rescue\|ensure\)[[:alnum:]_?!:]\@!', first_idx) != -1
      let shift -= 1
      let has_dedent = 1
    endif

    " Check the previous line:
    let start_lnum = prev_lnum

    while s:multiline_regions->get(synID(start_lnum, 1, 0)->synIDattr("name"))
      let start_lnum = prevnonblank(start_lnum - 1)
    endwhile

    if !continuation
      let continuation = s:ends_with_line_continuator(prev_lnum)

      if continuation == 4
        let shift += 1
        return indent(start_lnum) + shift * shiftwidth()
      endif
    endif

    call cursor(0, 1)

    if searchpair(s:all_start_re, s:block_middle_re, '\C\<end\>', "b", s:skip_keyword, start_lnum)
      let shift += 1
      return indent(start_lnum) + shift * shiftwidth()
    endif

    " Check for line continuations:
    let prev_continuation = 0

    let start_line = getline(start_lnum)
    let [start_first_char, start_first_idx, start_first_col] = start_line->matchstrpos('\S')

    if start_first_char ==# "."
      if start_line[start_first_col] !=# "."
        let prev_continuation = 6
      endif
    endif

    if !prev_continuation
      let prev_lnum = prevnonblank(start_lnum - 1)

      if prev_lnum != 0
        let prev_continuation = s:ends_with_line_continuator(prev_lnum)
      endif
    endif

    if continuation == 0
      if prev_continuation == 1 || prev_continuation == 2 || prev_continuation == 6
        let shift -= 1
      elseif prev_continuation == 3
        if !has_dedent && start_line->match('\C^\%([)\]}]\|end[[:alnum:]_?!:]\@!\)', start_first_idx) == -1
          let shift -= 1
        endif
      endif
    elseif continuation == 1 || continuation == 2 || continuation == 6
      if prev_continuation == 1 || prev_continuation == 2 || prev_continuation == 5 || prev_continuation == 6
        return start_first_idx
      else
        return start_first_idx + shiftwidth()
      endif
    elseif continuation == 3
      if prev_continuation == 1 || prev_continuation == 2
        let shift -= 1
      elseif prev_continuation == 3
        if has_dedent
          return start_first_idx - shiftwidth()
        else
          return start_first_idx
        endif
      elseif prev_continuation == 4
        return start_first_idx
      elseif prev_continuation == 5
        return start_first_idx - shiftwidth()
      else
        if start_line->match('\C^\%([)\]}]\|end[[:alnum:]_?!:]\@!\)', start_first_idx) == -1
          return start_first_idx + shiftwidth()
        endif
      endif
    elseif continuation == 5
      return start_first_idx + shiftwidth()
    endif

    " Default:
    return start_first_idx + shift * shiftwidth()
  endfunction
  " }}}
else
  " Default {{{
  function GetCrystalIndent() abort
    if s:multiline_regions->get(synID(v:lnum, 1, 0)->synIDattr("name"))
      return -1
    endif

    let prev_lnum = prevnonblank(v:lnum - 1)

    if prev_lnum == 0
      return 0
    endif

    " Check the current line for a closing bracket or dedenting keyword:
    let line = getline(v:lnum)
    let [first_char, first_idx, first_col] = line->matchstrpos('\S')

    call cursor(0, 1)

    if first_char ==# ")"
      return indent(searchpair('(', '', ')', "bW", s:skip_bracket))
    elseif first_char ==# "]"
      return indent(searchpair('\[', '', ']', "bW", s:skip_bracket))
    elseif first_char ==# "}"
      return indent(searchpair('{', '', '}', "bW", s:skip_bracket))
    elseif line->match('\C^\%(\\\={%\s*\)\=\%(end\|else\|elsif\|when\|in\|rescue\|ensure\)[[:alnum:]_?!:]\@!', first_idx) != -1
      let syngroup = synID(v:lnum, first_col, 0)->synIDattr("name")

      if syngroup ==# "crystalKeyword"
        let [l, c] = searchpairpos(s:block_start_re, s:block_middle_re, '\C\<end\>', "bW", s:skip_keyword)

        if expand("<cword>") ==# "do"
          return indent(l)
        else
          return c - 1
        endif
      elseif syngroup ==# "crystalMacroDelimiter"
        let shift = -1
        let msl = s:get_msl(v:lnum)

        if searchpair(s:block_start_re, s:block_middle_re, '\C\<end\>', "b", s:skip_keyword, msl)
          let shift += 1
        endif

        return indent(msl) + shift * shiftwidth()
      elseif syngroup ==# "crystalDefine"
        let shift = -1
        let msl = s:get_msl(v:lnum)

        if searchpair(s:define_block_start_re, s:define_block_middle_re, '\C\<end\>', "b", s:skip_define, msl)
          let shift += 1
        endif

        return indent(msl) + shift * shiftwidth()
      endif
    endif

    " Check the previous line:
    let start_lnum = prev_lnum

    while s:multiline_regions->get(synID(start_lnum, 1, 0)->synIDattr("name"))
      let start_lnum = prevnonblank(start_lnum - 1)
    endwhile

    let [l, c, p] = searchpos('\C\([(\[{]\)\|\([)\]}]\)\|\v<%((def|class|module|macro|struct|enum|annotation|lib|union)|(if|unless|case|begin|while|until|for|do)|(else|elsif|when|in|ensure|rescue)|(end))>', "bp", start_lnum)

    while p
      let syngroup = synID(l, c, 0)->synIDattr("name")

      if p == 2
        if syngroup ==# "crystalDelimiter"
          let line = getline(l)
          let [char, idx, _] = line->matchstrpos('\S', c)

          if char ==# "|" || char ==# "#"
            return indent(l) + shiftwidth()
          else
            return idx
          endif
        elseif syngroup ==# "crystalStringArrayDelimiter" || syngroup ==# "crystalSymbolArrayDelimiter"
          if search('\S', "z", l)
            return col(".") - 1
          else
            return indent(l) + shiftwidth()
          endif
        endif
      elseif p == 3
        if syngroup ==# "crystalDelimiter" || syngroup ==# "crystalStringArrayDelimiter" || syngroup ==# "crystalSymbolArrayDelimiter"
          let start_lnum = searchpair('[(\[{]', '', '[)\]}]', "bW", s:skip_bracket)

          while s:multiline_regions->get(synID(start_lnum, 1, 0)->synIDattr("name"))
            let start_lnum = prevnonblank(start_lnum - 1)
          endwhile
        endif
      elseif p == 4
        if syngroup ==# "crystalDefine"
          return indent(l) + shiftwidth()
        endif
      elseif p == 5
        if syngroup ==# "crystalKeyword"
          if expand("<cword>") ==# "do"
            return indent(l) + shiftwidth()
          else
            return c - 1 + shiftwidth()
          endif
        elseif syngroup ==# "crystalMacroKeyword"
          return indent(l) + shiftwidth()
        endif
      elseif p == 6
        if syngroup ==# "crystalKeyword" || syngroup ==# "crystalDefine"
          return c - 1 + shiftwidth()
        elseif syngroup ==# "crystalMacroKeyword"
          return indent(l) + shiftwidth()
        endif
      elseif p == 7
        if syngroup ==# "crystalKeyword" || syngroup ==# "crystalMacroKeyword"
          let start_lnum = searchpair(s:block_start_re, '', '\C\<end\>', "bW", s:skip_keyword)

          while s:multiline_regions->get(synID(start_lnum, 1, 0)->synIDattr("name"))
            let start_lnum = prevnonblank(start_lnum - 1)
          endwhile
        elseif syngroup ==# "crystalDefine"
          let start_lnum = searchpair(s:define_block_start_re, '', '\C\<end\>', "bW", s:skip_define)

          while s:multiline_regions->get(synID(start_lnum, 1, 0)->synIDattr("name"))
            let start_lnum = prevnonblank(start_lnum - 1)
          endwhile
        endif
      endif

      let [l, c, p] = searchpos('\C\([(\[{]\)\|\([)\]}]\)\|\v<%((def|class|module|macro|struct|enum|annotation|lib|union)|(if|unless|case|begin|while|until|for|do)|(else|elsif|when|in|ensure|rescue)|(end))>', "bp", start_lnum)
    endwhile

    " Check for line continuations:
    " 0 = no continuation
    " 1 = hanging operator or backslash
    " 2 = hanging postfix keyword
    " 3 = comma
    " 4 = opening bracket
    " 5 = hash key delimiter
    " 6 = leading dot
    let continuation = 0

    if first_char ==# "."
      if line[first_col] !=# "."
        let continuation = 6
      endif
    endif

    if !continuation
      let continuation = s:ends_with_line_continuator(prev_lnum)
    endif

    let prev_continuation = 0

    let start_line = getline(start_lnum)
    let [start_first_char, start_first_idx, start_first_col] = start_line->matchstrpos('\S')

    if start_first_char ==# "."
      if start_line[start_first_col] !=# "."
        let prev_continuation = 6
      endif
    endif

    if !prev_continuation
      let prev_prev_lnum = prevnonblank(start_lnum - 1)

      if prev_prev_lnum > 0
        let prev_continuation = s:ends_with_line_continuator(prev_prev_lnum)
      endif
    endif

    if continuation == 0
      if prev_continuation == 1 || prev_continuation == 3 || prev_continuation == 6
        " return s:get_msl_indent(start_lnum)
        return indent(s:get_msl(start_lnum))
      elseif prev_continuation == 2
        return start_first_idx - shiftwidth()
      endif
    elseif continuation == 1
      if prev_continuation == 1 || prev_continuation == 5
        return start_first_idx
      else
        " Align with the first character after the first operator in the
        " starting line, if any:
        let upper = strlen(start_line) - 1

        for i in range(start_first_idx + 1, upper)
          let char = start_line[i]

          if char ==# " " || char ==# "\t"
            continue
          endif

          if s:is_operator(char, i, start_lnum)
            for j in range(i + 1, upper)
              let char = start_line[j]

              if char ==# " " || char ==# "\t"
                continue
              endif

              if !s:is_operator(char, j, start_lnum)
                return j
              endif
            endfor

            break
          endif
        endfor

        return start_first_idx + shiftwidth()
      endif
    elseif continuation == 2
      if prev_continuation == 1 || prev_continuation == 2 || prev_continuation == 5
        return start_first_idx
      else
        return start_first_idx + shiftwidth()
      endif
    elseif continuation == 3
      if prev_continuation == 1
        return indent(s:get_msl(start_lnum))
      elseif prev_continuation == 2 || prev_continuation == 5
        return start_first_idx - shiftwidth()
      elseif prev_continuation == 3 || prev_continuation == 4
        return start_first_idx
      else
        return start_first_idx + shiftwidth()
      endif
    elseif continuation == 5
      return start_first_idx + shiftwidth()
    elseif continuation == 6
      if prev_continuation == 6
        return start_first_idx
      else
        " Align with the first dot in the starting line, if any:
        let idx = stridx(start_line, ".", start_first_idx + 1)

        while idx != -1
          if synID(start_lnum, idx + 1, 0)->synIDattr("name") ==# "crystalMethodOperator"
            return idx
          endif

          let idx = stridx(start_line, ".", idx + 2)
        endwhile

        return start_first_idx + shiftwidth()
      endif
    endif

    " Default:
    return start_first_idx
  endfunction
  " }}}
endif
" }}}

" vim:fdm=marker
