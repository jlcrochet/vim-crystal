" Vim indent file
" Language: Crystal <crystal-lang.org>
" Author: Jeffrey Crochet <jlcrochet@hey.com>
" URL: https://github.com/jlcrochet/vim-crystal

if get(b:, "did_indent")
  finish
endif

let b:did_indent = 1

" Generated by tools/indent.vim:
setlocal indentkeys=0),0],0},0.,0=..,o,O,!^F,=end,=end0,=end1,=end2,=end3,=end4,=end5,=end6,=end7,=end8,=end9,=endA,=endB,=endC,=endD,=endE,=endF,=endG,=endH,=endI,=endJ,=endK,=endL,=endM,=endN,=endO,=endP,=endQ,=endR,=endS,=endT,=endU,=endV,=endW,=endX,=endY,=endZ,=enda,=endb,=endc,=endd,=ende,=endf,=endg,=endh,=endi,=endj,=endk,=endl,=endm,=endn,=endo,=endp,=endq,=endr,=ends,=endt,=endu,=endv,=endw,=endx,=endy,=endz,=end_,=end?,=end!,=end:,=else,=else0,=else1,=else2,=else3,=else4,=else5,=else6,=else7,=else8,=else9,=elseA,=elseB,=elseC,=elseD,=elseE,=elseF,=elseG,=elseH,=elseI,=elseJ,=elseK,=elseL,=elseM,=elseN,=elseO,=elseP,=elseQ,=elseR,=elseS,=elseT,=elseU,=elseV,=elseW,=elseX,=elseY,=elseZ,=elsea,=elseb,=elsec,=elsed,=elsee,=elsef,=elseg,=elseh,=elsei,=elsej,=elsek,=elsel,=elsem,=elsen,=elseo,=elsep,=elseq,=elser,=elses,=elset,=elseu,=elsev,=elsew,=elsex,=elsey,=elsez,=else_,=else?,=else!,=else:,=elsif,=elsif0,=elsif1,=elsif2,=elsif3,=elsif4,=elsif5,=elsif6,=elsif7,=elsif8,=elsif9,=elsifA,=elsifB,=elsifC,=elsifD,=elsifE,=elsifF,=elsifG,=elsifH,=elsifI,=elsifJ,=elsifK,=elsifL,=elsifM,=elsifN,=elsifO,=elsifP,=elsifQ,=elsifR,=elsifS,=elsifT,=elsifU,=elsifV,=elsifW,=elsifX,=elsifY,=elsifZ,=elsifa,=elsifb,=elsifc,=elsifd,=elsife,=elsiff,=elsifg,=elsifh,=elsifi,=elsifj,=elsifk,=elsifl,=elsifm,=elsifn,=elsifo,=elsifp,=elsifq,=elsifr,=elsifs,=elsift,=elsifu,=elsifv,=elsifw,=elsifx,=elsify,=elsifz,=elsif_,=elsif?,=elsif!,=elsif:,0=when,0=when0,0=when1,0=when2,0=when3,0=when4,0=when5,0=when6,0=when7,0=when8,0=when9,0=whenA,0=whenB,0=whenC,0=whenD,0=whenE,0=whenF,0=whenG,0=whenH,0=whenI,0=whenJ,0=whenK,0=whenL,0=whenM,0=whenN,0=whenO,0=whenP,0=whenQ,0=whenR,0=whenS,0=whenT,0=whenU,0=whenV,0=whenW,0=whenX,0=whenY,0=whenZ,0=whena,0=whenb,0=whenc,0=whend,0=whene,0=whenf,0=wheng,0=whenh,0=wheni,0=whenj,0=whenk,0=whenl,0=whenm,0=whenn,0=wheno,0=whenp,0=whenq,0=whenr,0=whens,0=whent,0=whenu,0=whenv,0=whenw,0=whenx,0=wheny,0=whenz,0=when_,0=when?,0=when!,0=when:,0=in,0=in0,0=in1,0=in2,0=in3,0=in4,0=in5,0=in6,0=in7,0=in8,0=in9,0=inA,0=inB,0=inC,0=inD,0=inE,0=inF,0=inG,0=inH,0=inI,0=inJ,0=inK,0=inL,0=inM,0=inN,0=inO,0=inP,0=inQ,0=inR,0=inS,0=inT,0=inU,0=inV,0=inW,0=inX,0=inY,0=inZ,0=ina,0=inb,0=inc,0=ind,0=ine,0=inf,0=ing,0=inh,0=ini,0=inj,0=ink,0=inl,0=inm,0=inn,0=ino,0=inp,0=inq,0=inr,0=ins,0=int,0=inu,0=inv,0=inw,0=inx,0=iny,0=inz,0=in_,0=in?,0=in!,0=in:,0=rescue,0=rescue0,0=rescue1,0=rescue2,0=rescue3,0=rescue4,0=rescue5,0=rescue6,0=rescue7,0=rescue8,0=rescue9,0=rescueA,0=rescueB,0=rescueC,0=rescueD,0=rescueE,0=rescueF,0=rescueG,0=rescueH,0=rescueI,0=rescueJ,0=rescueK,0=rescueL,0=rescueM,0=rescueN,0=rescueO,0=rescueP,0=rescueQ,0=rescueR,0=rescueS,0=rescueT,0=rescueU,0=rescueV,0=rescueW,0=rescueX,0=rescueY,0=rescueZ,0=rescuea,0=rescueb,0=rescuec,0=rescued,0=rescuee,0=rescuef,0=rescueg,0=rescueh,0=rescuei,0=rescuej,0=rescuek,0=rescuel,0=rescuem,0=rescuen,0=rescueo,0=rescuep,0=rescueq,0=rescuer,0=rescues,0=rescuet,0=rescueu,0=rescuev,0=rescuew,0=rescuex,0=rescuey,0=rescuez,0=rescue_,0=rescue?,0=rescue!,0=rescue:,0=ensure,0=ensure0,0=ensure1,0=ensure2,0=ensure3,0=ensure4,0=ensure5,0=ensure6,0=ensure7,0=ensure8,0=ensure9,0=ensureA,0=ensureB,0=ensureC,0=ensureD,0=ensureE,0=ensureF,0=ensureG,0=ensureH,0=ensureI,0=ensureJ,0=ensureK,0=ensureL,0=ensureM,0=ensureN,0=ensureO,0=ensureP,0=ensureQ,0=ensureR,0=ensureS,0=ensureT,0=ensureU,0=ensureV,0=ensureW,0=ensureX,0=ensureY,0=ensureZ,0=ensurea,0=ensureb,0=ensurec,0=ensured,0=ensuree,0=ensuref,0=ensureg,0=ensureh,0=ensurei,0=ensurej,0=ensurek,0=ensurel,0=ensurem,0=ensuren,0=ensureo,0=ensurep,0=ensureq,0=ensurer,0=ensures,0=ensuret,0=ensureu,0=ensurev,0=ensurew,0=ensurex,0=ensurey,0=ensurez,0=ensure_,0=ensure?,0=ensure!,0=ensure:

if has("nvim-0.5")
  lua require "vim-crystal/get_crystal_indent"
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

let s:block_start_re = '\C\v<%(if|unless|case|select|begin|for|while|until|do)>'
let s:block_middle_re = '\C\v<%(else|elsif|when|in|ensure|rescue)>'

let s:define_block_start_re = '\C\v<%(def|macro|class|struct|lib|annotation|enum|module|union)>'
let s:define_block_middle_re = '\C\v<%(else|ensure|rescue)>'

let s:all_start_re = '\C\v<%(if|unless|case|select|begin|for|while|until|do|def|macro|class|struct|lib|annotation|enum|module|union)>'

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
      if synID(a:lnum, next_idx, 0)->synIDattr("name") =~# '^crystal\%(Comment\%(Start\)\=\|MarkdownCodeLineStart\)$'
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
    if synID(a:lnum, last_idx + 1, 0)->synIDattr("name") ==# "crystalBackslash"
      return 1
    endif
  elseif last_char ==# ","
    if synID(a:lnum, last_idx + 1, 0)->synIDattr("name") =~# '^crystal\%(Type\)\=Comma$'
      return 3
    endif
  elseif last_char ==# ":"
    let syngroup = synID(a:lnum, last_idx + 1, 0)->synIDattr("name")

    if syngroup =~# '^crystal\%(TypeRestriction\)\=Operator$'
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

    if syngroup =~# '^crystal\%(TypeUnion\)\=Operator$'
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
    let syngroup = synID(v:lnum, 1, 0)->synIDattr("name")

    if s:multiline_regions->get(syngroup)
      return -1
    elseif syngroup[:14] ==# "crystalMarkdown"
      " If this line is part of a fenced code block, simply align with
      " the previous line.
      return indent(prevnonblank(v:lnum - 1))
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
    let syngroup = synID(v:lnum, 1, 0)->synIDattr("name")

    if s:multiline_regions->get(syngroup)
      return -1
    elseif syngroup[:14] ==# "crystalMarkdown"
      " If this line is part of a fenced code block, simply align with
      " the previous line.
      return indent(prevnonblank(v:lnum - 1))
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

    let [l, c, p] = searchpos('\C\([(\[{]\)\|\([)\]}]\)\|\v<%((def|class|module|macro|struct|enum|annotation|lib|union)|(if|unless|case|select|begin|while|until|for|do)|(else|elsif|when|in|ensure|rescue)|(end))>', "bp", start_lnum)

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
        elseif syngroup =~# '^crystal\%(StringArray\|SymbolArray\)Delimiter$'
          if search('\S', "z", l)
            return col(".") - 1
          else
            return indent(l) + shiftwidth()
          endif
        endif
      elseif p == 3
        if syngroup =~# '^crystal\%(StringArray\|SymbolArray\)Delimiter$'
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
        if syngroup =~# '^crystal\%(Keyword\|Define\)$'
          return c - 1 + shiftwidth()
        elseif syngroup ==# "crystalMacroKeyword"
          return indent(l) + shiftwidth()
        endif
      elseif p == 7
        if syngroup =~# '^crystal\%(Macro\)\=Keyword$'
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

      let [l, c, p] = searchpos('\C\([(\[{]\)\|\([)\]}]\)\|\v<%((def|class|module|macro|struct|enum|annotation|lib|union)|(if|unless|case|select|begin|while|until|for|do)|(else|elsif|when|in|ensure|rescue)|(end))>', "bp", start_lnum)
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

" vim:fdm=marker:mmp=100000
