" Vim syntax file
" Language: Embedded Crystal <https://crystal-lang.org/api/latest/ECR.html>
" Author: Jeffrey Crochet <jlcrochet91@pm.me>
" URL: https://github.com/jlcrochet/vim-crystal

let b:is_ecrystal = 1

unlet! b:current_syntax

syn include @crystal syntax/crystal.vim

let b:current_syntax = "ecrystal"

syn cluster ecrystal contains=ecrystalTag,ecrystalComment,ecrystalTagEscape

syn region ecrystalTag matchgroup=ecrystalDelimiter start=/\%#=1<%-\==\=/ end=/\%#=1-\=%>/ contains=@crystal containedin=ALLBUT,@crystal,@ecrystal
syn region ecrystalComment matchgroup=ecrystalCommentStart start=/\%#=1<%#/ matchgroup=ecrystalCommentEnd end=/\%#=1%>/ containedin=ALLBUT,@crystal,@ecrystal
syn match ecrystalTagEscape /\%#=1<%%/ containedin=ALLBUT,@crystal,@ecrystal

hi def link ecrystalDelimiter Delimiter
hi def link ecrystalComment Comment
hi def link ecrystalCommentStart ecrystalComment
hi def link ecrystalCommentEnd ecrystalCommentStart
hi def link ecrystalTagEscape ecrystalDelimiter
