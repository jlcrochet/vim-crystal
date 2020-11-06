" Vim indent file
" Language: Crystal <crystal-lang.org>
" Author: Jeffrey Crochet <jlcrochet@pm.me>
" URL: https://github.com/jlcrochet/vim-crystal

if has_key(b:, "did_indent")
  finish
endif

let b:did_indent = 1

setlocal indentkeys=0),0],0},0.,o,O,!^F
setlocal indentkeys+==end,=else,=elsif,0=when,0=in,0=rescue,0=ensure

if has("nvim-0.5")
  lua get_crystal_indent = require("get_crystal_indent")
  setlocal indentexpr=v:lua.get_crystal_indent()
  finish
endif

setlocal indentexpr=GetCrystalIndent(v:lnum)

if exists("*GetCrystalIndent")
  finish
endif

const s:skip_char = "get(g:crystal#multiline_regions, synID(line('.'), col('.'), 0))"
const s:skip_word = "synID(line('.'), col('.'), 0) != g:crystal#keyword"
const s:skip_macro_delimiter = "synID(line('.'), col('.'), 0) != g:crystal#macro_delimiter"

const s:hanging_re = '\v<%(if|unless|begin|case)>'
const s:non_hanging_re = '\v<%(while|until|for|do|def|macro|class|struct|module|lib|annotation|enum)>'
const s:exception_re = '\v<%(begin|do|def)>'

const s:start_re = s:hanging_re.'|'.s:non_hanging_re
const s:middle_re = '\v<%(else|elsif|when|in|rescue|ensure)>'

const s:macro_start_re = '{%\s*\zs\<\%(if\|unless\|begin\|for\)\>\|\<do\s*%}'
const s:macro_middle_re = '{%\s*\zs\<\%(else\|elsif\)\>'
const s:macro_end_re = '{%\s*\zs\<end\>'

const s:slash_macro_start_re = '\\{%\s*\zs\<\%(if\|unless\|begin\|for\)\>\|.*\zs\<do\s*%}'
const s:slash_macro_middle_re = '\\{%\s*\zs\<\%(else\|elsif\)\>'
const s:slash_macro_end_re = '\\{%\s*\zs\<end\>'

" Similar to the `skip_word` expression above, but includes logic for
" skipping postfix `if` and `unless`.
function! s:skip_word_temp() abort
  let lnum = line(".")
  let col = col(".")

  if synID(lnum, col, 0) != g:crystal#keyword
    return 1
  endif

  let word = expand("<cword>")

  if word ==# "if" || word ==# "unless"
    let [_, col] = searchpos('\S', "b", lnum)

    if !col
      return 0
    endif

    let synid = synID(lnum, col, 0)

    if synid != g:crystal#operator && synid != g:crystal#macro_delimiter
      return 1
    endif
  endif

  return 0
endfunction

const s:skip_word_postfix = function("s:skip_word_temp")

" Find the nearest line up to and including the given line that does not
" begin with a multiline region.
function! s:prev_non_multiline(lnum) abort
  let lnum = a:lnum

  while get(g:crystal#multiline_regions, synID(lnum, 1, 0))
    let lnum = prevnonblank(lnum - 1)
  endwhile

  return lnum
endfunction

function! s:get_last_char() abort
  let [lnum, col] = searchpos('\S', "bW")

  if !lnum
    return
  endif

  while synID(lnum, col, 0) == g:crystal#comment
    let [lnum, col] = searchpos('\S\_s*#', "bW")

    if !lnum
      return
    endif
  endwhile

  let line = getline(lnum)
  let char = line[col - 1]

  return [char, col, lnum, line]
endfunction

function! s:get_msl(lnum) abort
  let lnum = s:prev_non_multiline(a:lnum)

  let line = getline(lnum)
  let [first_char, first_idx, _] = matchstrpos(line, '\S')

  " This line is *not* the MSL if:
  " 1. It starts with a leading dot
  " 2. It starts with a closing bracket
  " 3. It starts with `end`
  " 4. The previous line ended with a comma or hanging operator

  if first_char == "."
    return s:get_msl(prevnonblank(lnum - 1))
  elseif first_char == ")"
    call cursor(lnum, 1)

    let found = searchpair("(", "", ")", "bW", s:skip_char)

    return s:get_msl(found)
  elseif first_char == "]"
    call cursor(lnum, 1)

    let found = searchpair('\[', "", "]", "bW", s:skip_char)

    return s:get_msl(found)
  elseif first_char == "}"
    call cursor(lnum, 1)

    let found = searchpair("{", "", "}", "bW", s:skip_char)

    return s:get_msl(found)
  elseif first_char ==# "e" && match(line, '^nd\>', first_idx + 1) > -1
    " As an optimization, we are not doing the search if the `end` has
    " no whitespace before it, indicating that there is no possibility
    " for a hanging indent.
    if first_idx == 0
      return lnum
    endif

    call cursor(lnum, 1)

    let found = searchpair(s:start_re, "", '\<end\>', "bW", s:skip_word_postfix)
    let word = expand("<cword>")

    if word ==# "do" || word =~# s:hanging_re
      return s:get_msl(found)
    else
      return found
    endif
  else
    call cursor(lnum, 1)

    let [last_char, last_col, prev_lnum, _] = s:get_last_char()

    if last_char == "," || last_char == '\' || synID(prev_lnum, last_col, 0) == g:crystal#operator
      return s:get_msl(prev_lnum)
    endif
  endif

  " If none of the above are true, this line is the MSL.
  return lnum
endfunction

function! GetCrystalIndent(lnum) abort
  let prev_lnum = prevnonblank(a:lnum - 1)

  if !prev_lnum
    return 0
  endif

  " Current line {{{1
  " If the current line is inside of an ignorable multiline region, do
  " nothing.
  if get(g:crystal#multiline_regions, synID(a:lnum, 1, 0))
    return -1
  endif

  " If the first character of the current line is a leading dot, add an
  " indent unless the previous logical line also started with a leading
  " dot.
  let line = getline(a:lnum)
  let [first_char, first_idx, _] = matchstrpos(line, '\S')

  if first_char == "."
    let prev_lnum = s:prev_non_multiline(prev_lnum)
    let prev_line = getline(prev_lnum)
    let [first_char, first_idx, _] = matchstrpos(prev_line, '\S')

    if first_char == "."
      return first_idx
    else
      return first_idx + shiftwidth()
    endif
  endif

  " If the first character is a closing bracket, align with the line
  " that contains the opening bracket.
  if first_char == ")"
    return indent(searchpair("(", "", ")", "bW", s:skip_char))
  elseif first_char == "]"
    return indent(searchpair("\\[", "", "]", "bW", s:skip_char))
  elseif first_char == "}"
    return indent(searchpair("{", "", "}", "bW", s:skip_char))
  endif

  " If the first character is a macro delimiter and the first word after
  " the delimiter is a deindenting keyword, align with the nearest
  " indenting keyword that is also after a macro delimiter.
  if first_char == "{" && line[first_idx + 1] == "%"
    let word = matchstr(line, '^\s*\zs\l\w*', first_idx + 2)

    if word =~# '\v<%(end|else|elsif)>'
      call cursor(a:lnum, 1)
      call searchpair(s:macro_start_re, s:macro_middle_re, s:macro_end_re, "bW", s:skip_word)
      let [_, col] = searchpairpos("{%", "", "%}", "bW", s:skip_macro_delimiter)

      return col - 1
    endif
  elseif first_char == '\' && match(line, '^{%', first_idx + 1) > -1
    let word = matchstr(line, '^\s*\zs\l\w*', first_idx + 3)

    if word =~# '\v<%(end|else|elsif)>'
      call cursor(a:lnum, 1)
      call searchpair(s:slash_macro_start_re, s:slash_macro_middle_re, s:slash_macro_end_re, "bW", s:skip_word)
      let [_, col] = searchpairpos('\\{%', "", "%}", "bW", s:skip_macro_delimiter)

      return col - 1
    endif
  endif

  " If the first word is a deindenting keyword, align with the nearest
  " indenting keyword.
  let first_word = matchstr(line, '^\l\w*', first_idx)

  call cursor(a:lnum, 1)

  if first_word ==# "end"
    let [lnum, col] = searchpairpos(s:start_re, s:middle_re, '\<end\>', "bW", s:skip_word_postfix)
    let word = expand("<cword>")

    if word =~# s:hanging_re
      return col - 1
    else
      return indent(lnum)
    endif
  elseif first_word ==# "else"
    let [_, col] = searchpairpos(s:hanging_re, s:middle_re, '\<end\>', "bW", s:skip_word_postfix)
    return col - 1
  elseif first_word ==# "elsif"
    let [_, col] = searchpairpos('\v<%(if|unless)', '\<elsif\>', '\<end\>', "bW", s:skip_word_postfix)
    return col - 1
  elseif first_word ==# "when"
    let [_, col] = searchpairpos('\<case\>', '\<when\>', '\<end\>', "bW", s:skip_word)
    return col - 1
  elseif first_word ==# "in"
    let [_, col] = searchpairpos('\<case\>', '\<in\>', '\<end\>', "bW", s:skip_word)
    return col - 1
  elseif first_word ==# "rescue"
    let [lnum, col] = searchpairpos(s:exception_re, '\<rescue\>', '\<end\>', "bW", s:skip_word)

    if expand("<cword>") ==# "begin"
      return col - 1
    else
      return indent(lnum)
    endif
  elseif first_word ==# "ensure"
    let [lnum, col] = searchpairpos(s:exception_re, '\v<%(rescue|else)>', '\<end\>', "bW", s:skip_word)

    if expand("<cword>") ==# "begin"
      return col - 1
    else
      return indent(lnum)
    endif
  endif

  " Previous line {{{1
  " Begin by finding the previous non-comment character in the file.
  let [last_char, last_col, prev_lnum, prev_line] = s:get_last_char()

  " If the last character was a backslash, add an indent unless the line
  " before it also ended with a backslash.
  if last_char == '\'
    call cursor(s:prev_non_multiline(prev_lnum), 1)

    let [last_char, _, _, _] = s:get_last_char()

    if last_char == '\'
      return indent(prev_lnum)
    else
      return indent(prev_lnum) + shiftwidth()
    endif
  endif

  " If the last character was a comma, check the following:
  "
  " 1. If the comma is preceded by an unpaired opening bracket somewhere
  " in the same line, align with the bracket.
  " 2. If the next previous line also ended with a comma or it ended
  " with an opening bracket, align with the beginning of the previous
  " line.
  " 3. If the next previous line is not its own MSL, align with the MSL.
  " 4. Else, add an indent.
  if last_char == ","
    let [_, col] = searchpairpos('[([{]', "", '[)\]}]', "b", s:skip_char, prev_lnum)

    if col
      return col
    endif

    call cursor(prev_lnum, 1)
    let [last_char, _, _, _] = s:get_last_char()

    if last_char =~ '[,([{]'
      return indent(prev_lnum)
    endif

    let msl = s:get_msl(prev_lnum)

    if msl != prev_lnum
      return indent(msl)
    endif

    return indent(prev_lnum) + shiftwidth()
  endif

  " If the last character was an opening bracket, add an indent.
  if last_char =~ '[([{]'
    return indent(prev_lnum) + shiftwidth()
  endif

  let synid = synID(prev_lnum, last_col, 0)

  " If the last character was a block parameter delimiter, add an
  " indent.
  if synid == g:crystal#block_parameter_delimiter
    return indent(prev_lnum) + shiftwidth()
  endif

  " If the last character was a hanging operator, add an indent unless
  " the line before it also ended with a hanging operator.
  if synid == g:crystal#operator
    call cursor(s:prev_non_multiline(prev_lnum), 1)

    let [_, last_col, prev_prev_lnum, _] = s:get_last_char()

    if synID(prev_prev_lnum, last_col, 0) == g:crystal#operator
      return indent(prev_lnum)
    else
      return indent(prev_lnum) + shiftwidth()
    endif
  endif

  " MSL {{{1
  let msl = s:get_msl(prev_lnum)

  " Find the last keyword in the previous logical line.
  call cursor(prev_lnum, last_col)

  while search('\<\l', "b", msl)
    let lnum = line(".")
    let col = col(".")

    if synID(lnum, col, 0) != g:crystal#keyword
      continue
    endif

    let word = expand("<cword>")

    if word ==# "end"
      if search('{%\s*\%#', "b")
        if search('\\\%#', "b")
          let lnum = searchpair(s:slash_macro_start_re, "", s:slash_macro_end_re, "bW", s:skip_word)
        else
          let lnum = searchpair(s:macro_start_re, "", s:macro_end_re, "bW", s:skip_word)
        endif
      else
        let lnum = msl
      endif

      return indent(lnum)
    elseif word ==# "if" || word ==# "unless"
      let [_, prev_col] = searchpos('\S', "b", lnum)

      if !prev_col
        return col - 1 + shiftwidth()
      endif

      let synid = synID(lnum, prev_col, 0)

      if synid == g:crystal#macro_delimiter
        let [_, prev_col] = searchpos('\\\={\%#', "b")
        return prev_col - 1 + shiftwidth()
      elseif synid == g:crystal#operator
        return col - 1 + shiftwidth()
      else
        return indent(msl)
      endif
    elseif word =~# '\v<%(begin|else|elsif)>'
      let [_, found_col] = searchpos('\\\={%\s*\%#', "b")

      if found_col
        let col = found_col
      endif

      return col - 1 + shiftwidth()
    elseif word ==# "case"
      return col - 1 + shiftwidth()
    elseif word ==# "then"
      let found = search('\<')

      if found == lnum
        return indent(msl)
      else
        return indent(msl) + shiftwidth()
      endif
    elseif word ==# "do"
      return indent(lnum) + shiftwidth()
    elseif word =~# '\v<%(when|in|forall|while|until|rescue|ensure|def|macro|class|struct|lib|annotation|enum|module)>'
      return indent(msl) + shiftwidth()
    else
      return indent(msl)
    endif
  endwhile
  " }}}1

  " Default
  return indent(msl)
endfunction

" vim:fdm=marker