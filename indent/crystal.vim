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

" if has("nvim-0.5")
"   lua get_crystal_indent = require("get_crystal_indent")
"   setlocal indentexpr=v:lua.get_crystal_indent()
"   finish
" endif

setlocal indentexpr=GetCrystalIndent()

if exists("*GetCrystalIndent")
  finish
endif

" Helpers {{{
let s:start_re = '\<\%(def\|macro\|class\|struct\|module\|enum\|annotation\|lib\|union\|if\|unless\|while\|until\|for\|begin\|do\)\>:\@!'
let s:middle_re = '\<\%(else\|elsif\|when\|in\|rescue\|ensure\)\>:\@!'
let s:end_re = '\<end\>:\@!'

let s:keyword_dedent_re = '^\%(end\|else\|elsif\|when\|in\|rescue\|ensure\)\>:\@!'

if get(g:, "crystal_highlight_definitions")
  function s:skip_keyword()
    let synid = synID(line("."), col("."), 0)
    return synid != g:crystal#keyword && synid != g:crystal#define
  endfunction

  let s:skip_keyword_expr = function("s:skip_keyword")
else
  let s:skip_keyword_expr = 'synID(line("."), col("."), 0) != g:crystal#keyword'
endif

function s:prev_non_multiline(lnum)
  let lnum = a:lnum

  while get(g:crystal#multiline_regions, synID(lnum, 1, 0))
    let lnum -= 1
  endwhile

  return lnum
endfunction

function s:is_operator(char, lnum, col, line)
  if a:char =~# '[%&+\-/:<=>^|~]'
    return synID(a:lnum, a:col, 0) == g:crystal#operator
  elseif a:char =~# '[*?]'
    " Find the first character prior to this one that isn't also a * or
    " ?.
    for i in range(a:col - 2, 0, -1)
      let char = a:line[i]

      if char !~# '[*?]'
        if char =~# '\s'
          return synID(a:lnum, a:col, 0) == g:crystal#operator
        else
          return 0
        endif
      endif
    endfor
  endif
endfunction

function s:get_last_char(lnum)
  " First, try to find a comment delimiter: if one is found, the
  " non-whitespace character immediately before it is the last
  " character; else, simply find the last non-whitespace character in
  " the line.
  let line = getline(a:lnum)
  let found = -1

  while 1
    let found = stridx(line, "#", found + 1)

    if found == -1
      let [char, pos, _] = matchstrpos(line, '\S\ze\s*$')
      return [char, pos, line]
    elseif found == 0
      return [-1, -1, -1]
    endif

    if synID(a:lnum, found + 1, 0) == g:crystal#comment_delimiter
      break
    endif
  endwhile

  let [char, pos, _] = matchstrpos(line[:found - 1], '\S\ze\s*$')
  return [char, pos, line]
endfunction
" }}}

" GetCrystalIndent {{{
if get(g:, "crystal_simple_indent")
  " Simple {{{
  function GetCrystalIndent() abort
    " If the current line is inside of a multiline region, do nothing.
    if get(g:crystal#multiline_regions, synID(v:lnum, 1, 0))
      return -1
    endif

    let prev_lnum = prevnonblank(v:lnum - 1)

    if prev_lnum == 0
      return 0
    endif

    " Retrieve indentation info for the previous line.
    let [last_char, last_idx, prev_line] = s:get_last_char(prev_lnum)

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

      if get(g:crystal#multiline_regions, synID(prev_lnum, 1, 0))
        let start_lnum = s:prev_non_multiline(prevnonblank(prev_lnum - 1))
        let start_line = getline(prev_lnum)
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
      else
        let lnum = prevnonblank(start_lnum - 1)

        if lnum
          let [char, idx, line] = s:get_last_char(lnum)

          if idx != -1
            if char ==# '\'
              let continuation = 1
            elseif char ==# ","
              let continuation = 2
            elseif char =~# '[(\[{]'
              let continuation = 3
            elseif s:is_operator(char, lnum, idx + 1, line)
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

    let keyword_dedent = 0

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

      if last_char ==# "{" || (last_char ==# "|" && synID(prev_lnum, last_idx + 1, 0) == g:crystal#delimiter)
        let shift = 0
      endif

      if continuation == 1
        let shift += 1
      endif

      return first_idx - shift * shiftwidth()
    elseif char ==# '\'
      if match(line, '{%\s*\%(end\|els\%(e\|if\)\)\>', idx + 1) != -1
        let keyword_dedent = 1
      endif
    elseif char ==# "{"
      if match(line, '%\s*\%(end\|els\%(e\|if\)\)\>', idx + 1) != -1
        let keyword_dedent = 1
      endif
    elseif match(line, s:keyword_dedent_re, idx) != -1
      let keyword_dedent = 1
    endif

    if keyword_dedent
      if searchpair(s:start_re, s:middle_re, s:end_re, "b", s:skip_keyword_expr, start_lnum)
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
          \ || (last_char ==# "|" && synID(prev_lnum, last_idx + 1, 0) == g:crystal#delimiter)
          \ || s:is_operator(last_char, prev_lnum, last_idx + 1, prev_line)
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

        if !searchpair(s:start_re, s:middle_re, s:end_re, "cz", s:skip_keyword_expr, prev_lnum)
          let shift += 1
        endif
      elseif continuation == 1
        let shift -= 1
      endif

      return first_idx + shift * shiftwidth()
    endif

    if searchpair(s:start_re, s:middle_re, s:end_re, "b", s:skip_keyword_expr, start_lnum)
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
    if get(g:crystal#multiline_regions, synID(v:lnum, 1, 0))
      return -1
    endif

    let prev_lnum = prevnonblank(v:lnum - 1)

    if prev_lnum == 0
      return 0
    endif

    " Retrieve indentation info for the previous line.
    let [last_char, last_idx, prev_line] = s:get_last_char(prev_lnum)

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

      if get(g:crystal#multiline_regions, synID(prev_lnum, 1, 0))
        let start_lnum = s:prev_non_multiline(prevnonblank(prev_lnum - 1))
        let start_line = getline(prev_lnum)
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
      else
        let lnum = prevnonblank(start_lnum - 1)

        if lnum
          let [char, idx, line] = s:get_last_char(lnum)

          if idx != -1
            if char ==# '\'
              let continuation = 1
            elseif char ==# ","
              let continuation = 2
            elseif char =~# '[(\[{]'
              let continuation = 3
            elseif s:is_operator(char, lnum, idx + 1, line)
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

    let keyword_dedent = 0

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

      if last_char ==# "{" || (last_char ==# "|" && synID(prev_lnum, last_idx + 1, 0) == g:crystal#delimiter)
        let shift = 0
      endif

      if continuation == 1
        let shift += 1
      endif

      return first_idx - shift * shiftwidth()
    elseif char ==# '\'
      if match(line, '{%\s*\%(end\|els\%(e\|if\)\)\>', idx + 1) != -1
        let keyword_dedent = 1
      endif
    elseif char ==# "{"
      if match(line, '%\s*\%(end\|els\%(e\|if\)\)\>', idx + 1) != -1
        let keyword_dedent = 1
      endif
    elseif match(line, s:keyword_dedent_re, idx) != -1
      let keyword_dedent = 1
    endif

    if keyword_dedent
      if searchpair(s:start_re, s:middle_re, s:end_re, "b", s:skip_keyword_expr, start_lnum)
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
          \ || (last_char ==# "|" && synID(prev_lnum, last_idx + 1, 0) == g:crystal#delimiter)
          \ || s:is_operator(last_char, prev_lnum, last_idx + 1, prev_line)
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

        if !searchpair(s:start_re, s:middle_re, s:end_re, "cz", s:skip_keyword_expr, prev_lnum)
          let shift += 1
        endif
      elseif continuation == 1
        let shift -= 1
      endif

      return first_idx + shift * shiftwidth()
    endif

    if searchpair(s:start_re, s:middle_re, s:end_re, "b", s:skip_keyword_expr, start_lnum)
      let shift = 1
    elseif continuation == 1 || continuation == 2
      let shift = -1
    else
      let shift = 0
    endif

    return first_idx + shift * shiftwidth()
  endfunction
  " }}}
endif
" }}}

" vim:fdm=marker
