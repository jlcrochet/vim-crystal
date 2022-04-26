" Vim autoload file
" Language: Crystal <crystal-lang.org>
" Author: Jeffrey Crochet <jlcrochet@hey.com>
" URL: https://github.com/jlcrochet/vim-crystal

" There are certain keywords that cause a dedent, but a dedent should
" only occur if the word is not succeeded by a keyword character, in
" order to avoid dedenting when a line has a variable named "end_col" or
" something like that.
let s:dedent_words = []

let s:chars = [
      \ "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z",
      \ "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z",
      \ "0", "1", "2", "3", "4", "5", "6", "7", "8", "9",
      \ "_", "?", "!", ":"
      \ ]

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
