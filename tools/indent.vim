let s:words = ["=end", "=else", "=elsif", "0=when", "0=in", "0=rescue", "0=ensure"]
let s:characters = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_?!:"

let s:indent_words = ["0)", "0]", "0}", "0.", "0=..", "o", "O", "!^F"]

for s:word in s:words
  call append(s:indent_words, s:word)

  for s:char in s:characters
    call append(s:indent_words, s:word..s:char)
  endfor
endfor

let g:indentkeys = s:indentkeys->join(",")

unlet s:words s:characters s:indent_words s:word s:char
