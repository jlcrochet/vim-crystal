" Vim autoload file
" Language: Embedded Crystal <crystal-lang.org/api/latest/ECR.html>
" Author: Jeffrey Crochet <jlcrochet@pm.me>
" URL: https://github.com/jlcrochet/vim-crystal

let g:ecrystal#extensions = {
      \ "html": "html",
      \ "js": "javascript",
      \ "json": "json",
      \ "yml": "yaml",
      \ "txt": "text",
      \ "md": "markdown"
      \ }

if exists("g:ecrystal_extensions")
  call extend(g:ecrystal#extensions, g:ecrystal_extensions)
endif

lockvar g:ecrystal#extensions
