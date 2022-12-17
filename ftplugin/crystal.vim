" Vim ftplugin file
" Language: Crystal <crystal-lang.org>
" Author: Jeffrey Crochet <jlcrochet91@pm.me>
" URL: https://github.com/jlcrochet/vim-crystal

if get(b:, "did_ftplugin")
  finish
endif

let b:did_ftplugin = 1

setlocal
      \ shiftwidth=2
      \ comments=:#
      \ commentstring=#\ %s
      \ suffixesadd=.cr

let b:undo_ftplugin = "setlocal shiftwidth< comments< commentstring< suffixesadd<"

" matchit.vim
if get(g:, "loaded_matchit")
  let b:match_words = '\<\%(def\|macro\|class\|struct\|module\|enum\|annotation\|lib\|union\|if\|unless\|case\|select\|while\|until\|for\|begin\|do\)\:\@!\>:\<\%(else\|elsif\|when\|in\|rescue\|ensure\|break\|next\|yield\|return\|raise\)\:\@!\>:\<end\:\@!\>'
  let b:match_skip = 'S:^crystal\%(Keyword\|Define\)$'

  let b:undo_ftplugin ..= " | unlet b:match_words b:match_skip"
endif
