" Vim autoload file
" Language: Embedded Crystal <crystal-lang.org/api/latest/ECR.html>
" Author: Jeffrey Crochet <jlcrochet91@pm.me>
" URL: https://github.com/jlcrochet/vim-crystal

let s:extensions = #{
      \ html: "html",
      \ js: "javascript",
      \ json: "json",
      \ xml: "xml",
      \ yml: "yaml",
      \ txt: "text",
      \ md: "markdown"
      \ }

if exists("g:ecrystal_extensions")
  call extend(s:extensions, g:ecrystal_extensions)
endif

let s:default_subtype = get(g:, "ecrystal_default_subtype", "html")

if s:default_subtype !=# ""
  function g:ecrystal#ftdetect#set_filetype()
    let parts = split(expand("<afile>"), '\.')

    if len(parts) > 2
      let subtype = get(s:extensions, parts[-2], s:default_subtype)
    else
      let subtype = s:default_subtype
    endif

    let &filetype = subtype..".ecrystal"
  endfunction
else
  function g:ecrystal#ftdetect#set_filetype()
    let parts = split(expand("<afile>"), '\.')

    if len(parts) > 2
      let part = parts[-2]

      if has_key(s:extensions, part)
        let &filetype = s:extensions[part]..".ecrystal"
      else
        setfiletype ecrystal
      endif
    else
      setfiletype ecrystal
    endif
  endfunction
endif
