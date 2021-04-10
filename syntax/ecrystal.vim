" Vim syntax file
" Language: Embedded Crystal <crystal-lang.org/api/latest/ECR.html>
" Author: Jeffrey Crochet <jlcrochet@pm.me>
" URL: https://github.com/jlcrochet/vim-crystal

if has_key(b:, "current_syntax")
  finish
endif

let b:is_ecrystal = 1

syn include @crystal syntax/crystal.vim

syn region ecrystalTag matchgroup=ecrystalDelimiter start=/\%#=1<%-\==\=/ end=/\%#=1-\=%>/ contains=@crystal
syn region ecrystalComment matchgroup=ecrystalCommentDelimiter start=/\%#=1<%#/ end=/\%#=1%>/
syn match ecrystalTagEscape /\%#=1<%%/

hi def link ecrystalDelimiter PreProc
hi def link ecrystalComment Comment
hi def link ecrystalCommentDelimiter ecrystalComment
hi def link ecrystalTagEscape ecrystalDelimiter

let b:current_syntax = "ecrystal"
