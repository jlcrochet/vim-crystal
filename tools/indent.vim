let s:words = ["0=end", "0=else", "0=elsif", "0=when", "0=rescue", "0=ensure", "0={%\\ end", "0={%\\ else", "0={%\\ elsif", "0=\\\\{%\\ end", "0=\\\\{%\\ else", "0=\\\\{%\\ elsif"]
let s:characters = "_?!:"

let s:indent_words = ["o", "O", "!^F", "0)", "0]", "0}", "0=%}", "0.", "0=.."]

for s:word in s:words
  call add(s:indent_words, s:word)

  for char in s:characters
    call add(s:indent_words, s:word..char)
  endfor
endfor

call add(s:indent_words, '0=in')

" `in` is a short word that is commonly used as a prefix for other words, so
" we should add extra checks to make sure that it isn't part of another word:
let s:in_characters = 'abcdefghijklmnopqrstruvwxyz0123456789_?!:'

for s:char in s:in_characters
  call add(s:indent_words, '0=in'..s:char)
endfor

let g:indent_words = s:indent_words->join(",")
