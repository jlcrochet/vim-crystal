" Vim autoload file
" Language: Crystal <crystal-lang.org>
" Author: Jeffrey Crochet <jlcrochet@pm.me>
" URL: https://github.com/jlcrochet/vim-crystal

" There are certain keywords that cause a dedent, but a dedent should
" only occur if the word is not succeeded by a keyword character, in
" order to avoid dedenting when a line has a variable named "end_col" or
" something like that.
let s:dedent_words = []

let s:chars = map(str2list("abcdefghijklmnopqrstuvwxyz0123456789_:"), "nr2char(v:val)")

for s:word in ["end", "else", "elsif"]
  let str = "=" .. s:word

  call add(s:dedent_words, str)

  for char in s:chars
    call add(s:dedent_words, str .. char)
  endfor
endfor

for s:word in ["when", "in", "rescue", "ensure"]
  let str = "0=" .. s:word

  call add(s:dedent_words, str)

  for char in s:chars
    call add(s:dedent_words, str .. char)
  endfor
endfor

const g:crystal#indent#dedent_words = join(s:dedent_words, ",")

unlet s:word s:chars s:dedent_words
