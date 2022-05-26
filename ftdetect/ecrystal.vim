" Vim ftdetect file
" Language: Embedded Crystal <crystal-lang.org/api/latest/ECR.html>
" Author: Jeffrey Crochet <jlcrochet@hey.com>
" URL: https://github.com/jlcrochet/vim-crystal

autocmd BufRead,BufNewFile *.ecr call g:ecrystal#ftdetect#set_filetype()
