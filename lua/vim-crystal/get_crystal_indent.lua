local v = vim.v
local g = vim.g
local bo = vim.bo

local fn = vim.fn
local prevnonblank = fn.prevnonblank
local synID = fn.synID
local synIDattr = fn.synIDattr
local getline = fn.getline
local indent = fn.indent

local api = vim.api
local nvim_get_current_line = api.nvim_get_current_line

-- Helpers {{{
local multiline_regions = {
  crystalString = true,
  crystalStringEscape = true,
  crystalStringInterpolationDelimiter = true,
  crystalStringParenthesisEscape = true,
  crystalStringSquareBracketEscape = true,
  crystalStringCurlyBraceEscape = true,
  crystalStringAngleBracketEscape = true,
  crystalStringPipeEscape = true,
  crystalStringEnd = true,
  crystalSymbol = true,
  crystalSymbolEnd = true,
  crystalRegex = true,
  crystalRegexEnd = true,
  crystalPCREEscape = true,
  crystalPCREGroup = true,
  crystalPCRELiteral = true,
  crystalPCREMetaCharacter = true,
  crystalPCREClass = true,
  crystalPCREQuantifier = true,
  crystalPCREComment = true,
  crystalPCREControl = true,
  crystalRegexSlashEscape = true,
  crystalCommand = true,
  crystalCommandEnd = true,
  crystalHeredocLine = true,
  crystalHeredocLineRaw = true,
  crystalHeredocEnd = true
}

local function syngroup_at(lnum, col)
  return synIDattr(synID(lnum, col, false), "name")
end

local function get_line_with_first_byte(lnum)
  local line = lnum and getline(lnum) or nvim_get_current_line()

  local b, col

  for i = 1, #line do
    b = line:byte(i)

    if b > 32 then
      col = i
      break
    end
  end

  return line, b, col
end

local function get_line_with_last_byte(lnum)
  local line = getline(lnum)
  local found = 0

  local syngroup

  repeat
    found = line:find("#", found + 1)

    if not found then
      for i = #line, 1, -1 do
        local b = line:byte(i)

        if b > 32 then
          return line, b, i
        end
      end
    end

    syngroup = syngroup_at(lnum, found)
  until syngroup == "crystalComment" or syngroup == "crystalCommentStart" or syngroup == "crystalMarkdownCodeLineStart" or syngroup == "crystalMarkdownCrystalCodeLineStart"

  if found == 1 then
    return line
  end

  for i = found - 1, 1, -1 do
    local b = line:byte(i)

    if b > 32 then
      return line, b, i
    end
  end
end

local function is_operator(byte, col, lnum)
  if byte == 37 or
    byte == 38 or
    byte == 42 or
    byte == 43 or
    byte == 45 or
    byte == 47 or
    byte == 60 or
    byte == 63 or
    byte == 94 or
    byte == 126 then  -- [%&*+-/<?^~]
    return syngroup_at(lnum, col) == "crystalOperator"
  elseif byte == 58 then  -- :
    local syngroup = syngroup_at(lnum, col)
    return syngroup == "crystalOperator" or syngroup == "crystalTypeRestrictionOperator"
  elseif byte == 61 then  -- =
    local syngroup = syngroup_at(lnum, col)
    return syngroup == "crystalOperator" or syngroup == "crystalAssignmentOperator" or syngroup == "crystalMethodAssignmentOperator" or syngroup == "crystalTypeAliasOperator"
  elseif byte == 62 then  -- >
    local syngroup = syngroup_at(lnum, col)
    return syngroup == "crystalOperator" or syngroup == "crystalTypeHashOperator"
  elseif byte == 124 then  -- |
    local syngroup = syngroup_at(lnum, col)
    return syngroup == "crystalOperator" or syngroup == "crystalTypeUnionOperator"
  end

  return false
end

local function is_boundary(byte)
  -- [^%w_:]
  return not byte or
    byte < 48 or
    byte > 57 and byte < 65 and byte ~= 58 or
    byte > 90 and byte < 97 and byte ~= 95 or
    byte > 122
end

-- 0 = no continuation
-- 1 = hanging operator
-- 2 = hanging postfix keyword
-- 3 = comma
-- 4 = named tuple key
local function is_line_continuator(byte, col, line, lnum)
  if byte == 92 then  -- \
    if syngroup_at(lnum, col) == "crystalBackslash" then
      return 1
    end
  elseif byte == 44 then  -- ,
    local syngroup = syngroup_at(lnum, col)

    if syngroup == "crystalComma" or syngroup == "crystalTypeComma" then
      return 3
    end
  elseif byte == 58 then  -- :
    local syngroup = syngroup_at(lnum, col)

    if syngroup == "crystalOperator" or syngroup == "crystalTypeRestrictionOperator" then
      return 1
    elseif syngroup == "crystalNamedTupleKeyDelimiter" then
      return 4
    end
  elseif byte == 101 then  -- e
    -- rescue
    if line:byte(col - 1) == 117 and line:byte(col - 2) == 99 and line:byte(col - 3) == 115 and line:byte(col - 4) == 101 and line:byte(col - 5) == 114 and is_boundary(line:byte(col - 6)) and syngroup_at(lnum, col) == "crystalPostfixKeyword" then
      return 2
    end
  elseif byte == 102 then  -- f
    -- if
    if line:byte(col - 1) == 105 and is_boundary(line:byte(col - 2)) then
      return 2
    end
  elseif byte == 115 then  -- s
    -- unless
    if line:byte(col - 1) == 115 and line:byte(col - 2) == 115 and line:byte(col - 3) == 101 and line:byte(col - 4) == 108 and line:byte(col - 5) == 110 and line:byte(col - 6) == 117 and is_boundary(line:byte(col - 7)) then
      return 2
    end
  elseif is_operator(byte, col, lnum) then
    return 1
  end

  return 0
end

local function get_line_info(lnum)
  local line, first_byte, first_col = get_line_with_first_byte(lnum)

  local last_col
  local pairs = 0
  local has_middle = false
  local brackets = 0
  local bracket_cols = {}
  local floats = 0
  local float_cols = {}
  local operator_col
  local dot_col

  local i = first_col

  while i <= #line do
    local b = line:byte(i)

    if b <= 32 then  -- %s
      goto skip
    elseif b == 35 then  -- #
      local syngroup = syngroup_at(lnum, i)

      if syngroup == "crystalComment" or syngroup == "crystalCommentStart" or syngroup == "crystalMarkdownCodeLineStart" or syngroup == "crystalMarkdownCrystalCodeLineStart" then
        break
      end
    elseif b == 40 or b == 91 or b == 123 then  -- ( [ {
      local syngroup = syngroup_at(lnum, i)

      if syngroup == "crystalDelimiter" or syngroup == "crystalStringArrayDelimiter" or syngroup == "crystalSymbolArrayDelimiter" or syngroup == "crystalStringInterpolationDelimiter" or syngroup == 'crystalMacroDelimiter' then
        brackets = brackets + 1
        bracket_cols[brackets] = i
      end
    elseif b == 41 or b == 93 or b == 125 then  -- ) ] }
      local syngroup = syngroup_at(lnum, i)

      if syngroup == "crystalDelimiter" or syngroup == "crystalStringArrayDelimiter" or syngroup == "crystalSymbolArrayDelimiter" or syngroup == "crystalStringInterpolationDelimiter" or syngroup == 'crystalMacroDelimiter' then
        brackets = brackets - 1
      end
    elseif b == 46 then  -- .
      if not dot_col and i < #line and line:byte(i + 1) ~= 46 then  -- .
        dot_col = i
      end
    elseif is_operator(b, i, lnum) then
      if not operator_col then
        operator_col = i
      end
    elseif b >= 97 and b <= 122 then  -- %l
      local word = line:match("^%l+[%w_?!:]?", i)

      if word == "def" or word == "class" or word == "module" or word == "macro" or word == "struct" or word == "enum" or word == "annotation" or word == "lib" or word == "union" then
        if syngroup_at(lnum, i) == "crystalDefine" then
          pairs = pairs + 1
        end
      elseif word == "if" or word == "unless" or word == "begin" then
        local syngroup = syngroup_at(lnum, i)

        if syngroup == "crystalKeyword" then
          floats = floats + 1
          float_cols[floats] = i
        elseif syngroup == "crystalMacroKeyword" then
          pairs = pairs + 1
        end
      elseif word == "case" or word == "select" or word == "while" or word == "until" then
        if syngroup_at(lnum, i) == "crystalKeyword" then
          floats = floats + 1
          float_cols[floats] = i
        end
      elseif word == "do" then
        local syngroup = syngroup_at(lnum, i)

        if syngroup == "crystalKeyword" then
          floats = floats + 1
          float_cols[floats] = first_col
        elseif syngroup == "crystalMacroKeyword" then
          pairs = pairs + 1
        end
      elseif word == "for" then
        if syngroup_at(lnum, i) == "crystalMacroKeyword" then
          pairs = pairs + 1
        end
      elseif word == "else" then
        if not has_middle then
          local syngroup = syngroup_at(lnum, i)

          if syngroup == "crystalKeyword" or syngroup == "crystalDefine" or syngroup == "crystalMacroKeyword" then
            has_middle = true
          end
        end
      elseif word == "elsif" then
        if not has_middle then
          local syngroup = syngroup_at(lnum, i)

          if syngroup == "crystalKeyword" or syngroup == "crystalMacroKeyword" then
            has_middle = true
          end
        end
      elseif word == "rescue" or word == "ensure" then
        if not has_middle then
          local syngroup = syngroup_at(lnum, i)

          if syngroup == "crystalKeyword" or syngroup == "crystalDefine" then
            has_middle = true
          end
        end
      elseif word == "when" or word == "in" then
        if not has_middle then
          if syngroup_at(lnum, i) == "crystalKeyword" then
            has_middle = true
          end
        end
      elseif word == "end" then
        local syngroup = syngroup_at(lnum, i)

        if syngroup == "crystalKeyword" then
          floats = floats - 1
          has_middle = false
        elseif syngroup == "crystalDefine" or syngroup == "crystalMacroKeyword" then
          pairs = pairs - 1
          has_middle = false
        end
      end

      i = i + #word - 1
    end

    last_col = i

    ::skip::

    i = i + 1
  end

  local last_byte = line:byte(last_col)

  return
    line,
    first_byte, first_col,
    last_byte, last_col,
    pairs, has_middle,
    brackets, bracket_cols[brackets],
    floats, float_cols[floats],
    operator_col, dot_col
end

local function get_line_info_simple(lnum)
  local line, first_byte, first_col = get_line_with_first_byte(lnum)

  local last_col
  local pairs = 0
  local has_middle = false

  local i = first_col

  while i <= #line do
    local b = line:byte(i)

    if b <= 32 then  -- %s
      goto skip
    elseif b == 35 then  -- #
      local syngroup = syngroup_at(lnum, i)

      if syngroup == "crystalComment" or syngroup == "crystalCommentStart" or syngroup == "crystalMarkdownCodeLineStart" or syngroup == "crystalMarkdownCrystalCodeLineStart" then
        break
      end
    elseif b >= 97 and b <= 122 then  -- %l
      local word = line:match("^%l+[%w_?!:]?", i)

      if word == "def" or word == "class" or word == "module" or word == "macro" or word == "struct" or word == "enum" or word == "annotation" or word == "lib" or word == "union" or word == "case" or word == "select" or word == "while" or word == "until" then
        if syngroup_at(lnum, i) == "crystalKeyword" then
          pairs = pairs + 1
        end
      elseif word == 'if' or word == 'unless' or word == 'begin' or word == 'do' then
        local syngroup = syngroup_at(lnum, i)

        if syngroup == 'crystalKeyword' or syngroup == 'crystalMacroKeyword' then
          pairs = pairs + 1
        end
      elseif word == 'for' then
        if syngroup_at(lnum, i) == 'crystalMacroKeyword' then
          pairs = pairs + 1
        end
      elseif word == 'else' or word == 'elsif' then
        if not has_middle then
          local syngroup = syngroup_at(lnum, i)

          if syngroup == 'crystalKeyword' or syngroup == 'crystalMacroKeyword' then
            has_middle = true
          end
        end
      elseif word == "rescue" or word == "ensure" or word == "when" or word == "in" then
        if not has_middle then
          if syngroup_at(lnum, i) == "crystalKeyword" then
            has_middle = true
          end
        end
      elseif word == "end" then
        local syngroup = syngroup_at(lnum, i)

        if syngroup == "crystalKeyword" or syngroup == 'crystalMacroKeyword' then
          pairs = pairs - 1
          has_middle = false
        end
      end

      i = i + #word - 1
    end

    last_col = i

    ::skip::

    i = i + 1
  end

  local last_byte = line:byte(last_col)

  return line, first_byte, first_col, last_byte, last_col, pairs, has_middle
end

local function prev_non_multiline(lnum)
  repeat
    local prev_lnum = prevnonblank(lnum - 1)

    if prev_lnum == 0 then
      return lnum
    end

    lnum = prev_lnum
  until not multiline_regions[syngroup_at(lnum, 1)]

  return lnum
end

local function get_start_line_info(lnum, line, first_byte, first_col, last_byte, last_col, pairs, has_middle, brackets, bracket_col, floats, float_col, operator_col, dot_col)
  local check_multiline = true

  ::check:: do
    -- This line is not the starting line if...

    -- It starts in a multiline region:
    if check_multiline and multiline_regions[syngroup_at(lnum, 1)] then
      lnum = prev_non_multiline(lnum)
      check_multiline = false
      goto next
    end

    -- There are unresolved floating pairs:
    if brackets < 0 or floats < 0 then
      local prev_lnum = prevnonblank(lnum - 1)

      if prev_lnum == 0 then
        goto exit
      end

      lnum = prev_lnum

      check_multiline = true

      goto next
    end

    goto exit
  end

  ::next:: do
    local _pairs, _brackets, _floats

    line, first_byte, first_col, last_byte, last_col, _pairs, has_middle, _brackets, bracket_col, _floats, float_col, operator_col, dot_col =
      get_line_info(lnum)

    pairs = pairs + _pairs
    brackets = brackets + _brackets
    floats = floats + _floats

    goto check
  end

  ::exit:: do
    return lnum, line, first_byte, first_col, last_byte, last_col, pairs, has_middle, brackets, bracket_col, floats, float_col, operator_col, dot_col
  end
end
-- }}}

if g.crystal_simple_indent and g.crystal_simple_indent ~= 0 then
  -- Simple {{{
  function get_crystal_indent()
    local lnum = v.lnum

    do
      local syngroup = syngroup_at(lnum, 1)

      if multiline_regions[syngroup] then
        return -1
      elseif syngroup == "crystalMarkdownCodeBlock" or syngroup == "crystalMarkdownCodeLineStart" or syngroup == "crystalMarkdownCrystalCodeLineStart" then
        -- If this line is part of a fenced code block, simply align
        -- with the previous line.
        return indent(prevnonblank(lnum - 1))
      end
    end

    local prev_lnum = prevnonblank(lnum - 1)

    if prev_lnum == 0 then
      return 0
    end

    local shift = 0

    -- Check the current line for a closing bracket or dedenting keyword:
    local line, first_byte, first_col = get_line_with_first_byte()

    local has_dedent = false

    if first_byte == 41 or first_byte == 93 or first_byte == 125 then  -- ) ] }
      shift = shift - 1
      has_dedent = true
    elseif first_byte == 37 and line:byte(first_col + 1) == 125 then  -- % }
      shift = shift - 1
      has_dedent = true
    elseif first_byte == 123 and line:byte(first_col + 1) == 37 then  -- { %
      for i = first_col + 2, #line do
        local b = line:byte(i)

        if b > 32 then
          local word = line:match("^%l+[%w_?!:]?", i)

          if word == "end" or word == "else" or word == "elsif" then
            shift = shift - 1
            has_dedent = true
          end

          break
        end
      end
    elseif first_byte == 92 and line:byte(first_col + 1) == 123 and line:byte(first_col + 2) == 37 then  -- \ { %
      for i = first_col + 3, #line do
        local b = line:byte(i)

        if b > 32 then
          local word = line:match("^%l+[%w_?!:]?", i)

          if word == "end" or word == "else" or word == "elsif" then
            shift = shift - 1
            has_dedent = true
          end

          break
        end
      end
    else
      local word = line:match("^%l+[%w_?!:]?", first_col)

      if word == "end" or word == "else" or word == "elsif" or word == "when" or word == "in" or word == "rescue" or word == "ensure" then
        shift = shift - 1
        has_dedent = true
      end
    end

    -- Check the previous line:
    local prev_line, prev_first_byte, prev_first_col, prev_last_byte, prev_last_col, prev_pairs, prev_has_middle =
      get_line_info_simple(prev_lnum)

    local total_pairs = prev_pairs

    -- Check the starting line:
    local start_lnum, start_line, start_first_byte, start_first_col, start_last_byte, start_last_col, start_pairs, start_has_middle

    if multiline_regions[syngroup_at(prev_lnum, 1)] then
      start_lnum = prev_non_multiline(prev_lnum)
      start_line, start_first_byte, start_first_col, start_last_byte, start_last_col, start_pairs, start_has_middle =
        get_line_info_simple(start_lnum)

      total_pairs = total_pairs + start_pairs
    else
      start_lnum, start_line, start_first_byte, start_first_col, start_last_byte, start_last_col, start_pairs, start_has_middle =
        prev_lnum, prev_line, prev_first_byte, prev_first_col, prev_last_byte, prev_last_col, prev_pairs, prev_has_middle
    end

    if prev_last_byte == 40 or prev_last_byte == 91 or prev_last_byte == 123 then  -- ( [ {
      local syngroup = syngroup_at(prev_lnum, prev_last_col)

      if syngroup == "crystalDelimiter" or syngroup == "crystalStringArrayDelimiter" or syngroup == "crystalSymbolArrayDelimiter" or syngroup == "crystalStringInterpolationDelimiter" or syngroup == 'crystalMacroDelimiter' then
        shift = shift + 1
        return start_first_col - 1 + shift * bo.shiftwidth
      end
    elseif prev_last_byte == 37 then  -- %
      if prev_line:byte(prev_last_col - 1) == 123 and syngroup_at(prev_lnum, prev_last_col) == 'crystalMacroDelimiter' then
        shift = shift + 1
        return start_first_col - 1 + shift * bo.shiftwidth
      end
    elseif prev_last_byte == 124 then  -- |
      if syngroup_at(prev_lnum, prev_last_col) == "crystalDelimiter" then
        shift = shift + 1
        return start_first_col - 1 + shift * bo.shiftwidth
      end
    end

    if total_pairs > 0 then
      shift = shift + 1
      return start_first_col - 1 + shift * bo.shiftwidth
    end

    if start_has_middle or prev_has_middle then
      shift = shift + 1
      return start_first_col - 1 + shift * bo.shiftwidth
    end

    -- Check for a line continuation:
    -- 0 = no continuation
    -- 1 = hanging operator
    -- 2 = hanging postfix keyword
    -- 3 = comma
    -- 4 = named tuple key
    -- 5 = leading dot
    local continuation

    if first_byte == 46 and line:byte(first_col + 1) ~= 46 then  -- .
      continuation = 5
    else
      continuation = is_line_continuator(prev_last_byte, prev_last_col, prev_line, prev_lnum)
    end

    -- Subtract a shift if the starting line was also a line
    -- continuation:
    local prev_continuation

    if start_first_byte == 46 and start_line:byte(start_first_col + 1) ~= 46 then  -- .
      prev_continuation = 5
    else
      local prev_prev_lnum = prevnonblank(start_lnum - 1)

      if prev_prev_lnum > 0 then
        local prev_prev_line, prev_prev_last_byte, prev_prev_last_col = get_line_with_last_byte(prev_prev_lnum)

        if continuation == 3 and (prev_prev_last_byte == 40 or prev_prev_last_byte == 91 or prev_prev_last_byte == 123) then  -- ( [ {
          return start_first_col - 1
        end

        prev_continuation = is_line_continuator(prev_prev_last_byte, prev_prev_last_col, prev_prev_line, prev_prev_lnum)
      end
    end

    if continuation == 0 then
      if prev_continuation == 1 or prev_continuation == 2 or prev_continuation == 5 then
        shift = shift - 1
      elseif prev_continuation == 3 then
        if not has_dedent and prev_first_byte ~= 41 and prev_first_byte ~= 93 and prev_first_byte ~= 125 and prev_line:match("^end[%w_?!:]?", prev_first_col) ~= "end" then  -- ) ] }
          shift = shift - 1
        end
      end
    elseif continuation == 1 then
      if prev_continuation == 1 or prev_continuation == 2 or prev_continuation == 4 then
        return start_first_col - 1
      end

      shift = shift + 1
    elseif continuation == 2 then
      if prev_continuation == 2 then
        return start_first_col - 1
      elseif prev_continuation == 4 then
        shift = shift - 1
      end

      shift = shift + 1
    elseif continuation == 3 then
      if prev_continuation == 1 or prev_continuation == 2 or prev_continuation == 4 then
        shift = shift - 2
      elseif prev_continuation == 3 then
        shift = shift - 1
      elseif prev_first_byte == 41 or prev_first_byte == 93 or prev_first_byte == 125 or prev_line:match("^end[%w_?!:]?", prev_first_col) == "end" then  -- ) ] }
        shift = shift - 1
      end

      shift = shift + 1
    elseif continuation == 4 then
      return start_first_col - 1 + bo.shiftwidth
    elseif continuation == 5 then
      if prev_continuation == 5 then
        return start_first_col - 1
      end

      shift = shift + 1
    end

    return start_first_col - 1 + shift * bo.shiftwidth
  end
  -- }}}
else
  -- Default {{{
  function get_crystal_indent()
    local lnum = v.lnum

    do
      local syngroup = syngroup_at(lnum, 1)

      if multiline_regions[syngroup] then
        return -1
      elseif syngroup == "crystalMarkdownCodeBlock" or syngroup == "crystalMarkdownCodeLineStart" or syngroup == "crystalMarkdownCrystalCodeLineStart" then
        -- If this line is part of a fenced code block, simply align
        -- with the previous line.
        return indent(prevnonblank(lnum - 1))
      end
    end

    local prev_lnum = prevnonblank(lnum - 1)

    if prev_lnum == 0 then
      return 0
    end

    local shift = 0

    -- Check the current line for a closing bracket or dedenting keyword:
    local line, first_byte, first_col = get_line_with_first_byte()

    local has_dedent = false

    if first_byte == 41 or first_byte == 93 or first_byte == 125 then  -- ) ] }
      shift = shift - 1
      has_dedent = true
    elseif first_byte == 123 and line:byte(first_col + 1) == 37 then  -- { %
      for i = first_col + 2, #line do
        local b = line:byte(i)

        if b > 32 then
          local word = line:match("^%l+[%w_?!:]?", i)

          if word == "end" or word == "else" or word == "elsif" then
            shift = shift - 1
            has_dedent = true
          end

          break
        end
      end
    elseif first_byte == 92 and line:byte(first_col + 1) == 123 and line:byte(first_col + 2) == 37 then  -- \ { %
      for i = first_col + 3, #line do
        local b = line:byte(i)

        if b > 32 then
          local word = line:match("^%l+[%w_?!:]?", i)

          if word == "end" or word == "else" or word == "elsif" then
            shift = shift - 1
            has_dedent = true
          end

          break
        end
      end
    else
      local word = line:match("^%l+[%w_?!:]?", first_col)

      if word == "end" or word == "else" or word == "elsif" or word == "when" or word == "in" or word == "rescue" or word == "ensure" then
        shift = shift - 1
        has_dedent = true
      end
    end

    -- Check the previous line:
    local prev_line, prev_first_byte, prev_first_col, prev_last_byte, prev_last_col, prev_pairs, prev_has_middle, prev_brackets, prev_bracket_col, prev_floats, prev_float_col, prev_operator_col, prev_dot_col =
      get_line_info(prev_lnum)

    if prev_bracket_col then
      if prev_bracket_col == prev_last_col then
        shift = shift + 1
        return prev_first_col - 1 + shift * bo.shiftwidth
      else
        -- Align with the first non-whitespace character after the
        -- bracket:
        for i = prev_bracket_col + 1, prev_last_col do
          local b = prev_line:byte(i)

          if b > 32 then
            if b == 124 then  -- |
              shift = shift + 1
              return prev_first_col - 1 + shift * bo.shiftwidth
            else
              return i - 1
            end
          end
        end
      end
    end

    if prev_floats > 0 then
      shift = shift + 1
      return prev_float_col - 1 + shift * bo.shiftwidth
    end

    if prev_pairs > 0 or prev_has_middle then
      shift = shift + 1
      return prev_first_col - 1 + shift * bo.shiftwidth
    end

    -- Check the starting line:
    local start_lnum, start_line, start_first_byte, start_first_col, start_last_byte, start_last_col, start_pairs, start_has_middle, start_brackets, start_bracket_col, start_floats, start_float_col, start_operator_col, start_dot_col =
      get_start_line_info(prev_lnum, prev_line, prev_first_byte, prev_first_col, prev_last_byte, prev_last_col, prev_pairs, prev_has_middle, prev_brackets, prev_bracket_col, prev_floats, prev_float_col, prev_operator_col, prev_dot_col)

    if start_lnum < prev_lnum then
      if start_brackets > 0 then
        if start_bracket_col == start_last_col then
          shift = shift + 1
          return start_first_col - 1 + shift * bo.shiftwidth
        else
          -- Align with the first non-whitespace character after the
          -- bracket:
          for i = start_bracket_col + 1, start_last_col do
            local b = start_line:byte(i)

            if b > 32 then
              if b == 124 then  -- |
                shift = shift + 1
                return start_first_col - 1 + shift * bo.shiftwidth
              else
                return i - 1
              end
            end
          end
        end
      end

      if start_floats > 0 then
        shift = shift + 1
        return start_float_col - 1 + shift * bo.shiftwidth
      end

      if start_pairs > 0 or start_has_middle then
        shift = shift + 1
        return start_first_col - 1 + shift * bo.shiftwidth
      end
    end

    -- Check for a line continuation:
    -- 0 = no continuation
    -- 1 = hanging operator
    -- 2 = hanging postfix keyword
    -- 3 = comma
    -- 4 = named tuple key
    -- 5 = leading dot
    local continuation

    if first_byte == 46 and line:byte(first_col + 1) ~= 46 then  -- .
      continuation = 5
    else
      continuation = is_line_continuator(prev_last_byte, prev_last_col, prev_line, prev_lnum)
    end

    -- Subtract a shift if the starting line was also a line
    -- continuation:
    local prev_continuation

    if start_first_byte == 46 and start_line:byte(start_first_col + 1) ~= 46 then  -- .
      prev_continuation = 5
    else
      local prev_prev_lnum = prevnonblank(start_lnum - 1)

      if prev_prev_lnum > 0 then
        local prev_prev_line, prev_prev_last_byte, prev_prev_last_col = get_line_with_last_byte(prev_prev_lnum)

        if continuation == 3 and (prev_prev_last_byte == 40 or prev_prev_last_byte == 91 or prev_prev_last_byte == 123) then  -- ( [ {
          return start_first_col - 1
        end

        prev_continuation = is_line_continuator(prev_prev_last_byte, prev_prev_last_col, prev_prev_line, prev_prev_lnum)
      end
    end

    if continuation == 0 then
      if prev_continuation == 1 or prev_continuation == 3 or prev_continuation == 5 then
        goto msl
      elseif prev_continuation == 2 then
        shift = shift - 1
      end

      return start_first_col - 1 + shift * bo.shiftwidth
    elseif continuation == 1 then
      if prev_continuation == 1 or prev_continuation == 2 or prev_continuation == 4 then
        return start_first_col - 1
      end

      if start_operator_col then
        for i = start_operator_col + 1, start_last_col do
          local b = start_line:byte(i)

          if b > 32 and not is_operator(b, i, start_lnum) then
            return i - 1
          end
        end
      elseif prev_operator_col then
        for i = prev_operator_col + 1, prev_last_col do
          local b = prev_line:byte(i)

          if b > 32 and not is_operator(b, i, prev_lnum) then
            return i - 1
          end
        end
      end

      return start_first_col - 1 + bo.shiftwidth
    elseif continuation == 2 then
      if prev_continuation == 1 or prev_continuation == 5 then
        goto msl
      elseif prev_continuation == 2 then
        return start_first_col - 1
      elseif prev_continuation == 4 then
        shift = shift - 1
      end

      shift = shift + 1
      return start_first_col - 1 + shift * bo.shiftwidth
    elseif continuation == 3 then
      if prev_continuation == 1 or prev_continuation == 2 or prev_continuation == 4 or prev_continuation == 5 then
        goto msl
      elseif prev_continuation == 3 then
        shift = shift - 1
      end

      shift = shift + 1
      return start_first_col - 1 + shift * bo.shiftwidth
    elseif continuation == 4 then
      return start_first_col - 1 + bo.shiftwidth
    elseif continuation == 5 then
      if prev_continuation == 5 then
        return start_first_col - 1
      end

      if start_dot_col then
        return start_dot_col - 1
      elseif prev_dot_col then
        return prev_dot_col - 1
      end

      return start_first_col - 1 + bo.shiftwidth
    end

    ::msl::

    -- Align with the first previous starting line that is not
    -- a line continuation:
    local prev_prev_lnum, prev_prev_line, prev_prev_first_byte, prev_prev_first_col, prev_prev_last_byte, prev_prev_last_col, prev_prev_pairs, prev_prev_has_middle, prev_prev_brackets, prev_prev_bracket_col, prev_prev_floats, prev_prev_float_col, prev_prev_operator_col, prev_prev_dot_col

    prev_prev_lnum = prevnonblank(start_lnum - 1)

    if prev_prev_lnum == 0 then
      goto exit
    end

    prev_prev_line, prev_prev_first_byte, prev_prev_first_col, prev_prev_last_byte, prev_prev_last_col, prev_prev_pairs, prev_prev_has_middle, prev_prev_brackets, prev_prev_bracket_col, prev_prev_floats, prev_prev_float_col, prev_prev_operator_col, prev_prev_dot_col =
      get_line_info(prev_prev_lnum)

    start_lnum, start_line, start_first_byte, start_first_col, start_last_byte, start_last_col, start_pairs, start_has_middle, start_brackets, start_bracket_col, start_floats, start_float_col, start_operator_col, start_dot_col =
      get_start_line_info(prev_prev_lnum, prev_prev_line, prev_prev_first_byte, prev_prev_first_col, prev_prev_last_byte, prev_prev_last_col, prev_prev_pairs, prev_prev_has_middle, prev_prev_brackets, prev_prev_bracket_col, prev_prev_floats, prev_prev_float_col, prev_prev_operator_col, prev_prev_dot_col)

    ::loop:: do
      local continuation

      if start_first_byte == 46 and start_line:byte(start_first_col + 1) ~= 46 then  -- .
        continuation = 5
      end

      prev_prev_lnum = prevnonblank(start_lnum - 1)

      if prev_prev_lnum == 0 then
        goto exit
      end

      prev_prev_line, prev_prev_first_byte, prev_prev_first_col, prev_prev_last_byte, prev_prev_last_col, prev_prev_pairs, prev_prev_has_middle, prev_prev_brackets, prev_prev_bracket_col, prev_prev_floats, prev_prev_float_col, prev_prev_operator_col, prev_prev_dot_col =
        get_line_info(prev_prev_lnum)

      if not continuation then
        continuation = is_line_continuator(prev_prev_last_byte, prev_prev_last_col, prev_prev_line, prev_prev_lnum)
      end

      if continuation == 1 or continuation == 2 or continuation == 3 or continuation == 5 then
        start_lnum, start_line, start_first_byte, start_first_col, start_last_byte, start_last_col, start_pairs, start_has_middle, start_brackets, start_bracket_col, start_floats, start_float_col, start_operator_col, start_dot_col =
          get_start_line_info(prev_prev_lnum, prev_prev_line, prev_prev_first_byte, prev_prev_first_col, prev_prev_last_byte, prev_prev_last_col, prev_prev_pairs, prev_prev_has_middle, prev_prev_brackets, prev_prev_bracket_col, prev_prev_floats, prev_prev_float_col, prev_prev_operator_col, prev_prev_dot_col)

        goto loop
      elseif continuation == 4 then
        shift = shift - 1
      end
    end

    ::exit::

    return start_first_col - 1 + shift * bo.shiftwidth
  end
  -- }}}
end

-- vim:fdm=marker
