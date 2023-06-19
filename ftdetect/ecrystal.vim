" Vim ftdetect file
" Language: Embedded Crystal <https://crystal-lang.org/api/latest/ECR.html>
" Author: Jeffrey Crochet <jlcrochet91@pm.me>
" URL: https://github.com/jlcrochet/vim-crystal

autocmd BufRead,BufNewFile *.ecr call g:ecrystal#ftdetect#set_filetype()
