" Vim indent file
" Language: Crystal <crystal-lang.org>
" Author: Jeffrey Crochet <jlcrochet@pm.me>
" URL: https://github.com/jlcrochet/vim-crystal

if get(b:, "did_indent")
  finish
endif

let b:did_indent = 1

setlocal indentkeys=0),0],0},.,o,O,!^F
setlocal indentkeys+==end,=else,=elsif,0=when,0=in,0=rescue,0=ensure

if has("nvim-0.5")
  lua get_crystal_indent = require("get_crystal_indent")
  setlocal indentexpr=v:lua.get_crystal_indent()
  finish
endif

setlocal indentexpr=GetCrystalIndent()

if exists("*GetCrystalIndent")
  finish
endif

" Helpers {{{
let s:kw_start_re = '\<\%(def\|macro\|class\|struct\|module\|enum\|annotation\|lib\|union\|if\|unless\|case\|while\|until\|for\|begin\|do\):\@!\>'
let s:kw_middle_re = '\<\%(else\|elsif\|when\|in\|rescue\|ensure\):\@!\>'
let s:kw_end_re = '\<end:\@!\>'

let s:start_pair_re = s:kw_start_re . '\|[(\[{]'
let s:end_pair_re = s:kw_end_re . '\|[)\]}]'

let s:kw_dedent_re = '^\%(end\|else\|elsif\|when\|in\|rescue\|ensure\):\@!\>'

let s:floating_re = '\<\%(\(if\|unless\|begin\)\|\(case\|until\|while\)\|\(else\|elsif\|ensure\|in\|rescue\|when\)\|\(annotation\|class\|def\|enum\|lib\|macro\|module\|struct\|union\)\|\(do\)\|\(end\)\):\@!\>\|\([(\[{]\)\|\([)\]}]\)\|\(|\)'

if get(g:, "crystal_highlight_definitions")
  function s:skip_keyword()
    let synid = synID(line("."), col("."), 0)
    return synid != g:crystal#indent#keyword && synid != g:crystal#indent#define && synid != g:crystal#indent#block_control && synid != g:crystal#indent#define_block_control
  endfunction

  function s:skip_pair()
    let synid = synID(line("."), col("."), 0)
    return synid != g:crystal#indent#keyword && synid != g:crystal#indent#define && synid != g:crystal#indent#block_control && synid != g:crystal#indent#define_block_control && synid != g:crystal#indent#delimiter
  endfunction

  let s:skip_keyword_expr = function("s:skip_keyword")
  let s:skip_pair_expr = function("s:skip_pair")
else
  let s:skip_keyword_expr = 'synID(line("."), col("."), 0) != g:crystal#indent#keyword'
endif

function s:prev_non_multiline(lnum)
  let lnum = a:lnum

  while get(g:crystal#indent#multiline_regions, synID(lnum, 1, 0))
    let lnum -= 1
  endwhile

  return lnum
endfunction

function s:is_operator(char, col, line, lnum)
  if a:char =~# '[%&+\-/:<=>^|~]'
    return synID(a:lnum, a:col, 0) == g:crystal#indent#operator
  elseif a:char =~# '[*?]'
    " Find the first character prior to this one that isn't also a * or
    " ?.
    for i in range(a:col - 2, 0, -1)
      let char = a:line[i]

      if char !~# '[*?]'
        if char =~# '[[:alnum:]_)\]}]'
          return 0
        else
          return synID(a:lnum, a:col, 0) == g:crystal#indent#operator
        endif
      endif
    endfor
  endif
endfunction

function s:get_last_char(lnum, line)
  " First, try to find a comment delimiter: if one is found, the
  " non-whitespace character immediately before it is the last
  " character; else, simply find the last non-whitespace character in
  " the line.
  let found = -1

  while 1
    let found = stridx(a:line, "#", found + 1)

    if found == -1
      let [char, pos, _] = matchstrpos(a:line, '\S\ze\s*$')
      return [char, pos]
    elseif found == 0
      return [-1, -1]
    endif

    if synID(a:lnum, found + 1, 0) == g:crystal#indent#comment_delimiter
      break
    endif
  endwhile

  let [char, pos, _] = matchstrpos(a:line[:found - 1], '\S\ze\s*$')
  return [char, pos]
endfunction

function s:find_floating_index(lnum, i, j)
  call cursor(a:lnum, a:j + 1)

  let pairs = 0
  let [_, col, p] = searchpos(s:floating_re, "bcp", a:lnum)

  while col >= a:i + 1
    if p == 2  " if unless begin
      if synID(a:lnum, col, 0) == g:crystal#indent#keyword
        if pairs == 0
          " If this is a macro tag keyword, return the index for the macro
          " tag.
          let [_, col2] = searchpos('\\\={%\s*\%#', "b", a:lnum)

          if col2
            return col2 - 1
          else
            return col - 1
          endif
        else
          let pairs += 1
        endif
      endif
    elseif p == 3  " case while until
      if synID(a:lnum, col, 0) == g:crystal#indent#keyword
        if pairs == 0
          return col - 1
        else
          let pairs += 1
        endif
      endif
    elseif p == 4  " else elsif ensure in rescue when
      if pairs == 0
        let synid = synID(a:lnum, col, 0)

        if synid == g:crystal#indent#keyword || synid == g:crystal#indent#block_control || synid == g:crystal#indent#define_block_control
          return a:i
        endif
      endif
    elseif p == 5  " annotation class def enum lib macro module struct union
      if synID(a:lnum, col, 0) == g:crystal#indent#define
        if pairs == 0
          return a:i
        else
          let pairs += 1
        endif
      endif
    elseif p == 6  " do
      if synID(a:lnum, col, 0) == g:crystal#indent#keyword
        if pairs == 0
          return a:i
        else
          let pairs += 1
        endif
      endif
    elseif p == 7  " end
      let synid = synID(a:lnum, col, 0)

      if synid == g:crystal#indent#keyword || synid == g:crystal#indent#define
        let pairs -= 1
      endif
    elseif p == 8  " ( [ {
      if synID(a:lnum, col, 0) == g:crystal#indent#delimiter
        if pairs == 0
          let [_, col2] = searchpos('\S', "z", a:lnum)

          if col2
            return col2 - 1
          else
            return a:i
          endif
        else
          let pairs += 1
        endif
      endif
    elseif p == 9  " ) ] }
      if synID(a:lnum, col, 0) == g:crystal#indent#delimiter
        let pairs -= 1
      endif
    elseif p == 10  " |
      if synID(a:lnum, col, 0) == g:crystal#indent#delimiter
        if pairs == 0
          return a:i
        endif
      endif
    endif

    let [_, col, p] = searchpos(s:floating_re, "bp", a:lnum)
  endwhile

  return -1
endfunction

function s:find_msl(skip_commas, pairs)
  let [lnum, col] = searchpos('\S', "czW")
  let prev_lnum = prevnonblank(lnum - 1)

  if prev_lnum == 0
    return [lnum, col - 1, 0]
  endif

  " This line is *not* the MSL if:

  " It is part of a multiline region.
  if get(g:crystal#indent#multiline_regions, synID(lnum, 1, 0))
    call cursor(prev_lnum, 1)
    return s:find_msl(a:skip_commas, v:null)
  endif

  " It starts with a leading dot.
  let line = getline(lnum)

  if match(line, '^\.\.\@!', col - 1) != -1
    call cursor(prev_lnum, 1)
    return s:find_msl(a:skip_commas, v:null)
  endif

  " It contains a positive number of unpaired closing brackets or
  " keywords; find the corresponding starting line...
  "
  " *unless* the line starts with an `end` that is part of a definition.
  if a:pairs == v:null
    let pairs = 0

    if match(line, '^end:\@!\>', col - 1) != -1
      if col == 1
        return [lnum, col - 1, 0]
      endif

      if synID(lnum, col, 0) == g:crystal#indent#define
        return [lnum, col - 1, 0]
      endif

      let pairs = -searchpair(s:start_pair_re, "", s:end_pair_re, "mnrz", s:skip_pair_expr, lnum) - 1
    else
      let pairs = -searchpair(s:start_pair_re, "", s:end_pair_re, "cmnrz", s:skip_pair_expr, lnum)
    endif

    if pairs < 0
      while pairs < 0
        let lnum = searchpair(s:start_pair_re, "", s:end_pair_re, "bW", s:skip_pair_expr)
        let pairs += 1
      endwhile

      let pairs = searchpair(s:start_pair_re, "", s:end_pair_re, "bmr", s:skip_pair_expr, lnum)

      call cursor(0, 1)
      return s:find_msl(a:skip_commas, pairs)
    endif
  else
    let pairs = a:pairs
  endif

  " The previous line ends with a comma, backslash, or hanging operator.
  let prev_line = getline(prev_lnum)
  let [last_char, last_idx] = s:get_last_char(prev_lnum, prev_line)

  if last_char ==# ","
    if !a:skip_commas
      call cursor(prev_lnum, 1)
      return s:find_msl(0, v:null)
    endif
  elseif last_char ==# '\' || s:is_operator(last_char, last_idx + 1, prev_line, prev_lnum)
    call cursor(prev_lnum, 1)
    return s:find_msl(a:skip_commas, v:null)
  endif

  " Else, this line is the MSL.
  return [lnum, col - 1, pairs > 0]
endfunction
" }}}

" GetCrystalIndent {{{
if get(g:, "crystal_simple_indent")
  " Simple {{{
  function GetCrystalIndent() abort
    " If the current line is inside of a multiline region, do nothing.
    if get(g:crystal#indent#multiline_regions, synID(v:lnum, 1, 0))
      return -1
    endif

    let prev_lnum = prevnonblank(v:lnum - 1)

    if prev_lnum == 0
      return 0
    endif

    " Retrieve indentation info for the previous line.
    let prev_line = getline(prev_lnum)
    let [last_char, last_idx] = s:get_last_char(prev_lnum, prev_line)

    " This variable tells whether or not the previous line is
    " a continuation of another line.
    " 0 -> no continuation
    " 1 -> continuation caused by a backslash or hanging operator
    " 2 -> continuation caused by a comma (list continuation)
    " 3 -> continuation caused by an opening bracket
    let continuation = 0

    if last_idx != -1
      " If the previous line begins in a multiline region, find the line
      " that began that region.

      if get(g:crystal#indent#multiline_regions, synID(prev_lnum, 1, 0))
        let start_lnum = s:prev_non_multiline(prevnonblank(prev_lnum - 1))
        let start_line = getline(start_lnum)
      else
        let start_lnum = prev_lnum
        let start_line = prev_line
      endif

      " Find the first column and first character of the line.
      let [first_char, first_idx, _] = matchstrpos(start_line, '\S')

      " Determine whether or not the line is a continuation.
      if first_char ==# "."
        if start_line[first_idx + 1] !=# "."
          let continuation = 1
        endif
      elseif first_char !~# '[\]}]'
        let lnum = prevnonblank(start_lnum - 1)

        if lnum
          let line = getline(lnum)
          let [char, idx] = s:get_last_char(lnum, line)

          if idx != -1
            if char ==# '\'
              let continuation = 1
            elseif char ==# ","
              let continuation = 2
            elseif char =~# '[(\[{]'
              let continuation = 3
            elseif s:is_operator(char, idx + 1, line, lnum)
              let continuation = 1
            endif
          endif
        endif
      endif
    else
      " The previous line is a comment line.
      let first_idx = last_idx
      let start_lnum = prev_lnum
      let start_line = prev_line
    endif

    " Find the first character in the current line.
    let line = getline(v:lnum)

    let [char, idx, _] = matchstrpos(line, '\S')

    if char ==# "."
      " If the current line begins with a leading dot, add a shift unless
      " the previous line was a line continuation.

      if line[idx + 1] !=# "."
        if continuation == 1
          return first_idx
        else
          return first_idx + shiftwidth()
        endif
      endif
    elseif char ==# ")"
      " If the current line begins with a closing bracket, subtract
      " a shift unless the previous character was the corresponding
      " bracket; subtract an additional shift if the previous line was
      " a continuation.

      let shift = 1

      if last_char ==# "("
        let shift = 0
      endif

      if continuation == 1
        let shift += 1
      endif

      return first_idx - shift * shiftwidth()
    elseif char ==# "]"
      let shift = 1

      if last_char ==# "["
        let shift = 0
      endif

      if continuation == 1
        let shift += 1
      endif

      return first_idx - shift * shiftwidth()
    elseif char ==# "}"
      let shift = 1

      if last_char ==# "{" || (last_char ==# "|" && synID(prev_lnum, last_idx + 1, 0) == g:crystal#indent#delimiter)
        let shift = 0
      endif

      if continuation == 1
        let shift += 1
      endif

      return first_idx - shift * shiftwidth()
    elseif match(line, s:kw_dedent_re, idx) != -1 || match(line, '^\\\={%\s*\%(end\|else\|elsif\)\>', idx) != -1
      call cursor(prev_lnum, last_idx)

      if searchpair(s:kw_start_re, s:kw_middle_re, s:kw_end_re, "b", s:skip_keyword_expr, start_lnum)
        return first_idx
      else
        return first_idx - shiftwidth()
      endif
    endif

    " If we can't determine the indent from the current line, examine the
    " previous line.

    if last_idx == -1
      return first_idx
    endif

    if (last_char =~# '[\\(\[{]')
          \ || (last_char ==# "|" && synID(prev_lnum, last_idx + 1, 0) == g:crystal#indent#delimiter)
          \ || s:is_operator(last_char, last_idx + 1, prev_line, prev_lnum)
      if continuation == 1
        return first_idx
      else
        return first_idx + shiftwidth()
      endif
    elseif last_char ==# ","
      " If the last character was a comma:
      "
      " If the previous line was not a continuation, add a shift unless it
      " has unpaired `end`s.
      " If the previous line was an operator continuation, subtract
      " a shift.

      let shift = 0

      if continuation == 0
        call cursor(prev_lnum, 1)

        if !searchpair(s:kw_start_re, s:kw_middle_re, s:kw_end_re, "cz", s:skip_keyword_expr, prev_lnum)
          let shift += 1
        endif
      elseif continuation == 1
        let shift -= 1
      endif

      return first_idx + shift * shiftwidth()
    endif

    if searchpair(s:kw_start_re, s:kw_middle_re, s:kw_end_re, "b", s:skip_keyword_expr, start_lnum)
      let shift = 1
    elseif continuation == 1 || continuation == 2
      let shift = -1
    else
      let shift = 0
    endif

    return first_idx + shift * shiftwidth()
  endfunction
  " }}}
else
  " Default {{{
  function GetCrystalIndent() abort
    " If the current line is inside of a multiline region, do nothing.
    if get(g:crystal#indent#multiline_regions, synID(v:lnum, 1, 0))
      return -1
    endif

    let prev_lnum = prevnonblank(v:lnum - 1)

    if prev_lnum == 0
      return 0
    endif

    " Retrieve indentation info for the previous line.
    let prev_line = getline(prev_lnum)
    let [last_char, last_idx] = s:get_last_char(prev_lnum, prev_line)

    " Before we proceed, we need to determine which column we will use
    " as the starting position.
    "
    " If there is a floating column somehwere in the previous line, that
    " is the starting column.
    "
    " Else, the first column of the previous line is the starting
    " position.
    let first_idx = match(prev_line, '\S')

    let pos = getcurpos()
    let floating_idx = s:find_floating_index(prev_lnum, first_idx, last_idx)
    call setpos(".", pos)

    let start_idx = floating_idx != -1 ? floating_idx : first_idx

    " Check the last character of the previous line.
    if last_char ==# '\' || s:is_operator(last_char, last_idx + 1, prev_line, prev_lnum)
      " If the previous line ends with a hanging operator or
      " backslash...

      " Find the next previous line.
      let prev_prev_lnum = prevnonblank(prev_lnum - 1)

      if prev_prev_lnum
        let prev_prev_line = getline(prev_prev_lnum)
        let [prev_last_char, prev_last_idx] = s:get_last_char(prev_prev_lnum, prev_prev_line)

        " If the next previous line also ends with a hanging operator or
        " backslash...
        if prev_last_char ==# '\' || s:is_operator(prev_last_char, prev_last_idx + 1, prev_prev_line, prev_prev_lnum)
          " Align with the starting column.
          return start_idx
        endif
      endif

      " Else, find the first operator in the previous line.
      let idx = 0
      let offset = 0

      while idx != -1
        let [char, idx, offset] = matchstrpos(prev_line, '[%&+\-/:<=>^|~]\|[[:alnum:]_)\]}]\@1<![*?]\+', offset)

        if synID(prev_lnum, idx + 1, 0) == g:crystal#indent#operator
          " Find the first non-whitespace column after the operator that
          " is not also an operator.
          let [char, idx, _] = matchstrpos(prev_line, '[^[:space:]%&+\-/:<=>^|~*?]', offset)

          if idx != -1 && char !=# "#"
            " If one is found and it is not a comment delimiter, align
            " with it.
            return idx
          else
            " Else, align with the first column of the previous line and
            " add a shift.
            return start_idx + shiftwidth()
          endif
        endif
      endwhile

      " If one could not be found, align with the first column of the
      " previous line and add a shift.
      return start_idx + shiftwidth()
    elseif last_char ==# ","
      " If the previous line ends with a comma...

      " First, find the MSL of the previous line.
      call cursor(prev_lnum, 1)
      let [msl, ind, _] = s:find_msl(1, v:null)

      " Find the line prior to the MSL.
      let prev_prev_lnum = prevnonblank(msl - 1)

      if prev_prev_lnum
        let prev_prev_line = getline(prev_prev_lnum)
        let [prev_last_char, prev_last_idx] = s:get_last_char(prev_prev_lnum, prev_prev_line)

        if prev_last_char =~# '[,(\[{]'
          " If the next previous line also ended with a comma or an
          " opening bracket, align with the MSL, unless the current line
          " begins with a closing bracket.
          if getline(v:lnum) =~# '^\s*[)\]}]'
            return ind - shiftwidth()
          endif

          return ind
        elseif prev_last_char ==# '\' || s:is_operator(prev_last_char, prev_last_idx + 1, prev_prev_line, prev_prev_lnum)
          " If the next previous line ended with a backslash or hanging
          " operator, align with the MSL.
          return ind
        endif
      endif

      " Else, align with the previous line and add a shift.
      if floating_idx != -1
        return floating_idx
      else
        return first_idx + shiftwidth()
      endif
    elseif last_char =~# '[(\[{]' || last_char ==# "|" && synID(prev_lnum, last_idx + 1, 0) == g:crystal#indent#delimiter
      " If the previous line ends with an opening bracket, align with
      " the starting column and add a shift unless the current line
      " begins with a closing bracket or `end`.
      if getline(v:lnum) =~# '^\s*\%([)\]}]\|end:\@!\>\)'
        return start_idx
      else
        return start_idx + shiftwidth()
      endif
    endif

    " Next, examine the first character of the current line.
    let line = getline(v:lnum)
    let [char, idx, _] = matchstrpos(line, '\S')

    if char ==# "."
      " If the current line starts with a leading dot:
      "
      " If the previous line also started with a leading dot, align with
      " the previous line.
      "
      " Else, align with the first leading dot in the previous line, if
      " any.
      "
      " Else, add a shift.
      if line[idx + 1] !=# "."
        let idx = match(prev_line, '\.\.\@!', first_idx)

        if idx != -1
          return idx
        else
          return start_idx + shiftwidth()
        endif
      endif
    elseif char =~# '[)\]}]'
      " If the current line begins with a closing bracket, subtract
      " a shift.
      if floating_idx != -1
        return floating_idx
      else
        call cursor(prev_lnum, 1)
        let [_, ind, _] = s:find_msl(1, v:null)
        return ind - shiftwidth()
      endif
    elseif match(line, s:kw_dedent_re, idx) != -1 || match(line, '^\\\={%\s*\%(end\|else\|elsif\)\>', idx) != -1
      if floating_idx != -1
        return floating_idx
      else
        call cursor(prev_lnum, 1)
        let [_, ind, _] = s:find_msl(0, v:null)
        return ind - shiftwidth()
      endif
    endif

    if floating_idx != -1
      return floating_idx + shiftwidth()
    else
      call cursor(prev_lnum, 1)
      let [_, ind, shift] = s:find_msl(0, v:null)

      if shift
        let ind += shiftwidth()
      endif

      return ind
    endif
  endfunction
  " }}}
endif
" }}}

" vim:fdm=marker
