local v = vim.v

local fn = vim.fn
local prevnonblank = fn.prevnonblank
local shiftwidth = fn.shiftwidth
local synID = fn.synID
local synIDattr = fn.synIDattr

local api = vim.api
local nvim_get_current_line = api.nvim_get_current_line
local nvim_buf_get_lines = api.nvim_buf_get_lines

local multiline_regions = {
  crystalString = true,
  crystalSymbol = true,
  crystalRegex = true,
  crystalCommand = true,
  crystalHeredocLine = true,
  crystalHeredocLineRaw = true,
  crystalHeredocDelimiter = true
}

local syngroups = {}

local function syngroup_at(lnum, idx)
  local synid = synid_at(lnum, idx)
  local syngroup = syngroups[synid]

  if not syngroup then
    local name = synIDattr(synid, "name")

    syngroups[synid] = name
    syngroup = name
  end

  return syngroup
end

local function is_word(b)
  -- [_%w]
  return b == 95 or  -- _
    b >= 48 and b <= 57 or  -- %d
    b >= 65 and b <= 90 or  -- %u
    b >= 97 and b <= 122  -- %l
end

local function is_word_boundary(b)
  return not b or not is_word(b)
end

local function prev_non_multiline(lnum)
  while multiline_regions[syngroup_at(lnum, 0)] do
    lnum = prevnonblank(lnum - 1)
  end

  return lnum
end

-- First, try to find a comment delimiter: if one is found, the
-- non-whitespace byte immediately before it is the last byte; else,
-- simply find the last non-whitespace byte in the line.
local function get_last_byte(lnum)
  local line = get_line(lnum)
  local found = 0

  repeat
    found = line:find("#", found + 1)

    if not found then
      for i = #line, 1, -1 do
        local b = line:byte(i)

        if b > 32 then
          return b, i, line
        end
      end
    end
  until syngroup_at(lnum, found) == "crystalCommentDelimiter"

  for i = found - 1, 1, -1 do
    local b = line:byte(i)

    if b > 32 then
      return b, i, line
    end
  end

  return nil, found, line
end

-- +&\=
-- -&\=
-- |
-- \^
-- \~[=!]\=
-- %
-- \*\%(&\|\*&\=\)\= (type declaration)
-- / (crystalRegexDelimiter)
-- =\%(!\|==\=\=\)
-- !
-- >[=>]\=
-- <<\=
-- ? (type declaration)
local function is_operator(b, col, line, lnum)
  -- Determining whether or not a given character is an operator is
  -- tricky because we first need to ensure that it isn't part of
  -- a symbol or operator method. We could do this through querying the
  -- character's syntax, but lexical analysis should be faster.
  if b == 43 or b == 45 then  -- + -
    local b2 = line:byte(col - 1)
    local target

    if b2 == 38 then  -- &
      target = line:byte(col - 2)
    else
      target = b2
    end

    return target ~= 46 and target ~= 58  -- . :
  elseif b == 33 or b == 37 or b == 94 or b == 124 then  -- ! % ^ |
    local target = line:byte(col - 1)
    return target ~= 46 and target ~= 58  -- . :
  elseif b == 126 then  -- ~
    local b2 = line:byte(col - 1)
    local target

    if b2 == 33 or b2 == 61 then  -- ! =
      target = line:byte(col - 2)
    else
      target = b2
    end

    return target ~= 46 and target ~= 58  -- . :
  elseif b == 42 then  -- *
    local b2 = line:byte(col - 1)

    if b2 == 38 then  -- &
      local target = line:byte(col - 2)
      return target ~= 46 and target ~= 58  -- . :
    elseif b2 == 42 then  -- *
      local b3 = line:byte(col - 2)

      if b3 == 38 then  -- &
        target = line:byte(col - 3)
      else
        target = b3
      end
    end

    return target ~= 46 and target ~= 58  -- . :
  elseif b == 47 then  -- /
  end
end

return function()
  local lnum = v.lnum

  -- If the current line is inside of a multiline region, do nothing.
  if skip_char(lnum, 0) then
    return -1
  end

  local prev_lnum = prevnonblank(lnum - 1)

  if prev_lnum == 0 then
    return 0
  end

  -- Retrieve indentation info for the previous line.
  local last_byte, last_col, prev_line = get_last_byte(prev_lnum)

  local first_col
  local is_cont = false

  if last_byte then
    -- If the previous line begins in a multiline region, find the line
    -- that began that region.
    local start_lnum, start_line, first_byte

    if multiline_regions[syngroup_at(prev_lnum, 0)] then
      start_lnum = prev_non_multiline(prevnonblank(prev_lnum - 1))
      start_line = get_line(prev_lnum)
    else
      start_lnum = prev_lnum
      start_line = prev_line
    end

    -- Find the first column and first byte of the line.
    for i = 1, #start_line do
      first_byte = start_line:byte(i)

      if first_byte > 32 then  -- %S
        first_col = i
        break
      end
    end

    -- Determine whether or not the line is a continuation.
    if first_byte == 46 and start_line:byte(first_col + 1) ~= 46 then  -- .
      is_cont = true
    elseif first_byte == 40 or first_byte == 91 or first_byte == 123 or is_word(first_byte) then  -- [(%[{%w_]
      local lnum = prevnonblank(start_lnum - 1)

      if lnum ~= 0 then
        local b, col, line = get_last_byte(lnum)

        if b and (b == 92 or is_operator(b, col, line, lnum)) then  -- \
          is_cont = true
        end
      end
    end
  else
    -- The previous line is a comment line.
    first_col = last_col
  end

  -- Find the first character in the current line.
  local line = nvim_get_current_line()
  local col, b

  for i = 1, #line do
    b = line:byte(i)

    if b > 32 then  -- %S
      col = i
      break
    end
  end

  if b == 46 then  -- .
    -- If the current line begins with a leading dot, add a shift
    -- unless the previous line was a line continuation.

    local b2 = line:byte(col + 1)

    if not b2 or b2 < 48 or b2 > 57 then  -- %D
      if is_cont then
        return first_col - 1
      else
        return first_col - 1 + shiftwidth()
      end
    end
  elseif b == 41 then  -- )
    -- If the current line begins with a closing bracket, subtract
    -- a shift unless the previous character was the corresponding
    -- opening bracket; subtract an additional shift if the previous
    -- line was a continuation.

    local shift = 1

    if last_byte == 40 then  -- (
      shift = 0
    end

    if is_cont then
      shift = shift + 1
    end

    return first_col - 1 - shift * shiftwidth()
  elseif b == 125 then  -- }
    local shift = 1

    if last_byte == 123 then  -- {
      shift = 0
    end

    if is_cont then
      shift = shift + 1
    end

    return first_col - 1 - shift * shiftwidth()
  elseif b == 101 then  -- e
    local b2 = line:byte(col + 1)

    if b2 == 110 then  -- n
      if line:byte(col + 2) == 100 and  -- d
        is_word_boundary(line:byte(col + 3)) then
        -- If the first word is `end`, subtract a shift unless the
        -- previous word was either `then`, `else`, or `do` or if the
        -- previous character was the closing parenthesis of a function
        -- definition; subtract an additional shift if the previous line
        -- was a continuation.

        local shift = 1

        if last_byte == 110 then  -- n
          if prev_line:byte(last_col - 3) == 116 and  -- t
            prev_line:byte(last_col - 2) == 104 and  -- h
            prev_line:byte(last_col - 1) == 101 and  -- e
            is_word_boundary(prev_line:byte(last_col - 4)) then
            shift = 0
          end
        elseif last_byte == 101 then  -- e
          if prev_line:byte(last_col - 3) == 101 and  -- e
            prev_line:byte(last_col - 2) == 108 and  -- l
            prev_line:byte(last_col - 1) == 115 and  -- s
            is_word_boundary(prev_line:byte(last_col - 4)) then
            shift = 0
          end
        elseif last_byte == 111 then  -- o
          if prev_line:byte(last_col - 1) == 100 and  -- d
            is_word_boundary(prev_line:byte(last_col - 2)) then
            shift = 0
          end
        elseif last_byte == 41 then  -- )
          if syngroup_at(prev_lnum, last_col - 1) == "luaFunctionParameters" then
            shift = 0
          end
        end

        if is_cont then
          shift = shift + 1
        end

        return first_col - 1 - shift * shiftwidth()
      end
    elseif b2 == 108 and  -- l
      line:byte(col + 2) == 115 and  -- s
      line:byte(col + 3) == 101 then  -- e
      local b3 = line:byte(col + 4)

      if b3 == 105 and  -- i
        line:byte(col + 5) == 102 and  -- f
        is_word_boundary(line:byte(col + 6)) or
        is_word_boundary(b3) then
        -- If the first word is `else` or `elseif`, subtract a shift
        -- if the previous word isn't `then`; subtract an additional
        -- shift if the previous line is a continuation.

        local shift = 1

        if last_byte == 110 then  -- n
          if prev_line:byte(last_col - 3) == 116 and  -- t
            prev_line:byte(last_col - 2) == 104 and  -- h
            prev_line:byte(last_col - 1) == 101 and  -- e
            is_word_boundary(prev_line:byte(last_col - 4)) then
            shift = 0
          end
        end

        if is_cont then
          shift = shift + 1
        end

        return first_col - 1 - shift * shiftwidth()
      end
    end
  elseif b == 117 then  -- u
    if line:byte(col + 1) == 110 and  -- n
      line:byte(col + 2) == 116 and  -- t
      line:byte(col + 3) == 105 and  -- i
      line:byte(col + 4) == 108 and  -- l
      is_word_boundary(line:byte(col + 5)) then
      -- If the first word is `until`, subtract a shift if the previous
      -- word isn't `repeat`; subtract an additional shift if the
      -- previous line is a continuation.

      local shift = 1

      if last_byte == 116 then  -- t
        if prev_line:byte(last_col - 5) == 114 and  -- r
          prev_line:byte(last_col - 4) == 101 and  -- e
          prev_line:byte(last_col - 3) == 112 and  -- p
          prev_line:byte(last_col - 2) == 101 and  -- e
          prev_line:byte(last_col - 1) == 97 and  -- a
          is_word_boundary(prev_line:byte(last_col - 6)) then
          shift = 0
        end
      end

      if is_cont then
        shift = shift + 1
      end

      return first_col - 1 - shift * shiftwidth()
    end
  end

  -- If we can't determine the indent from the current line, examine the
  -- previous line.

  if not last_byte then
    return first_col - 1
  end

  local shift = 0

  b = last_byte

  if b == 35 or  -- #
    b == 37 or  -- %
    b == 38 or  -- &
    b == 40 or  -- (
    b == 42 or  -- *
    b == 43 or  -- +
    b == 45 or  -- -
    b == 47 or  -- /
    b == 60 or  -- <
    b == 61 or  -- =
    b == 62 or  -- >
    b == 92 or  -- \
    b == 94 or  -- ^
    b == 123 or  -- {
    b == 124 or  -- |
    b == 126 then  -- ~
    shift = 1
  elseif b == 100 then  -- d
    if prev_line:byte(last_col - 2) == 97 and  -- a
      prev_line:byte(last_col - 1) == 110 and  -- n
      is_word_boundary(prev_line:byte(last_col - 3)) then
      shift = 1
    end
  elseif b == 114 then  -- r
    if prev_line:byte(last_col - 1) == 111 and  -- o
      is_word_boundary(prev_line:byte(last_col - 2)) then
      shift = 1
    end
  elseif b == 110 then  -- n
    if prev_line:byte(last_col - 3) == 116 and  -- t
      prev_line:byte(last_col - 2) == 104 and  -- h
      prev_line:byte(last_col - 1) == 101 and  -- e
      is_word_boundary(prev_line:byte(last_col - 4)) then
      shift = 1
    end
  elseif b == 101 then  -- e
    if prev_line:byte(last_col - 3) == 101 and  -- e
      prev_line:byte(last_col - 2) == 108 and  -- l
      prev_line:byte(last_col - 1) == 115 and  -- s
      is_word_boundary(prev_line:byte(last_col - 4)) then
      shift = 1
    end
  elseif b == 111 then  -- o
    if prev_line:byte(last_col - 1) == 100 and  -- d
      is_word_boundary(prev_line:byte(last_col - 2)) then
      shift = 1
    end
  elseif b == 116 then  -- t
    if prev_line:byte(last_col - 5) == 114 and  -- r
      prev_line:byte(last_col - 4) == 101 and  -- e
      prev_line:byte(last_col - 3) == 112 and  -- p
      prev_line:byte(last_col - 2) == 101 and  -- e
      prev_line:byte(last_col - 1) == 97 and  -- a
      is_word_boundary(prev_line:byte(last_col - 6)) then
      shift = 1
    end
  elseif b == 41 then  -- )
    -- If the previous character was a closing parenthesis, add a shift
    -- if it is preceded by `function`.

    if syngroup_at(prev_lnum, last_col - 1) == "luaFunctionParameters" then
      shift = 1
    end
  end

  if is_cont then
    shift = shift - 1
  end

  return first_col - 1 + shift * shiftwidth()
end
