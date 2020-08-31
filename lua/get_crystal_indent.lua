local ipairs = ipairs
local unpack = unpack

local find = string.find
local sub = string.sub
local match = string.match

local concat = table.concat

local tbl_contains = vim.tbl_contains

local api = vim.api
local nvim_win_get_cursor = api.nvim_win_get_cursor
-- TEMP
local nvim_command = api.nvim_command

local fn = vim.fn
local getline = fn.getline
local prevnonblank = fn.prevnonblank
local searchpos = fn.searchpos
local indent = fn.indent
local fn_match = fn.match
local line = fn.line
local col = fn.col
local cursor = fn.cursor
local synID = fn.synID
local synIDattr = fn.synIDattr
local escape = fn.escape
local shiftwidth = fn.shiftwidth

-- These top-level variables are written in CAPS to set them apart from
-- local variables elsewhere in the script.
local CLNUM, CLINE
local PLNUM, PLINE
local FIRST_COL, LAST_COL
local FIRST_CHAR, LAST_CHAR
local CONTENT

-- Constants {{{1
-- =========

-- Like the top-level variables, these constants are written in CAPS to
-- set them apart from local variables.

-- Lookup table for keyword syntax groups
KEYWORD_SYNGROUPS = {
  ["class"] = "crystalDefine",
  ["struct"] = "crystalDefine",
  ["def"] = "crystalDefine",
  ["macro"] = "crystalDefine",
  ["module"] = "crystalDefine",
  ["lib"] = "crystalDefine",
  ["enum"] = "crystalDefine",
  ["annotation"] = "crystalDefine",
  ["if"] = "crystalConditional",
  ["unless"] = "crystalConditional",
  ["begin"] = "crystalControl",
  ["case"] = "crystalConditional",
  ["while"] = "crystalRepeat",
  ["until"] = "crystalRepeat",
  ["do"] = "crystalDo",
  ["else"] = "crystalConditional",
  ["elsif"] = "crystalConditional",
  ["when"] = "crystalConditional",
  ["in"] = "crystalConditional",
  ["rescue"] = "crystalControl",
  ["ensure"] = "crystalControl",
  ["end"] = "crystalControl"
}

-- Syntax groups for regions that are not indented
MULTILINE_SYNGROUPS = {
  "crystalHeredocLine", "crystalHeredocLineRaw", "crystalHeredocEnd"
}

-- Keywords that can cause a hanging indent
HANGING_KEYWORDS = {
  "if", "unless", "begin", "case"
}

-- Operator symbols that can cause a hanging indent
OPERATORS = {
  "+", "-", "*", "/", "%", "|", "&", "=", "<", ">", "."
}

OPERATORS_RE = "["..escape(concat(OPERATORS), "-").."]"

local function join_words(words)
  return "\\<\\%("..concat(words, "\\|").."\\)\\>"
end

-- Pattern for keywords that start a keyword pair
START_RE = join_words {
  "class", "struct", "def", "macro", "module", "lib", "enum",
  "annotation", "if", "unless", "begin", "case", "while", "until", "do"
}

-- Pattern for keywords that can be in the middle of a keyword pair
MIDDLE_RE = join_words {
  "else", "elsif", "when", "in", "rescue", "ensure"
}

-- Pattern for keywords that end a keyword pair
END_RE = "\\<end\\>"

-- Pattern for keywords that start an indent
INDENT_RE = "\\%("..START_RE.."\\|"..MIDDLE_RE.."\\)"

-- Pattern for keywords that end an indent
DEDENT_RE = "\\%("..MIDDLE_RE.."\\|"..END_RE.."\\)"

-- Pattern for matching the last character before the end of the line,
-- excluding optional inline comments
EOL_RE = "\\ze\\s*\\%(#{\\@!.*\\)\\=\\_$"

-- Pattern for macro tags that start a pair
MACRO_START_RE = "{%\\s*\\zs"..join_words {
  "if", "unless", "begin", "for"
}

-- Pattern for macro tags that can be in the middle of a pair
MACRO_MIDDLE_RE = "{%\\s*\\zs"..join_words {
  "else", "elsif"
}

-- Pattern for macro tags that end a pair
MACRO_END_RE = "{%\\s*\\zsend\\>"

-- Pattern for macro tags that start an indent
MACRO_INDENT_RE = "{%\\s*\\zs"..join_words {
  "if", "unless", "begin", "for", "else", "elsif"
}

-- Pattern for macro tags that end an indent
MACRO_DEDENT_RE = "{%\\s*\\zs"..join_words {
  "else", "elsif", "end"
}

-- Pattern for

-- Helper functions {{{1
-- ================

-- TEMP
function echo(str)
  nvim_command("echo '"..str.."'")
end

-- TEMP
function echom(str)
  nvim_command("echom '"..str.."'")
end

function get_pos()
  return unpack(nvim_win_get_cursor(0))
end

function set_pos(lnum, idx)
  cursor(lnum, idx + 1)
end

function syngroup_at(lnum, idx)
  return synIDattr(synID(lnum, idx + 1, true), "name")
end

function syngroup_at_cursor()
  return syngroup_at(get_pos())
end

local function search(re, move_cursor, stop_line, skip_func)
  if move_cursor == nil then
    move_cursor = true
  end

  stop_line = stop_line or line("$")

  local found_lnum, found_col

  if skip_func then
    local lnum, idx = get_pos()

    repeat
      found_lnum, found_col = unpack(searchpos(re, "z", stop_line))

      if found_lnum == 0 then
        return set_pos(lnum, idx)
      end
    until not skip_func(found_lnum, found_col - 1)

    if not move_cursor then
      set_pos(lnum, idx)
    end
  else
    local flags

    if move_cursor then
      flags = "z"
    else
      flags = "nz"
    end

    found_lnum, found_col = unpack(searchpos(re, flags, stop_line))

    if found_lnum == 0 then
      return
    end
  end

  return found_lnum, found_col - 1
end

local function search_back(re, move_cursor, stop_line, skip_func)
  if move_cursor == nil then
    move_cursor = true
  end

  stop_line = stop_line or 1

  local found_lnum, found_col

  if skip_func then
    local lnum, idx = get_pos()

    repeat
      found_lnum, found_col = unpack(searchpos(re, "b", stop_line))

      if found_lnum == 0 then
        return set_pos(lnum, idx)
      end
    until not skip_func(found_lnum, found_col - 1)

    if not move_cursor then
      set_pos(lnum, idx)
    end
  else
    local flags

    if move_cursor then
      flags = "b"
    else
      flags = "bn"
    end

    found_lnum, found_col = unpack(searchpos(re, flags, stop_line))

    if found_lnum == 0 then
      return
    end
  end

  return found_lnum, found_col - 1
end

local function searchpair(start_re, end_re, move_cursor, stop_line, skip_start, skip_end)
  if move_cursor == nil then
    move_cursor = true
  end

  stop_line = stop_line or line("$")

  local end_lnum, end_idx = search(end_re, false, stop_line, skip_end)

  if not end_lnum then
    return
  end

  local lnum, idx = get_pos()

  local i = 0

  while true do
    local start_lnum, start_idx = search(start_re, true, end_lnum, skip_start)

    if start_lnum then
      if start_lnum == end_lnum and start_idx > end_idx then
        break
      else
        i = i + 1
      end
    else
      break
    end
  end

  if i == 0 then
    if move_cursor then
      set_pos(end_lnum, end_idx)
    else
      set_pos(lnum, idx)
    end

    return end_lnum, end_idx
  end

  set_pos(end_lnum, end_idx)

  local j = 0

  while j < i do
    end_lnum, end_idx = search(end_re, false, stop_line, skip_end)

    if not end_lnum then
      return set_pos(lnum, idx)
    end

    while true do
      local start_lnum, start_idx = search(start_re, true, end_lnum, skip_start)

      if start_lnum then
        if start_lnum == end_lnum and start_idx > end_idx then
          break
        else
          i = i + 1
        end
      else
        break
      end
    end

    set_pos(end_lnum, end_idx)

    j = j + 1
  end

  if not move_cursor then
    set_pos(lnum, idx)
  end

  return end_lnum, end_idx
end

local function searchpair_back(start_re, end_re, move_cursor, stop_line, skip_start, skip_end)
  if move_cursor == nil then
    move_cursor = true
  end

  stop_line = stop_line or 1

  local start_lnum, start_idx = search_back(start_re, false, stop_line, skip_start)

  if not start_lnum then
    return
  end

  local lnum, idx = get_pos()

  local i = 0

  while true do
    local end_lnum, end_idx = search_back(end_re, true, start_lnum, skip_end)

    if end_lnum then
      if end_lnum == start_lnum and end_idx < start_idx then
        break
      else
        i = i + 1
      end
    else
      break
    end
  end

  if i == 0 then
    if move_cursor then
      set_pos(start_lnum, start_idx)
    else
      set_pos(lnum, idx)
    end

    return start_lnum, start_idx
  end

  set_pos(start_lnum, start_idx)

  local j = 0

  while j < i do
    start_lnum, start_idx = search_back(start_re, false, stop_line, skip_start)

    if not start_lnum then
      return set_pos(lnum, idx)
    end

    while true do
      local end_lnum, end_idx = search_back(end_re, true, start_lnum, skip_end)

      if end_lnum then
        if end_lnum == start_lnum and end_idx < start_idx then
          break
        else
          i = i + 1
        end
      else
        break
      end
    end

    set_pos(start_lnum, start_idx)

    j = j + 1
  end

  if not move_cursor then
    set_pos(lnum, idx)
  end

  return start_lnum, start_idx
end

function word_at(lnum, idx)
  return match(getline(lnum), "^%a+", idx + 1)
end

function skip_word(lnum, idx)
  return syngroup_at(lnum, idx) ~= KEYWORD_SYNGROUPS[word_at(lnum, idx)]
end

function skip_end(lnum, idx)
  return syngroup_at(lnum, idx) ~= "crystalControl"
end

function skip_macro_word(lnum, idx)
  return syngroup_at(lnum, idx) ~= "crystalMacroKeyword"
end

function skip_macro_delimiter(lnum, idx)
  return syngroup_at(lnum, idx) ~= "crystalMacroDelimiter"
end

function skip_heredoc_start(lnum, idx)
  return syngroup_at(lnum, idx) ~= "crystalHeredocStart"
end

function skip_parenthesis(lnum, idx)
  return syngroup_at(lnum, idx) ~= "crystalParenthesis"
end

function skip_bracket(lnum, idx)
  return syngroup_at(lnum, idx) ~= "crystalBracket"
end

function skip_brace(lnum, idx)
  return syngroup_at(lnum, idx) ~= "crystalBrace"
end

function skip_delimiter(lnum, idx)
  local syngroup = syngroup_at(lnum, idx)
  return syngroup ~= "crystalParenthesis" and syngroup ~= "crystalBracket" and syngroup ~= "crystalBrace"
end

function starts_with(text, re)
  return fn_match(text, "\\_^"..re) > -1
end

-- function get_msl(lnum)
--   local plnum = prevnonblank(lnum - 1)

--   -- This line is not the MSL if...

--   -- There is no previous line
--   if plnum == 0 then
--     return lnum
--   end

--   local line = getline(lnum)
--   local first_char = match(line, "%S")

--   -- The current line has a leading dot
--   if first_char == "." then
--     return get_msl(plnum)
--   end

--   local pline = getline(plnum)
--   local last_col = fn_match(pline, EOL_RE)
--   local last_char = sub(pline, last_col, last_col)

--   -- The previous line ended with a comma
--   if last_char == "," then
--     return get_msl(plnum)
--   end

--   -- The previous line ended with a line continuation character
--   if last_char == "\\" then
--     return get_msl(plnum)
--   end

--   -- If none of the above conditions apply, then this line is the MSL.
--   return lnum
-- end

-- -- Find the first line before the given line that doesn't end in with
-- -- the given character.
-- function get_msl(lnum, char)
--   local plnum = prevnonblank(lnum - 1)

--   -- If there is no previous line, this is the MSL
--   if plnum == 0 then
--     return lnum
--   end

--   local pline = getline(plnum)
--   local last_col = fn_match(pline, EOL_RE)
--   local last_char = sub(pline, last_col, last_col) typeof(z)
-- end

-- Current line indent callbacks {{{1
-- =============================

local function multiline_region()
  if tbl_contains(MULTILINE_SYNGROUPS, syngroup_at(CLNUM, 0)) then
    echo "multiline_region"
    return indent(".")
  end
end

local function closing_bracket()
  local opener

  if FIRST_CHAR == ")" then
    opener = "("
  elseif FIRST_CHAR == "]" then
    opener = "["
  elseif FIRST_CHAR == "}" then
    opener = "{"
  else
    return
  end

  echo "closing_bracket"

  PLINE = getline(PLNUM)
  LAST_COL = fn_match(PLINE, EOL_RE)
  LAST_CHAR = sub(PLINE, LAST_COL, LAST_COL)

  if LAST_CHAR == opener then
    return indent(PLNUM)
  else
    return indent(PLNUM) - shiftwidth()
  end
end

local function deindenting_keyword()
  if starts_with(CONTENT, DEDENT_RE) then
    echo "deindenting_keyword"

    local lnum, idx = searchpair_back(INDENT_RE, END_RE, true, 1, skip_word, skip_end)

    if tbl_contains(HANGING_KEYWORDS, word_at(lnum, idx)) then
      return idx
    else
      return indent(lnum)
    end
  end
end

local function deindenting_macro_tag()
  local prefix

  if FIRST_CHAR == "\\" then
    prefix = "\\"
  else
    prefix = ""
  end

  if starts_with(CONTENT, prefix..MACRO_DEDENT_RE) then
    echo "deindenting_macro_tag"

    local lnum, idx = searchpair_back(prefix..MACRO_INDENT_RE, prefix..MACRO_END_RE, true, 1, skip_macro_word, skip_macro_word)

    if tbl_contains(HANGING_KEYWORDS, word_at(lnum, idx)) then
      search_back(prefix.."{%", skip_macro_delimiter, lnum)
      return idx
    else
      return indent(lnum)
    end
  end
end

local function leading_dot()
  if FIRST_CHAR == "." then
    echo "leading_dot"

    PLINE = getline(PLNUM)

    if match(PLINE, "%S") == "." then
      return indent(PLNUM)
    else
      return indent(PLNUM) + shiftwidth()
    end
  end
end

local curr_line_callbacks = {
  multiline_region,
  leading_dot,
  closing_bracket,
  deindenting_macro_tag,
  deindenting_keyword
}

-- Previous line indent callbacks {{{1
-- ==============================

local function after_comment()
  if FIRST_CHAR == "#" then
    echo "after_comment"
    return indent(PLNUM)
  end
end

local function after_link_attribute()
  if sub(CONTENT, 1, 2) == "@[" then
    echo "after_link_attribute"
    return indent(PLNUM)
  end
end

local function after_opening_bracket()
  if LAST_CHAR == "(" or LAST_CHAR == "[" or LAST_CHAR == "{" then
    echo "after_opening_bracket"
    return indent(PLNUM) + shiftwidth()
  elseif LAST_CHAR == "|" and find(CONTENT, "{%s*%b||$") then
    echo "after_opening_bracket"
    return indent(PLNUM) + shiftwidth()
  end
end

local function after_beginning_closing_bracket()
  if FIRST_CHAR == ")" or FIRST_CHAR == "]" or FIRST_CHAR == "}" then
    echo "after_beginning_closing_bracket"
    return indent(PLNUM)
  end
end

local function after_closing_bracket()
  local opener, skip_func

  if LAST_CHAR == ")" then
    opener = "("
    skip_func = skip_parenthesis
  elseif LAST_CHAR == "]" then
    opener = "\\["
    skip_func = skip_bracket
  elseif LAST_CHAR == "}" then
    opener = "{"
    skip_func = skip_brace
  else
    return
  end

  echo "after_closing_bracket"

  set_pos(PLNUM, LAST_COL - 1)

  local open_lnum = searchpair_back(opener, LAST_CHAR, true, 1, skip_func, skip_func)

  if open_lnum == PLNUM then
    return
  end

  return indent(open_lnum)
end

local function after_end_keyword()
  if sub(CONTENT, 1, 3) ~= "end" then
    return
  end

  echo "after_end_keyword"

  set_pos(PLNUM, 0)

  local lnum = searchpair_back(START_RE, END_RE, true, 1, skip_word, skip_end)

  return indent(lnum)
end

local function after_end_macro_tag()
  local prefix

  if FIRST_CHAR == "\\" then
    prefix = "\\"
  else
    prefix = ""
  end

  if starts_with(CONTENT, prefix..MACRO_END_RE) then
    echo "after_end_macro_tag"

    set_pos(PLNUM, 0)

    local lnum = searchpair_back(prefix..MACRO_START_RE, prefix..MACRO_END_RE, true, 1, skip_macro_word, skip_macro_word)

    return indent(lnum)
  end
end

local function after_indent_keyword()
  set_pos(PLNUM, LAST_COL - 1)

  -- local lnum, idx
  -- local x, y

  -- repeat
  --   x, y = searchpair_back(INDENT_RE, END_RE, skip_word, PLNUM)

  --   if x then
  --     lnum, idx = x, y
  --   end
  -- until not x

  local lnum, idx = searchpair_back(INDENT_RE, END_RE, true, PLNUM, skip_word, skip_end)

  if not lnum then
    return
  end

  echo "after_indent_keyword"

  if tbl_contains(HANGING_KEYWORDS, word_at(lnum, idx)) then
    return idx + shiftwidth()
  else
    return indent(PLNUM) + shiftwidth()
  end
end

local function after_indent_macro_tag()
  set_pos(PLNUM, LAST_COL - 1)

  local lnum, idx = searchpair_back(MACRO_START_RE, MACRO_END_RE, true, PLNUM, skip_macro_word, skip_macro_word)

  if not lnum then
    return
  end

  echo "after_indent_macro_tag"

  if tbl_contains(HANGING_KEYWORDS, word_at(lnum, idx)) then
    lnum, idx = search_back("{%", skip_macro_delimiter, lnum)

    if sub(PLINE, idx + 1, idx + 1) == "\\" then
      idx = idx - 1
    end

    return idx + shiftwidth()
  else
    return indent(PLNUM) + shiftwidth()
  end
end

local function after_backslash()
  if LAST_CHAR ~= "\\" then
    return
  end

  echo "after_backslash"

  local pplnum = prevnonblank(PLNUM - 1)

  if pplnum == 0 then
    return indent(PLNUM) + shiftwidth()
  end

  local ppline = getline(pplnum)
  local last_col = fn_match(ppline, EOL_RE)
  local last_char = sub(ppline, last_col, last_col)

  if last_char == "\\" then
    return indent(PLNUM)
  else
    return indent(PLNUM) + shiftwidth()
  end
end

local function after_comma()
  if LAST_CHAR ~= "," then
    return
  end

  echo "after_comma"

  set_pos(PLNUM, LAST_COL - 1)

  while true do
    local _, idx = search_back("[(%[{]", skip_delimiter, PLNUM)

    if not idx then
      break
    end

    local char = sub(PLNUM, idx + 1, idx + 1)

    local closer, skip_func

    if char == "(" then
      closer = ")"
      skip_func = skip_parenthesis
    elseif char == "[" then
      char = "\\["
      closer = "]"
      skip_func = skip_bracket
    elseif char == "{" then
      closer = "}"
      skip_func = skip_brace
    end

    if not searchpair(char, closer, false, PLNUM, skip_func) then
      return idx + 1
    end
  end

  -- Special case for multiline record definitions
  if starts_with(CONTENT, "record\\>") then
    return indent(PLNUM) + shiftwidth()
  end

  return indent(PLNUM)
end

local function after_operator()
  if tbl_contains(OPERATORS, LAST_CHAR) and syngroup_at(PLNUM, LAST_COL - 1) == "crystalOperator" then
    echo "after_operator"

    local pplnum = prevnonblank(PLNUM - 1)

    if pplnum == 0 then
      return indent(PLNUM) + shiftwidth()
    end

    local ppline = getline(pplnum)
    local last_col = fn_match(ppline, EOL_RE)
    local last_char = sub(ppline, last_col, last_col)

    if tbl_contains(OPERATORS, last_char) and syngroup_at(pplnum, last_col - 1) == "crystalOperator" then
      return indent(PLNUM)
    else
      return indent(PLNUM) + shiftwidth()
    end
  end
end

local function after_line_continuation()
  -- The previous line is a line continuation if...

  -- It has a leading dot
  if FIRST_CHAR == "." then
    echo "after_line_continuation"
    return indent(PLNUM) - shiftwidth()
  end

  local pplnum = prevnonblank(PLNUM - 1)

  if pplnum == 0 then
    return
  end

  local ppline = getline(pplnum)
  local last_col = fn_match(ppline, EOL_RE)
  local last_char = sub(ppline, last_col, last_col)

  -- The line before it ended with a comma, backslash, or operator
  if last_char == "," or last_char == "\\" then
    echo "after_line_continuation"
    return indent(PLNUM) - shiftwidth()
  elseif tbl_contains(OPERATORS, last_char) and syngroup_at(pplnum, last_col - 1) == "crystalOperator" then
    echo "after_line_continuation"
    return indent(PLNUM) - shiftwidth()
  end
end

local function after_heredoc_end()
  if sub(syngroup_at(PLNUM, 0), 1, 14) ~= "crystalHeredoc" then
    return
  end

  echo "after_heredoc_end"

  -- Align with the starting line

  local lnum = search_back("<<-", skip_heredoc_start)

  if lnum then
    return indent(lnum)
  end
end

local prev_line_callbacks = {
  after_comment,
  after_link_attribute,
  after_backslash,
  after_comma,
  after_operator,
  after_opening_bracket,
  after_beginning_closing_bracket,
  after_heredoc_end,
  after_end_macro_tag,
  after_indent_macro_tag,
  after_end_keyword,
  after_indent_keyword,
  after_closing_bracket,
  after_line_continuation
}

-- get_crystal_indent {{{1
-- ==================

return function(lnum)
  -- Setup {{{2
  -- -----

  CLNUM = lnum
  PLNUM = prevnonblank(CLNUM - 1)

  -- If there is no previous line, return zero.
  if PLNUM == 0 then
    echo "First line"
    return 0
  end

  local ind

  set_pos(lnum, 0)

  -- Work on the current line {{{2
  -- ------------------------

  CLINE = getline(CLNUM)
  FIRST_COL, _, FIRST_CHAR = find(CLINE, "(%S)")

  -- The current line is not guaranteed to be non-blank
  if FIRST_COL then
    CONTENT = sub(CLINE, FIRST_COL)

    for _, callback in ipairs(curr_line_callbacks) do
      ind = callback()

      if ind then
        return ind
      end
    end
  end

  -- Work on the previous line {{{2
  -- -------------------------

  PLINE = getline(PLNUM)

  FIRST_COL, _, FIRST_CHAR = find(PLINE, "(%S)")
  LAST_COL = fn_match(PLINE, EOL_RE)

  CONTENT = sub(PLINE, FIRST_COL, LAST_COL)
  LAST_CHAR = sub(CONTENT, -1)

  for _, callback in ipairs(prev_line_callbacks) do
    ind = callback()

    if ind then
      return ind
    end
  end

  -- }}}2

  echo "default"
  return indent(PLNUM)
end

-- }}}

-- vim:fdm=marker
