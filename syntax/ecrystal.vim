" Vim syntax file
" Language: eCrystal <crystal-lang.org/api/latest/ECR.html>
" Author: Jeffrey Crochet <jlcrochet@pm.me>
" URL: https://github.com/jlcrochet/vim-crystal

if &syntax !~# '\<ecrystal\>' || get(b:, 'current_syntax') =~# '\<ecrystal\>'
  finish
endif

if !exists('main_syntax')
  let main_syntax = 'ecrystal'
endif

call ecrystal#SetSubtype()

if b:ecrystal_subtype !=# ''
  exec 'runtime! syntax/'.b:ecrystal_subtype.'.vim'
  unlet! b:current_syntax
endif

syn include @crystalTop syntax/crystal.vim

syn cluster ecrystalRegions contains=ecrystalControl,ecrystalRender,ecrystalComment

syn region ecrystalControl matchgroup=ecrystalDelimiter start="<%%\@!-\="  end="-\=%>" display contains=@crystalTop        containedin=ALLBUT,@ecrystalRegions
syn region ecrystalRender  matchgroup=ecrystalDelimiter start="<%%\@!-\==" end="-\=%>" display contains=@crystalTop        containedin=ALLBUT,@ecrystalRegions
syn region ecrystalComment matchgroup=ecrystalDelimiter start="<%%\@!-\=#" end="-\=%>" display contains=crystalTodo,@Spell containedin=ALLBUT,@ecrystalRegions

" Define the default highlighting.

hi def link ecrystalDelimiter PreProc
hi def link ecrystalComment   crystalComment

let b:current_syntax = 'ecrystal'

if exists('main_syntax') && main_syntax ==# 'ecrystal'
  unlet main_syntax
endif
