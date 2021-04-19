" Vim ftplugin file
" Language: Embedded Crystal <crystal-lang.org/api/latest/ECR.html>
" Author: Jeffrey Crochet <jlcrochet@pm.me>
" URL: https://github.com/jlcrochet/vim-crystal

if get(b:, "did_ftplugin")
  finish
endif

setlocal suffixesadd=.ecr

" Determine the sub-filetype based on the file extension of the file
" being opened.
let s:parts = split(expand("%:t"), '\.')

if len(s:parts) > 2
  let s:sub_extension = s:parts[-2]

  if has_key(g:ecrystal#ftplugin#extensions, s:sub_extension)
    let b:ecrystal_subtype = g:ecrystal#ftplugin#extensions[s:sub_extension]
  endif
endif

unlet! s:parts s:sub_extension

" If a subtype was found, load filetype settings for that subtype.
if exists("b:ecrystal_subtype")
  execute printf("runtime! ftplugin/%s.vim indent/%s.vim", b:ecrystal_subtype, b:ecrystal_subtype)

  let b:ecrystal_subtype_indentexpr = &indentexpr

  unlet b:did_indent
else
  let b:ecrystal_subtype_indentexpr = "-1"

  setlocal shiftwidth=2
  setlocal commentstring=<%#\ %s\ %>
endif

let b:did_ftplugin = 1
