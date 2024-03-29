" Vim plugin file
" Language: Crystal <crystal-lang.org>
" Author: Jeffrey Crochet <jlcrochet91@pm.me>
" URL: https://github.com/jlcrochet/vim-crystal

" vim-endwise
if get(g:, "loaded_endwise")
  augroup endwise
    autocmd! FileType crystal
          \ let b:endwise_addition = "end" |
          \ let b:endwise_words = "def,macro,class,struct,module,enum,annotation,lib,union,if,unless,case,while,until,begin,do" |
          \ let b:endwise_syngroups = "crystalKeyword,crystalDefine"
  augroup END
endif
