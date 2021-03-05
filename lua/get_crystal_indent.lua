local v = vim.v

local fn = vim.fn
local prevnonblank = fn.prevnonblank
local shiftwidth = fn.shiftwidth
local synID = fn.synID
local synIDattr = fn.synIDattr

local api = vim.api
local nvim_get_current_line = api.nvim_get_current_line
local nvim_buf_get_lines = api.nvim_buf_get_lines

-- Helpers {{{
local MULTILINE_REGIONS = {
  crystalString = true,
  crystalSymbol = true,
  crystalRegex = true,
  crystalCommand = true,
  crystalHeredocLine = true,
  crystalHeredocLineRaw = true,
  crystalHeredocDelimiter = true
}

local SYNGROUPS = {}

local function syngroup_at(lnum, col)
  local synid = synID(lnum, col, false)
  local syngroup = SYNGROUPS[synid]

  if not syngroup then
    local name = synIDattr(synid, "name")

    SYNGROUPS[synid] = name
    syngroup = name
  end

  return syngroup
end

local function is_boundary(b)
  -- [^_%w]
  return
    b < 48 or
    b > 57 and b < 65 or
    b > 90 and b < 97 and b ~= 95 or
    b > 122
end

local function prev_non_multiline(lnum)
  while MULTILINE_REGIONS[syngroup_at(lnum, 1)] do
    lnum = prevnonblank(lnum - 1)
  end

  return lnum
end

local function get_line(lnum)
  return nvim_buf_get_lines(0, lnum - 1, lnum, false)[1]
end

local function is_operator(byte, lnum, col, line)
  if byte == 37 or  -- %
    byte == 38 or  -- &
    byte == 43 or  -- +
    byte == 45 or  -- -
    byte == 47 or  -- /
    byte == 58 or  -- :
    byte == 60 or  -- <
    byte == 61 or  -- =
    byte == 62 or  -- >
    byte == 94 or  -- ^
    byte == 124 or  -- |
    byte == 126 then  -- ~
    return syngroup_at(lnum, col) == "crystalOperator"
  elseif byte == 42 or byte == 63 then  -- * ?
    -- Find the first character prior to this one that isn't also a * or
    -- ?.
    for i = col - 1, 1, -1 do
      local b = line:byte(i)

      if b ~= 42 and b ~= 63 then  -- * ?
        if b <= 32 then
          return syngroup_at(lnum, col) == "crystalOperator"
        else
          return false
        end
      end
    end
  end

  return false
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
    elseif found == 1 then
      return nil, 1, line
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

-- Find the number of unpaired indenting keywords in the given line.
local function get_keyword_pairs(line, lnum, i, j)
  i = i or 1
  j = j or #line

  local pairs = 0

  while i < j do
    local b = line:byte(i)
    local start

    if b == 97 then  -- a
      i = i + 1
      b = line:byte(i)

      if b == 110 then  -- n
        i = i + 1
        b = line:byte(i)

        if b == 110 then  -- n
          i = i + 1
          b = line:byte(i)

          if b == 111 then  -- o
            i = i + 1
            b = line:byte(i)

            if b == 116 then  -- t
              i = i + 1
              b = line:byte(i)

              if b == 97 then  -- a
                i = i + 1
                b = line:byte(i)

                if b == 116 then  -- t
                  i = i + 1
                  b = line:byte(i)

                  if b == 105 then  -- i
                    i = i + 1
                    b = line:byte(i)

                    if b == 111 then  -- o
                      i = i + 1
                      b = line:byte(i)

                      if b == 110 then  -- n
                        -- annotation
                        start = i - 9
                        goto kw_start
                      end
                    end
                  end
                end
              end
            end
          end
        end
      end
    elseif b == 98 then  -- b
      i = i + 1
      b = line:byte(i)

      if b == 101 then  -- e
        i = i + 1
        b = line:byte(i)

        if b == 103 then  -- g
          i = i + 1
          b = line:byte(i)

          if b == 105 then  -- i
            i = i + 1
            b = line:byte(i)

            if b == 110 then  -- n
              -- begin
              start = i - 4
              goto kw_start
            end
          end
        end
      end
    elseif b == 99 then  -- c
      i = i + 1
      b = line:byte(i)

      if b == 97 then  -- a
        i = i + 1
        b = line:byte(i)

        if b == 115 then  -- s
          i = i + 1
          b = line:byte(i)

          if b == 101 then  -- e
            -- case
            start = i - 3
            goto kw_start
          end
        end
      elseif b == 108 then  -- l
        i = i + 1
        b = line:byte(i)

        if b == 97 then  -- a
          i = i + 1
          b = line:byte(i)

          if b == 115 then  -- s
            i = i + 1
            b = line:byte(i)

            if b == 115 then  -- s
              -- class
              start = i - 4
              goto kw_start
            end
          end
        end
      end
    elseif b == 100 then  -- d
      i = i + 1
      b = line:byte(i)

      if b == 101 then  -- e
        i = i + 1
        b = line:byte(i)

        if b == 102 then  -- f
          -- def
          start = i - 2
          goto kw_start
        end
      elseif b == 111 then  -- o
        -- do
        start = i - 1
        goto kw_start
      end
    elseif b == 101 then  -- e
      i = i + 1
      b = line:byte(i)

      if b == 108 then  -- l
        i = i + 1
        b = line:byte(i)

        if b == 115 then  -- s
          i = i + 1
          b = line:byte(i)

          if b == 101 then  -- e
            -- else
            start = i - 3
            goto kw_middle
          elseif b == 105 then  -- i
            i = i + 1
            b = line:byte(i)

            if b == 102 then  -- f
              -- elsif
              start = i - 4
              goto kw_middle
            end
          end
        end
      elseif b == 110 then  -- n
        i = i + 1
        b = line:byte(i)

        if b == 100 then  -- d
          -- end
          start = i - 2
          goto kw_end
        elseif b == 115 then  -- s
          i = i + 1
          b = line:byte(i)

          if b == 117 then  -- u
            i = i + 1
            b = line:byte(i)

            if b == 114 then  -- r
              i = i + 1
              b = line:byte(i)

              if b == 101 then  -- e
                -- ensure
                start = i - 5
                goto kw_middle
              end
            end
          end
        elseif b == 117 then  -- u
          i = i + 1
          b = line:byte(i)

          if b == 109 then  -- m
            -- enum
            start = i - 3
            goto kw_start
          end
        end
      end
    elseif b == 102 then  -- f
      i = i + 1
      b = line:byte(i)

      if b == 111 then  -- o
        i = i + 1
        b = line:byte(i)

        if b  == 114 then  -- r
          -- for
          start = i - 2
          goto kw_start
        end
      end
    elseif b == 105 then  -- i
      i = i + 1
      b = line:byte(i)

      if b == 102 then  -- f
        -- if
        start = i - 1
        goto kw_start
      elseif b == 110 then  -- n
        -- in
        start = i - 1
        goto kw_middle
      end
    elseif b == 108 then  -- l
      i = i + 1
      b = line:byte(i)

      if b == 105 then  -- i
        i = i + 1
        b = line:byte(i)

        if b == 98 then  -- b
          -- lib
          start = i - 2
          goto kw_start
        end
      end
    elseif b == 109 then  -- m
      i = i + 1
      b = line:byte(i)

      if b == 97 then  -- a
        i = i + 1
        b = line:byte(i)

        if b == 99 then  -- c
          i = i + 1
          b = line:byte(i)

          if b == 114 then  -- r
            i = i + 1
            b = line:byte(i)

            if b == 111 then  -- o
              -- macro
              start = i - 4
              goto kw_start
            end
          end
        end
      elseif b == 111 then  -- o
        i = i + 1
        b = line:byte(i)

        if b == 100 then  -- d
          i = i + 1
          b = line:byte(i)

          if b == 117 then  -- u
            i = i + 1
            b = line:byte(i)

            if b == 108 then  -- l
              i = i + 1
              b = line:byte(i)

              if b == 101 then  -- e
                -- module
                start = i - 5
                goto kw_start
              end
            end
          end
        end
      end
    elseif b == 114 then  -- r
      i = i + 1
      b = line:byte(i)

      if b == 101 then  -- e
        i = i + 1
        b = line:byte(i)

        if b == 115 then  -- s
          i = i + 1
          b = line:byte(i)

          if b == 99 then  -- c
            i = i + 1
            b = line:byte(i)

            if b == 117 then  -- u
              i = i + 1
              b = line:byte(i)

              if b == 101 then  -- e
                -- rescue
                start = i - 5
                goto kw_middle
              end
            end
          end
        end
      end
    elseif b == 115 then  -- s
      i = i + 1
      b = line:byte(i)

      if b == 116 then  -- t
        i = i + 1
        b = line:byte(i)

        if b == 114 then  -- r
          i = i + 1
          b = line:byte(i)

          if b == 117 then  -- u
            i = i + 1
            b = line:byte(i)

            if b == 99 then  -- c
              i = i + 1
              b = line:byte(i)

              if b == 116 then  -- t
                -- struct
                start = i - 5
                goto kw_start
              end
            end
          end
        end
      end
    elseif b == 117 then  -- u
      i = i + 1
      b = line:byte(i)

      if b == 110 then  -- n
        i = i + 1
        b = line:byte(i)

        if b == 105 then  -- i
          i = i + 1
          b = line:byte(i)

          if b == 111 then  -- o
            i = i + 1
            b = line:byte(i)

            if b == 110 then  -- n
              -- union
              start = i - 4
              goto kw_start
            end
          end
        elseif b == 108 then  -- l
          i = i + 1
          b = line:byte(i)

          if b == 101 then  -- e
            i = i + 1
            b = line:byte(i)

            if b == 115 then  -- s
              i = i + 1
              b = line:byte(i)

              if b == 115 then  -- s
                -- unless
                start = i - 5
                goto kw_start
              end
            end
          end
        elseif b == 116 then  -- t
          i = i + 1
          b = line:byte(i)

          if b == 105 then  -- i
            i = i + 1
            b = line:byte(i)

            if b == 108 then  -- l
              -- until
              start = i - 4
              goto kw_start
            end
          end
        end
      end
    elseif b == 119 then  -- w
      i = i + 1
      b = line:byte(i)

      if b == 104 then  -- h
        i = i + 1
        b = line:byte(i)

        if b == 101 then  -- e
          i = i + 1
          b = line:byte(i)

          if b == 110 then  -- n
            -- when
            start = i - 3
            goto kw_middle
          end
        elseif b == 105 then  -- i
          i = i + 1
          b = line:byte(i)

          if b == 108 then  -- l
            i = i + 1
            b = line:byte(i)

            if b == 101 then  -- e
              -- while
              start = i - 4
              goto kw_start
            end
          end
        end
      end
    end

    goto next

    ::kw_start::

    if (start == 1 or is_boundary(line:byte(start - 1))) and
      (i == j or is_boundary(line:byte(i + 1))) and
      syngroup_at(lnum, start) == "crystalKeyword" then
      pairs = pairs + 1
    end

    goto next

    ::kw_middle::

    if pairs == 0 then
      goto kw_start
    end

    goto next

    ::kw_end::

    if (start == 1 or is_boundary(line:byte(start - 1))) and
      (i == j or is_boundary(line:byte(i + 1))) and
      syngroup_at(lnum, start) == "crystalKeyword" then
      pairs = pairs - 1
    end

    ::next::

    i = i + 1
  end

  return pairs
end
-- }}}

-- get_crystal_indent {{{
if vim.g.crystal_simple_indent == 1 then
  -- Simple {{{
  return function()
    local lnum = v.lnum

    -- If the current line is inside of a multiline region, do nothing.
    if MULTILINE_REGIONS[syngroup_at(lnum, 1)] then
      return -1
    end

    local prev_lnum = prevnonblank(lnum - 1)

    if prev_lnum == 0 then
      return 0
    end

    -- Retrieve indentation info for the previous line.
    local last_byte, last_col, prev_line = get_last_byte(prev_lnum)

    local first_col, start_lnum, start_line

    -- This variables tells whether or not the previous line is
    -- a continuation of another line.
    -- 0 -> no continuation
    -- 1 -> continuation caused by a backslash or hanging operator
    -- 2 -> continuation caused by a comma (list continuation)
    -- 3 -> continuation caused by an opening bracket
    local continuation = 0

    if last_byte then
      -- If the previous line begins in a multiline region, find the line
      -- that began that region.

      if MULTILINE_REGIONS[syngroup_at(prev_lnum, 1)] then
        start_lnum = prev_non_multiline(prevnonblank(prev_lnum - 1))
        start_line = get_line(prev_lnum)
      else
        start_lnum = prev_lnum
        start_line = prev_line
      end

      -- Find the first column and first byte of the line.
      local first_byte

      for i = 1, #start_line do
        first_byte = start_line:byte(i)

        if first_byte > 32 then  -- %S
          first_col = i
          break
        end
      end

      -- Determine whether or not the line is a continuation.
      if first_byte == 46 then  -- .
        if start_line:byte(first_col + 1) ~= 46 then
          continuation = 1
        end
      else
        local lnum = prevnonblank(start_lnum - 1)

        if lnum ~= 0 then
          local b, col, line = get_last_byte(lnum)

          if b then
            if b == 92 then  -- \
              continuation = 1
            elseif b == 44 then  -- ,
              continuation = 2
            elseif b == 40 or b == 91 or b == 123 then  -- ( [ {
              continuation = 3
            elseif is_operator(b, lnum, col, line) then
              continuation = 1
            end
          end
        end
      end
    else
      -- The previous line is a comment line.
      first_col = last_col
      start_lnum = prev_lnum
      start_line = prev_line
    end

    -- Find the first character in the current line.
    local line = nvim_get_current_line()
    local i, b

    for j = 1, #line do
      b = line:byte(j)

      if b > 32 then  -- %S
        i = j
        break
      end
    end

    local keyword_dedent = false

    if b == 46 then  -- .
      -- If the current line begins with a leading dot, add a shift
      -- unless the previous line was a line continuation.

      if line:byte(i + 1) ~= 46 then  -- .
        if continuation == 1 then
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

      if continuation == 1 then
        shift = shift + 1
      end

      return first_col - 1 - shift * shiftwidth()
    elseif b == 93 then  -- ]
      local shift = 1

      if last_byte == 91 then  -- [
        shift = 0
      end

      if continuation == 1 then
        shift = shift + 1
      end

      return first_col - 1 - shift * shiftwidth()
    elseif b == 125 then  -- }
      local shift = 1

      if last_byte == 123 or last_byte == 124 and  -- { |
        syngroup_at(prev_lnum, last_col) == "crystalDelimiter" then
        shift = 0
      end

      if continuation == 1 then
        shift = shift + 1
      end

      return first_col - 1 - shift * shiftwidth()
    elseif b == 92 then  -- \
      i = i + 1
      b = line:byte(i)

      if b == 123 then  -- {
        i = i + 1
        b = line:byte(i)

        if b == 37 then  -- %
          i = i + 1
          b = line:byte(i)

          for j = i, #line do
            b = line:byte(j)

            if b > 32 then
              i = j
              break
            end
          end

          if b == 101 then  -- e
            i = i + 1
            b = line:byte(i)

            if b == 108 then  -- l
              i = i + 1
              b = line:byte(i)

              if b == 115 then  -- s
                i = i + 1
                b = line:byte(i)

                if b == 101 then  -- e
                  -- else
                  keyword_dedent = true
                elseif b == 105 then  -- i
                  i = i + 1
                  b = line:byte(i)

                  if b == 102 then  -- f
                    -- elsif
                    keyword_dedent = true
                  end
                end
              end
            elseif b == 110 then  -- n
              i = i + 1
              b = line:byte(i)

              if b == 100 then -- d
                -- end
                keyword_dedent = true
              end
            end
          end
        end
      end
    elseif b == 123 then  -- {
      i = i + 1
      b = line:byte(i)

      if b == 37 then  -- %
        i = i + 1
        b = line:byte(i)

        for j = i, #line do
          b = line:byte(j)

          if b > 32 then
            i = j
            break
          end
        end

        if b == 101 then  -- e
          i = i + 1
          b = line:byte(i)

          if b == 108 then  -- l
            i = i + 1
            b = line:byte(i)

            if b == 115 then  -- s
              i = i + 1
              b = line:byte(i)

              if b == 101 then  -- e
                -- else
                keyword_dedent = true
              elseif b == 105 then  -- i
                i = i + 1
                b = line:byte(i)

                if b == 102 then  -- f
                  -- elsif
                  keyword_dedent = true
                end
              end
            end
          elseif b == 110 then  -- n
            i = i + 1
            b = line:byte(i)

            if b == 100 then -- d
              -- end
              keyword_dedent = true
            end
          end
        end
      end
    elseif b == 101 then  -- e
      i = i + 1
      b = line:byte(i)

      if b == 108 then  -- l
        i = i + 1
        b = line:byte(i)

        if b == 115 then  -- s
          i = i + 1
          b = line:byte(i)

          if b == 101 then  -- e
            -- else
            keyword_dedent = true
          elseif b == 105 then  -- i
            i = i + 1
            b = line:byte(i)

            if b == 102 then  -- f
              -- elsif
              keyword_dedent = true
            end
          end
        end
      elseif b == 110 then  -- n
        i = i + 1
        b = line:byte(i)

        if b == 100 then -- d
          -- end
          keyword_dedent = true
        elseif b == 115 then  -- s
          i = i + 1
          b = line:byte(i)

          if b == 117 then  -- u
            i = i + 1
            b = line:byte(i)

            if b == 114 then  -- r
              i = i + 1
              b = line:byte(i)

              if b == 101 then  -- e
                -- ensure
                keyword_dedent = true
              end
            end
          end
        end
      end
    elseif b == 105 then  -- i
      i = i + 1
      b = line:byte(i)

      if b == 110 then  -- n
        -- in
        keyword_dedent = true
      end
    elseif b == 114 then  -- r
      i = i + 1
      b = line:byte(i)

      if b == 101 then  -- e
        i = i + 1
        b = line:byte(i)

        if b == 115 then  -- s
          i = i + 1
          b = line:byte(i)

          if b == 99 then  -- c
            i = i + 1
            b = line:byte(i)

            if b == 117 then  -- u
              i = i + 1
              b = line:byte(i)

              if b == 101 then  -- e
                -- rescue
                keyword_dedent = true
              end
            end
          end
        end
      end
    elseif b == 119 then  -- w
      i = i + 1
      b = line:byte(i)

      if b == 104 then  -- h
        i = i + 1
        b = line:byte(i)

        if b == 101 then  -- e
          i = i + 1
          b = line:byte(i)

          if b == 110 then  -- n
            -- when
            keyword_dedent = true
          end
        end
      end
    end

    if keyword_dedent then
      b = line:byte(i + 1)

      if (i == #line or b ~= 58 and is_boundary(b)) then  -- :
        local pairs

        if start_lnum == prev_lnum then
          pairs = get_keyword_pairs(start_line, start_lnum, first_col, last_col)
        else
          pairs = get_keyword_pairs(start_line, start_lnum, first_col) +
            get_keyword_pairs(prev_line, prev_lnum, 1, last_col)
        end

        if pairs > 0 then
          return first_col - 1
        else
          return first_col - 1 - shiftwidth()
        end
      end
    end

    -- If we can't determine the indent from the current line, examine the
    -- previous line.

    if not last_byte then
      return first_col - 1
    end

    if last_byte == 92 or last_byte == 40 or last_byte == 91 or last_byte == 123 or  -- \ ( [ {
      last_byte == 124 and syngroup_at(prev_lnum, last_col) == "crystalDelimiter" or  -- |
      is_operator(last_byte, prev_lnum, last_col, prev_line) then
      if continuation == 1 then
        return first_col - 1
      else
        return first_col - 1 + shiftwidth()
      end
    elseif last_byte == 44 then  -- ,
      -- If the last character was a comma:
      -- If the previous line was not a continuation, add a shift unless
      -- it has unpaired `end`s.
      -- If the previous line was an operator continuation, subtract
      -- a shift.

      local shift = 0

      if continuation == 0 then
        if get_keyword_pairs(prev_line, prev_lnum, 1, last_col - 1) >= 0 then
          shift = shift + 1
        end
      elseif continuation == 1 then
        shift = shift - 1
      end

      return first_col - 1 + shift * shiftwidth()
    end

    local pairs

    if start_lnum == prev_lnum then
      pairs = get_keyword_pairs(start_line, start_lnum, first_col, last_col)
    else
      pairs = get_keyword_pairs(start_line, start_lnum, first_col) +
        get_keyword_pairs(prev_line, prev_lnum, 1, last_col)
    end

    local shift

    if pairs > 0 then
      shift = 1
    elseif continuation == 1 or continuation == 2 then
      shift = -1
    else
      shift = 0
    end

    return first_col - 1 + shift * shiftwidth()
  end
  -- }}}
else
  -- Default {{{
  return function()
    local lnum = v.lnum

    -- If the current line is inside of a multiline region, do nothing.
    if MULTILINE_REGIONS[syngroup_at(lnum, 1)] then
      return -1
    end

    local prev_lnum = prevnonblank(lnum - 1)

    if prev_lnum == 0 then
      return 0
    end

    -- Retrieve indentation info for the previous line.
    local last_byte, last_col, prev_line = get_last_byte(prev_lnum)

    local first_col, start_lnum, start_line

    -- This variables tells whether or not the previous line is
    -- a continuation of another line.
    -- 0 -> no continuation
    -- 1 -> continuation caused by a backslash or hanging operator
    -- 2 -> continuation caused by a comma (list continuation)
    -- 3 -> continuation caused by an opening bracket
    local continuation = 0

    if last_byte then
      -- If the previous line begins in a multiline region, find the line
      -- that began that region.

      if MULTILINE_REGIONS[syngroup_at(prev_lnum, 1)] then
        start_lnum = prev_non_multiline(prevnonblank(prev_lnum - 1))
        start_line = get_line(prev_lnum)
      else
        start_lnum = prev_lnum
        start_line = prev_line
      end

      -- Find the first column and first byte of the line.
      local first_byte

      for i = 1, #start_line do
        first_byte = start_line:byte(i)

        if first_byte > 32 then  -- %S
          first_col = i
          break
        end
      end

      -- Determine whether or not the line is a continuation.
      if first_byte == 46 then  -- .
        if start_line:byte(first_col + 1) ~= 46 then
          continuation = 1
        end
      else
        local lnum = prevnonblank(start_lnum - 1)

        if lnum ~= 0 then
          local b, col, line = get_last_byte(lnum)

          if b then
            if b == 92 then  -- \
              continuation = 1
            elseif b == 44 then  -- ,
              continuation = 2
            elseif b == 40 or b == 91 or b == 123 then  -- ( [ {
              continuation = 3
            elseif is_operator(b, lnum, col, line) then
              continuation = 1
            end
          end
        end
      end
    else
      -- The previous line is a comment line.
      first_col = last_col
      start_lnum = prev_lnum
      start_line = prev_line
    end

    -- Find the first character in the current line.
    local line = nvim_get_current_line()
    local i, b

    for j = 1, #line do
      b = line:byte(j)

      if b > 32 then  -- %S
        i = j
        break
      end
    end

    local keyword_dedent = false

    if b == 46 then  -- .
      -- If the current line begins with a leading dot, add a shift
      -- unless the previous line was a line continuation.

      if line:byte(i + 1) ~= 46 then  -- .
        if continuation == 1 then
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

      if continuation == 1 then
        shift = shift + 1
      end

      return first_col - 1 - shift * shiftwidth()
    elseif b == 93 then  -- ]
      local shift = 1

      if last_byte == 91 then  -- [
        shift = 0
      end

      if continuation == 1 then
        shift = shift + 1
      end

      return first_col - 1 - shift * shiftwidth()
    elseif b == 125 then  -- }
      local shift = 1

      if last_byte == 123 or last_byte == 124 and  -- { |
        syngroup_at(prev_lnum, last_col) == "crystalDelimiter" then
        shift = 0
      end

      if continuation == 1 then
        shift = shift + 1
      end

      return first_col - 1 - shift * shiftwidth()
    elseif b == 92 then  -- \
      i = i + 1
      b = line:byte(i)

      if b == 123 then  -- {
        i = i + 1
        b = line:byte(i)

        if b == 37 then  -- %
          i = i + 1
          b = line:byte(i)

          for j = i, #line do
            b = line:byte(j)

            if b > 32 then
              i = j
              break
            end
          end

          if b == 101 then  -- e
            i = i + 1
            b = line:byte(i)

            if b == 108 then  -- l
              i = i + 1
              b = line:byte(i)

              if b == 115 then  -- s
                i = i + 1
                b = line:byte(i)

                if b == 101 then  -- e
                  -- else
                  keyword_dedent = true
                elseif b == 105 then  -- i
                  i = i + 1
                  b = line:byte(i)

                  if b == 102 then  -- f
                    -- elsif
                    keyword_dedent = true
                  end
                end
              end
            elseif b == 110 then  -- n
              i = i + 1
              b = line:byte(i)

              if b == 100 then -- d
                -- end
                keyword_dedent = true
              end
            end
          end
        end
      end
    elseif b == 123 then  -- {
      i = i + 1
      b = line:byte(i)

      if b == 37 then  -- %
        i = i + 1
        b = line:byte(i)

        for j = i, #line do
          b = line:byte(j)

          if b > 32 then
            i = j
            break
          end
        end

        if b == 101 then  -- e
          i = i + 1
          b = line:byte(i)

          if b == 108 then  -- l
            i = i + 1
            b = line:byte(i)

            if b == 115 then  -- s
              i = i + 1
              b = line:byte(i)

              if b == 101 then  -- e
                -- else
                keyword_dedent = true
              elseif b == 105 then  -- i
                i = i + 1
                b = line:byte(i)

                if b == 102 then  -- f
                  -- elsif
                  keyword_dedent = true
                end
              end
            end
          elseif b == 110 then  -- n
            i = i + 1
            b = line:byte(i)

            if b == 100 then -- d
              -- end
              keyword_dedent = true
            end
          end
        end
      end
    elseif b == 101 then  -- e
      i = i + 1
      b = line:byte(i)

      if b == 108 then  -- l
        i = i + 1
        b = line:byte(i)

        if b == 115 then  -- s
          i = i + 1
          b = line:byte(i)

          if b == 101 then  -- e
            -- else
            keyword_dedent = true
          elseif b == 105 then  -- i
            i = i + 1
            b = line:byte(i)

            if b == 102 then  -- f
              -- elsif
              keyword_dedent = true
            end
          end
        end
      elseif b == 110 then  -- n
        i = i + 1
        b = line:byte(i)

        if b == 100 then -- d
          -- end
          keyword_dedent = true
        elseif b == 115 then  -- s
          i = i + 1
          b = line:byte(i)

          if b == 117 then  -- u
            i = i + 1
            b = line:byte(i)

            if b == 114 then  -- r
              i = i + 1
              b = line:byte(i)

              if b == 101 then  -- e
                -- ensure
                keyword_dedent = true
              end
            end
          end
        end
      end
    elseif b == 105 then  -- i
      i = i + 1
      b = line:byte(i)

      if b == 110 then  -- n
        -- in
        keyword_dedent = true
      end
    elseif b == 114 then  -- r
      i = i + 1
      b = line:byte(i)

      if b == 101 then  -- e
        i = i + 1
        b = line:byte(i)

        if b == 115 then  -- s
          i = i + 1
          b = line:byte(i)

          if b == 99 then  -- c
            i = i + 1
            b = line:byte(i)

            if b == 117 then  -- u
              i = i + 1
              b = line:byte(i)

              if b == 101 then  -- e
                -- rescue
                keyword_dedent = true
              end
            end
          end
        end
      end
    elseif b == 119 then  -- w
      i = i + 1
      b = line:byte(i)

      if b == 104 then  -- h
        i = i + 1
        b = line:byte(i)

        if b == 101 then  -- e
          i = i + 1
          b = line:byte(i)

          if b == 110 then  -- n
            -- when
            keyword_dedent = true
          end
        end
      end
    end

    if keyword_dedent then
      b = line:byte(i + 1)

      if (i == #line or b ~= 58 and is_boundary(b)) then  -- :
        local pairs

        if start_lnum == prev_lnum then
          pairs = get_keyword_pairs(start_line, start_lnum, first_col, last_col)
        else
          pairs = get_keyword_pairs(start_line, start_lnum, first_col) +
            get_keyword_pairs(prev_line, prev_lnum, 1, last_col)
        end

        if pairs > 0 then
          return first_col - 1
        else
          return first_col - 1 - shiftwidth()
        end
      end
    end

    -- If we can't determine the indent from the current line, examine the
    -- previous line.

    if not last_byte then
      return first_col - 1
    end

    if last_byte == 92 or last_byte == 40 or last_byte == 91 or last_byte == 123 or  -- \ ( [ {
      last_byte == 124 and syngroup_at(prev_lnum, last_col) == "crystalDelimiter" or  -- |
      is_operator(last_byte, prev_lnum, last_col, prev_line) then
      if continuation == 1 then
        return first_col - 1
      else
        return first_col - 1 + shiftwidth()
      end
    elseif last_byte == 44 then  -- ,
      -- If the last character was a comma:
      -- If the previous line was not a continuation, add a shift unless
      -- it has unpaired `end`s.
      -- If the previous line was an operator continuation, subtract
      -- a shift.

      local shift = 0

      if continuation == 0 then
        if get_keyword_pairs(prev_line, prev_lnum, 1, last_col - 1) >= 0 then
          shift = shift + 1
        end
      elseif continuation == 1 then
        shift = shift - 1
      end

      return first_col - 1 + shift * shiftwidth()
    end

    local pairs

    if start_lnum == prev_lnum then
      pairs = get_keyword_pairs(start_line, start_lnum, first_col, last_col)
    else
      pairs = get_keyword_pairs(start_line, start_lnum, first_col) +
        get_keyword_pairs(prev_line, prev_lnum, 1, last_col)
    end

    local shift

    if pairs > 0 then
      shift = 1
    elseif continuation == 1 or continuation == 2 then
      shift = -1
    else
      shift = 0
    end

    return first_col - 1 + shift * shiftwidth()
  end
  -- }}}
end
-- }}}

-- vim:fdm=marker
