local unpack = unpack
local find = string.find
local match = string.match
local sub = string.sub

local fn = vim.fn
local prevnonblank = fn.prevnonblank
local shiftwidth = fn.shiftwidth
local getline = fn.getline
local indent = fn.indent
local expand = fn.expand
local search = fn.search
local searchpos = fn.searchpos
local synID = fn.synID
local synIDattr = fn.synIDattr
local cursor = fn.cursor

local api = vim.api
local nvim_get_current_line = api.nvim_get_current_line
local nvim_win_get_cursor = api.nvim_win_get_cursor

local multiline_regions = {
  crystalString = true,
  crystalSymbol = true,
  crystalRegex = true,
  crystalCommand = true,
  crystalComment = true,
  crystalHeredocLine = true,
  crystalHeredocLineRaw = true,
  crystalHeredocDelimiter = true
}

local start_re = "\\<\\%(if\\|unless\\|begin\\|case\\|while\\|until\\|for\\|do\\|def\\|macro\\|class\\|struct\\|module\\|lib\\|annotation\\|enum\\)\\>"
local middle_re = "\\<\\%(else\\|elsif\\|when\\|in\\|rescue\\|ensure\\)\\>"

local hanging_re = "\\<\\%(if\\|unless\\|begin\\|case\\)\\>"

local macro_start_re = "{%\\s*\\zs\\<\\%(if\\|unless\\|begin\\|for\\)\\>\\|\\<do\\s*%}"
local macro_middle_re = "{%\\s*\\zs\\<\\%(else\\|elsif\\)\\>"
local macro_end_re = "{%\\s*\\zs\\<end\\>"

local slash_macro_start_re = "\\\\{%\\s*\\zs\\<\\%(if\\|unless\\|begin\\|for\\)\\>\\|.*\\zs\\<do\\s*%}"
local slash_macro_middle_re = "\\\\{%\\s*\\zs\\<\\%(else\\|elsif\\)\\>"
local slash_macro_end_re = "\\\\{%\\s*\\zs\\<end\\>"

local function syngroup_at(lnum, idx)
  return synIDattr(synID(lnum, idx + 1, false), "name")
end

local function skip_char(lnum, idx)
  return multiline_regions[syngroup_at(lnum, idx)]
end

local function skip_word(lnum, idx)
  return syngroup_at(lnum, idx) ~= "crystalKeyword"
end

local function skip_word_postfix(lnum, idx)
  if syngroup_at(lnum, idx) ~= "crystalKeyword" then
    return true
  end

  local word = expand("<cword>")

  if word == "if" or word == "unless" then
    local _, col = unpack(searchpos("\\S", "b", lnum))

    if col == 0 then
      return false
    end

    local syngroup = syngroup_at(lnum, col - 1)

    if syngroup ~= "crystalOperator" and syngroup ~= "crystalMacroDelimiter" then
      return true
    end
  end

  return false
end

local function skip_macro_delimiter(lnum, idx)
  return syngroup_at(lnum, idx) ~= "crystalMacroDelimiter"
end

local function prev_non_multiline(lnum)
  while multiline_regions[syngroup_at(lnum, 0)] do
    lnum = prevnonblank(lnum - 1)
  end

  return lnum
end

local function get_last_char()
  local lnum, col = unpack(searchpos("\\S", "bW"))

  if lnum == 0 then
    return
  end

  while syngroup_at(lnum, col - 1) == "crystalComment" do
    lnum, col = unpack(searchpos("\\S\\_s*#", "bW"))

    if lnum == 0 then
      return
    end
  end

  local line = nvim_get_current_line()
  local char = sub(line, col, col)

  return char, col - 1, lnum, line
end

local function get_pos()
  return unpack(nvim_win_get_cursor(0))
end

local function set_pos(lnum, idx)
  cursor(lnum, idx + 1)
end

local function search_back(re, skip_func, move_cursor, stop_line, include_current)
  stop_line = stop_line or 1

  local found_lnum, found_col

  if include_current then
    found_lnum, found_col = unpack(searchpos(re, "cbn", stop_line))
  else
    found_lnum, found_col = unpack(searchpos(re, "bn", stop_line))
  end

  if found_lnum == 0 then
    return
  end

  local lnum, idx = get_pos()

  set_pos(found_lnum, found_col - 1)

  while skip_func(found_lnum, found_col - 1) do
    found_lnum, found_col = unpack(searchpos(re, "b", stop_line))

    if found_col == 0 then
      return set_pos(lnum, idx)
    end
  end

  if move_cursor == false then
    set_pos(lnum, idx)
  end

  return found_lnum, found_col - 1
end

local function searchpair_back(start_re, middle_re, end_re, skip_func, move_cursor, stop_line)
  stop_line = stop_line or 1

  -- First, we need to make two patterns: one for top-level pairs,
  -- another for nested pairs. The first will consist of the start and
  -- end patterns; the second will consist of the start, end, and middle
  -- patterns, assuming a middle pattern has been provided.
  local top_re = "\\("..start_re.."\\)\\|\\("..end_re.."\\)"
  local nested_re

  if middle_re then
    nested_re = "\\("..start_re.."\\)\\|\\("..end_re.."\\)\\|\\("..middle_re.."\\)"
  else
    nested_re = top_re
  end

  local lnum, idx = get_pos()
  local pattern = nested_re
  local nest = 1

  local found_lnum, found_col, found_sub

  while true do
    repeat
      found_lnum, found_col, found_sub = unpack(searchpos(pattern, "bp", stop_line))

      if found_lnum == 0 then
        return set_pos(lnum, idx)
      end
    until not skip_func(found_lnum, found_col - 1, found_sub)

    if found_sub == 3 then  -- End pattern was found
      nest = nest + 1
      pattern = top_re
    else
      nest = nest - 1

      if nest == 1 then
        pattern = nested_re
      elseif nest == 0 then
        if move_cursor == false then
          set_pos(lnum, idx)
        end

        return found_lnum, found_col - 1
      end
    end
  end
end

local function get_msl(lnum)
  lnum = prev_non_multiline(lnum)

  local line = getline(lnum)
  local first_col, _, first_char = find(line, "(%S)")

  if first_char == "." then
    return get_msl(prevnonblank(lnum - 1))
  elseif first_char == ")" then
    set_pos(lnum, 0)
    local found = searchpair_back("(", nil, ")", skip_char)
    return get_msl(found)
  elseif first_char == "]" then
    set_pos(lnum, 0)
    local found = searchpair_back("\\[", nil, "]", skip_char)
    return get_msl(found)
  elseif first_char == "}" then
    set_pos(lnum, 0)
    local found = searchpair_back("{", nil, "}", skip_char)
    return get_msl(found)
  elseif first_char == "e" and find(line, "^nd", first_col + 1) and syngroup_at(lnum, first_col - 1) == "crystalKeyword" then
    if first_col == 1 then
      return lnum
    end

    set_pos(lnum, 0)

    local found = searchpair_back(start_re, nil, "\\<end\\>", skip_word_postfix)
    local word = expand("<cword>")

    if word == "do" or word == "if" or word == "unless" or word == "begin" or word == "case" then
      return get_msl(found)
    else
      return found
    end
  else
    set_pos(lnum, 0)

    local last_char, last_idx, prev_lnum = get_last_char()

    if last_char == "," or last_char == "\\" or syngroup_at(prev_lnum, last_idx) == "crystalOperator" then
      return get_msl(prev_lnum)
    end
  end

  return lnum
end

return function()
  local lnum = get_pos()
  local prev_lnum = prevnonblank(lnum - 1)

  if prev_lnum == 0 then
    return 0
  end

  -- Current line {{{1
  -- If the current line is inside of an ignorable multiline region, do
  -- nothing.
  if multiline_regions[syngroup_at(lnum, 0)] then
    return -1
  end

  -- If the first character of the current line is a leading dot, add an
  -- indent unless the previous logical line also started with a leading
  -- dot.
  local line = nvim_get_current_line()
  local first_col, _, first_char = find(line, "(%S)")

  if first_char == "." then
    local prev_lnum = prev_non_multiline(prev_lnum)
    local prev_line = getline(prev_lnum)
    local first_col, _, first_char = find(prev_line, "(%S)")

    if first_char == "." then
      return first_col - 1
    else
      return first_col - 1 + shiftwidth()
    end
  end

  -- If the first character is a closing bracket, align with the line
  -- that contains the opening bracket.
  if first_char == ")" then
    local found = searchpair_back("(", nil, ")", skip_char)
    return indent(found)
  elseif first_char == "]" then
    local found = searchpair_back("\\[", nil, "]", skip_char)
    return indent(found)
  elseif first_char == "}" then
    local found = searchpair_back("{", nil, "}", skip_char)
    return indent(found)
  end

  -- If the first character is a macro delimiter and the first word
  -- after the delimiter is a deindenting keyword, align with the
  -- nearest indenting keyword that is also after a macro delimiter.
  if first_char == "{" and sub(line, first_col + 1, first_col + 1) == "%" then
    local word = match(line, "^%s*(%l%w*)", first_col + 2)

    if word == "end" or word == "else" or word == "elsif" then
      set_pos(lnum, 0)
      searchpair_back(macro_start_re, macro_middle_re, macro_end_re, skip_word)
      local _, idx = searchpair_back("{%", nil, "%}", skip_macro_delimiter)

      return idx
    end
  elseif first_char == "\\" and find(line, "^{%%", first_col + 1) then
    local word = match(line, "^%s*(%l%w*)", first_col + 3)

    if word == "end" or word == "else" or word == "elsif" then
      set_pos(lnum, 0)
      searchpair_back(slash_macro_start_re, slash_macro_middle_re, slash_macro_end_re, skip_word)
      local _, idx = searchpair_back("\\\\{%", nil, "%}", skip_macro_delimiter)

      return idx
    end
  end

  -- If the first word is a deindenting keyword, align with the nearest
  -- indenting keyword.
  local first_word = match(line, "^%l%w*", first_col)

  set_pos(lnum, 0)

  if first_word == "end" then
    local lnum, idx = searchpair_back(start_re, middle_re, "\\<end\\>", skip_word_postfix)
    local word = expand("<cword>")

    if word == "if" or word == "unless" or word == "begin" or word == "case" then
      return idx
    else
      return indent(lnum)
    end
  elseif first_word == "else" then
    local _, idx = searchpair_back(hanging_re, middle_re, "\\<end\\>", skip_word_postfix)
    return idx
  elseif first_word == "elsif" then
    local _, idx = searchpair_back("\\<\\%(if\\|unless\\)\\>", "\\<elsif\\>", "\\<end\\>", skip_word_postfix)
    return idx
  elseif first_word == "when" then
    local _, idx = searchpair_back("\\<case\\>", "\\<when\\>", "\\<end\\>", skip_word)
    return idx
  elseif first_word == "in" then
    local _, idx = searchpair_back("\\<case\\>", "\\<in\\>", "\\<end\\>", skip_word)
    return idx
  elseif first_word == "rescue" then
    local lnum, idx = searchpair_back("\\<\\%(begin\\|do\\|def\\)\\>", "\\<rescue\\>", "\\<end\\>", skip_word)

    if expand("<cword>") == "begin" then
      return idx
    else
      return indent(lnum)
    end
  elseif first_word == "ensure" then
    local lnum, idx = searchpair_back("\\<\\%(begin\\|do\\|def\\)\\>", "\\<ensure\\>", "\\<end\\>", skip_word)

    if expand("<cword>") == "begin" then
      return idx
    else
      return indent(lnum)
    end
  end

  -- Previous line {{{1
  -- Begin by finding the previous non-comment character in the file.
  local last_char, last_idx, prev_lnum, prev_line = get_last_char()

  -- If the last character was a backslash, add an indent unless the
  -- next previous line also ended with a backslash.
  if last_char == "\\" then
    set_pos(prev_non_multiline(prev_lnum), 0)

    local last_char = get_last_char()

    if last_char == "\\" then
      return indent(prev_lnum)
    else
      return indent(prev_lnum) + shiftwidth()
    end
  end

  -- If the last character was a comma, check the following:
  --
  -- 1. If the comma is preceded by an unpaired opening bracket
  -- somehwere in the same line, align with the bracket.
  -- 2. If the next previous line also ended with a comma or it ended
  -- with an opening bracket, align with the beginning of the previous
  -- line.
  -- 3. If the next previous line is not its own MSL, align with the
  -- MSL.
  -- 4. Else, add an indent.
  if last_char == "," then
    local _, idx = searchpair_back("[([{]", nil, "[)\\]}]", skip_char, true, prev_lnum)

    if idx then
      return idx + 1
    end

    set_pos(prev_lnum, 0)
    last_char = get_last_char()

    if find(last_char, "[,([{]") then
      return indent(prev_lnum)
    end

    local msl = get_msl(prev_lnum)

    if msl ~= prev_lnum then
      return indent(msl)
    end

    return indent(prev_lnum) + shiftwidth()
  end

  -- If the last character was an opening bracket, add an indent.
  if find(last_char, "[([{]") then
    return indent(prev_lnum) + shiftwidth()
  end

  local syngroup = syngroup_at(prev_lnum, last_idx)

  -- If the last character was a block parameter delimiter, add an
  -- indent.
  if syngroup == "crystalBlockParameterDelimiter" then
    return indent(prev_lnum) + shiftwidth()
  end

  -- If the last character was a hanging operator, add an indent unless
  -- the line before it also ended with a hanging operator.
  if syngroup == "crystalOperator" then
    set_pos(prev_non_multiline(prev_lnum), 0)

    local _, last_idx, prev_prev_lnum = get_last_char()

    if syngroup_at(prev_prev_lnum, last_idx) == "crystalOperator" then
      return indent(prev_lnum)
    else
      return indent(prev_lnum) + shiftwidth()
    end
  end

  -- MSL {{{1
  local msl = get_msl(prev_lnum)

  -- Find the last keyword in the previous logical line.
  set_pos(prev_lnum, last_idx)

  local lnum, idx = search_back("\\<\\l", skip_word, true, msl)

  while lnum do
    local word = expand("<cword>")

    if word == "end" then
      local found = unpack(searchpos("{%\\s*\\%#", "b"))

      if found ~= 0 then
        found = unpack(searchpos("\\\\\\%#", "b"))

        if found ~= 0 then
          lnum = searchpair_back(slash_macro_start_re, nil, slash_macro_end_re, skip_word)
        else
          lnum = searchpair_back(macro_start_re, nil, macro_end_re, skip_word)
        end
      else
        lnum = msl
      end

      return indent(lnum)
    elseif word == "if" or word == "unless" then
      local _, prev_col = unpack(searchpos("\\S", "b", lnum))

      if prev_col == 0 then
        return idx + shiftwidth()
      end

      local syngroup = syngroup_at(lnum, prev_col - 1)

      if syngroup == "crystalMacroDelimiter" then
        _, prev_col = unpack(searchpos("\\\\\\={\\%#", "b"))
        return prev_col - 1 + shiftwidth()
      end

      if syngroup == "crystalOperator" then
        return idx + shiftwidth()
      else
        return indent(msl)
      end
    elseif word == "begin" or word == "else" or word == "elsif" then
      local _, prev_col = unpack(searchpos("\\\\\\={%\\s*\\%#", "b"))

      if prev_col ~= 0 then
        idx = prev_col - 1
      end

      return idx + shiftwidth()
    elseif word == "case" then
      return idx + shiftwidth()
    elseif word == "then" then
      local found = search("\\<")

      if found == lnum then
        return indent(msl)
      else
        return indent(msl) + shiftwidth()
      end
    elseif word == "do" then
      return indent(lnum) + shiftwidth()
    elseif word == "when" or word == "in" or word == "forall" or word == "while" or word == "until" or word == "rescue" or word == "ensure" or word == "def" or word == "macro" or word == "class" or word == "struct" or word == "lib" or word == "annotation" or word == "enum" or word == "module" then
      return indent(msl) + shiftwidth()
    else
      return indent(msl)
    end
  end
  -- }}}1

  -- Default
  return indent(msl)
end

-- vim:fdm=marker