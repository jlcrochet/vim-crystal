" Vim autoload file
" Language: Crystal <crystal-lang.org>
" Author: Jeffrey Crochet <jlcrochet@pm.me>
" URL: https://github.com/jlcrochet/vim-crystal

let s:match_words = [
      \ '\<\%(def\|macro\|class\|struct\|module\|enum\|annotation\|lib\|union\|if\|unless\|case\|while\|until\|for\|begin\|do\)\:\@!\>',
      \ '\<\%(else\|elsif\|when\|in\|rescue\|ensure\|break\|next\|yield\|return\|raise\)\:\@!\>',
      \ '\<end\:\@!\>'
      \ ]
const g:crystal#ftplugin#match_words = join(s:match_words, ":")
unlet s:match_words
