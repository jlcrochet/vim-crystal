" Vim syntax file
" Language: Embedded Crystal <crystal-lang.org/api/latest/ECR.html>
" Author: Jeffrey Crochet <jlcrochet@pm.me>
" URL: https://github.com/jlcrochet/vim-crystal

if exists("b:current_syntax")
  finish
endif

if exists("b:ecrystal_subtype")
  execute printf("runtime! syntax/%s.vim syntax/%s/*.vim", b:ecrystal_subtype, b:ecrystal_subtype)
  unlet b:current_syntax
endif

let b:is_ecrystal = 1

syn include @crystal syntax/crystal.vim

let b:current_syntax = "ecrystal"

syn region ecrystalTag matchgroup=ecrystalDelimiter start=/\%#=1<%-\==\=/ end=/\%#=1-\=%>/ contains=@crystal containedin=ALLBUT,ecrystalTag,ecrystalComment,ecrystalTagEscape,@crystal
syn region ecrystalComment matchgroup=ecrystalCommentStart start=/\%#=1<%#/ matchgroup=ecrystalCommentEnd end=/\%#=1%>/ containedin=ALLBUT,ecrystalTag,ecrystalComment,ecrystalTagEscape,@crystal
syn match ecrystalTagEscape /\%#=1<%%/ containedin=ALLBUT,ecrystalTag,ecrystalComment,ecrystalTagEscape,@crystal

hi def link ecrystalDelimiter PreProc
hi def link ecrystalComment Comment
hi def link ecrystalCommentStart ecrystalComment
hi def link ecrystalCommentEnd ecrystalCommentStart
hi def link ecrystalTagEscape ecrystalDelimiter
