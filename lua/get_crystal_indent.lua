local v = vim.v

local fn = vim.fn
local prevnonblank = fn.prevnonblank
local shiftwidth = fn.shiftwidth
local synID = fn.synID
local synIDattr = fn.synIDattr
local getline = fn.getline

local api = vim.api
local nvim_get_current_line = api.nvim_get_current_line

-- Helpers {{{
local MULTILINE_REGIONS = {
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

local function is_boundary(b)
  -- [^_:%w]
  return
    b < 48 or
    b > 57 and b < 65 and b ~= 58 or
    b > 90 and b < 97 and b ~= 95 or
    b > 122
end

local function prev_non_multiline(lnum)
  while MULTILINE_REGIONS[syngroup_at(lnum, 1)] do
    lnum = prevnonblank(lnum - 1)
  end

  return lnum
end

local function is_operator(byte, col, line, lnum)
  if byte == 37 or  -- %
    byte == 38 or  -- &
    byte == 42 or  -- *
    byte == 43 or  -- +
    byte == 45 or  -- -
    byte == 47 or  -- /
    byte == 60 or  -- <
    byte == 62 or  -- >
    byte == 63 or  -- ?
    byte == 94 or  -- ^
    byte == 126 then  -- ~
    return syngroup_at(lnum, col) == "crystalOperator"
  elseif byte == 58 then  -- :
    local syngroup = syngroup_at(lnum, col)
    return syngroup == "crystalOperator" or syngroup == "crystalTypeRestrictionOperator"
  elseif byte == 61 then  -- =
    local syngroup = syngroup_at(lnum, col)
    return syngroup == "crystalOperator" or syngroup == "crystalAssignmentOperator" or syngroup == "crystalMethodAssignmentOperator" or syngroup == "crystalTypeAliasOperator"
  elseif byte == 124 then  -- |
    local syngroup = syngroup_at(lnum, col)
    return syngroup == "crystalOperator" or syngroup == "crystalTypeUnionOperator"
  end

  return false
end

local function is_assignment_operator(byte, col, line, lnum)
  if byte == 61 then  -- =
    local x = line:byte(col + 1)
    local y = line:byte(col - 1)

    if x ~= 61 and x ~= 62 and x ~= 126 and y ~= 61 and y ~= 33 then  -- = > ~ = !
      local syngroup = syngroup_at(lnum, col)
      return syngroup == "crystalOperator" or syngroup == "crystalAssignmentOperator" or syngroup == "crystalMethodAssignmentOperator" or syngroup == "crystalTypeAliasOperator"
    end
  end

  return false
end

-- First, try to find a comment delimiter: if one is found, the
-- non-whitespace byte immediately before it is the last byte; else,
-- simply find the last non-whitespace byte in the line.
local function get_last_byte(lnum, line)
  local found = 0

  repeat
    found = line:find("#", found + 1)

    if not found then
      for i = #line, 1, -1 do
        local b = line:byte(i)

        if b > 32 then
          return b, i
        end
      end
    elseif found == 1 then
      return nil, 1
    end
  until syngroup_at(lnum, found) == "crystalCommentStart"

  for i = found - 1, 1, -1 do
    local b = line:byte(i)

    if b > 32 then
      return b, i
    end
  end

  return nil, found
end

local function get_pairs(lnum, line, i, j, pairs)
  pairs = pairs or 0

  local start_found = false

  while i <= j do
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

    goto default

    ::kw_start::

    if (start == 1 or is_boundary(line:byte(start - 1))) and (i == j or is_boundary(line:byte(i + 1))) then
      local syngroup = syngroup_at(lnum, start)

      if syngroup == "crystalKeyword" or syngroup == "crystalDefine" then
        pairs = pairs + 1
        start_found = true
      end
    end

    goto next

    ::kw_middle::

    if not start_found and pairs == 0 then
      if (start == 1 or is_boundary(line:byte(start - 1))) and (i == j or is_boundary(line:byte(i + 1))) then
        local syngroup = syngroup_at(lnum, start)

        if syngroup == "crystalKeyword" or syngroup == "crystalBlockControl" or syngroup == "crystalDefineBlockControl" then
          pairs = pairs + 1
          start_found = true
        end
      end
    end

    goto next

    ::kw_end::

    if (start == 1 or is_boundary(line:byte(start - 1))) and (i == j or is_boundary(line:byte(i + 1))) then
      local syngroup = syngroup_at(lnum, start)

      if syngroup == "crystalKeyword" or syngroup == "crystalDefine" then
        pairs = pairs - 1
      end
    end

    goto next

    ::default::

    if b == 40 or b == 91 or b == 123 then  -- ( [ {
      if syngroup_at(lnum, i) == "crystalDelimiter" then
        pairs = pairs + 1
      end
    elseif b == 41 or b == 93 or b == 125 then  -- ) ] }
      if syngroup_at(lnum, i) == "crystalDelimiter" then
        pairs = pairs - 1
      end
    end

    ::next::

    i = i + 1
  end

  return pairs
end

local function find_floating_column(lnum, line, i, j)
  local pairs = 0

  local k = j

  while k >= i do
    local offset
    local b = line:byte(k)

    if b == 98 then  -- b
      k = k - 1
      b = line:byte(k)

      if b == 105 then  -- i
        k = k - 1
        b = line:byte(k)

        if b == 108 then  -- l
          -- lib
          offset = k + 2
          goto kw_define
        end
      end
    elseif b == 100 then  -- d
      k = k - 1
      b = line:byte(k)

      if b == 110 then  -- n
        k = k - 1
        b = line:byte(k)

        if b == 101 then  -- d
          -- end
          goto kw_end
        end
      end
    elseif b == 101 then  -- e
      k = k - 1
      b = line:byte(k)

      if b == 108 then  -- l
        k = k - 1
        b = line:byte(k)

        if b == 105 then  -- i
          k = k - 1
          b = line:byte(k)

          if b == 104 then  -- h
            k = k - 1
            b = line:byte(k)

            if b == 119 then  -- w
              -- while
              offset = k + 4
              goto kw_start
            end
          end
        elseif b == 117 then  -- u
          k = k - 1
          b = line:byte(k)

          if b == 100 then  -- d
            k = k - 1
            b = line:byte(k)

            if b == 111 then  -- o
              k = k - 1
              b = line:byte(k)

              if b == 109 then  -- m
                -- module
                offset = k + 5
                goto kw_define
              end
            end
          end
        end
      elseif b == 114 then  -- r
        k = k - 1
        b = line:byte(k)

        if b == 117 then  -- u
          k = k - 1
          b = line:byte(k)

          if b == 115 then  -- s
            k = k - 1
            b = line:byte(k)

            if b == 110 then  -- n
              k = k - 1
              b = line:byte(k)

              if b == 101 then  -- e
                -- ensure
                offset = k + 5
                goto kw_middle
              end
            end
          end
        end
      elseif b == 115 then  -- s
        k = k - 1
        b = line:byte(k)

        if b == 97 then  -- a
          k = k - 1
          b = line:byte(k)

          if b == 99 then  -- c
            -- case
            offset = k + 3
            goto kw_start
          end
        elseif b == 108 then  -- l
          k = k - 1
          b = line:byte(k)

          if b == 101 then  -- e
            -- else
            offset = k + 3
            goto kw_middle
          end
        end
      elseif b == 117 then  -- u
        k = k - 1
        b = line:byte(k)

        if b == 99 then  -- c
          k = k - 1
          b = line:byte(k)

          if b == 115 then  -- s
            k = k - 1
            b = line:byte(k)

            if b == 101 then  -- e
              k = k - 1
              b = line:byte(k)

              if b == 114 then  -- r
                -- rescue
                offset = k + 5
                goto kw_middle
              end
            end
          end
        end
      end
    elseif b == 102 then  -- f
      k = k - 1
      b = line:byte(k)

      if b == 101 then  -- e
        k = k - 1
        b = line:byte(k)

        if b == 100 then  -- d
          -- def
          offset = k + 2
          goto kw_define
        end
      elseif b == 105 then  -- i
        if k == i or is_boundary(line:byte(k - 1)) then
          -- if
          offset = k + 1
          goto kw_start
        else
          k = k - 1
          b = line:byte(k)

          if b == 115 then  -- s
            k = k - 1
            b = line:byte(k)

            if b == 108 then  -- l
              k = k - 1
              b = line:byte(k)

              if b == 101 then  -- e
                -- elsif
                offset = k + 4
                goto kw_middle
              end
            end
          end
        end
      end
    elseif b == 108 then  -- l
      k = k - 1
      b = line:byte(k)

      if b == 105 then  -- i
        k = k - 1
        b = line:byte(k)

        if b == 116 then  -- t
          k = k - 1
          b = line:byte(k)

          if b == 110 then  -- n
            k = k - 1
            b = line:byte(k)

            if b == 117 then  -- u
              -- until
              offset = k + 4
              goto kw_start
            end
          end
        end
      end
    elseif b == 109 then  -- m
      k = k - 1
      b = line:byte(k)

      if b == 117 then  -- u
        k = k - 1
        b = line:byte(k)

        if b == 110 then  -- n
          k = k - 1
          b = line:byte(k)

          if b == 101 then  -- e
            -- enum
            offset = k + 3
            goto kw_define
          end
        end
      end
    elseif b == 110 then  -- n
      k = k - 1
      b = line:byte(k)

      if b == 101 then  -- e
        k = k - 1
        b = line:byte(k)

        if b == 104 then  -- h
          k = k - 1
          b = line:byte(k)

          if b == 119 then  -- w
            -- when
            offset = k + 3
            goto kw_middle
          end
        end
      elseif b == 105 then  -- i
        if k == i or is_boundary(line:byte(k - 1)) then
          -- in
          offset = k + 1
          goto kw_middle
        else
          k = k - 1
          b = line:byte(k)

          if b == 103 then  -- g
            k = k - 1
            b = line:byte(k)

            if b == 101 then  -- e
              k = k - 1
              b = line:byte(k)

              if b == 98 then  -- b
                -- begin
                offset = k + 4
                goto kw_start
              end
            end
          end
        end
      elseif b == 111 then  -- o
        k = k - 1
        b = line:byte(k)

        if b == 105 then  -- i
          k = k - 1
          b = line:byte(k)

          if b == 110 then  -- n
            k = k - 1
            b = line:byte(k)

            if b == 117 then  -- u
              -- union
              offset = k + 4
              goto kw_define
            end
          elseif b == 116 then  -- t
            k = k - 1
            b = line:byte(k)

            if b == 97 then  -- a
              k = k - 1
              b = line:byte(k)

              if b == 116 then  -- t
                k = k - 1
                b = line:byte(k)

                if b == 111 then  -- o
                  k = k - 1
                  b = line:byte(k)

                  if b == 110 then  -- n
                    k = k - 1
                    b = line:byte(k)

                    if b == 110 then  -- n
                      k = k - 1
                      b = line:byte(k)

                      if b == 97 then  -- a
                        -- annotation
                        offset = k + 9
                        goto kw_define
                      end
                    end
                  end
                end
              end
            end
          end
        end
      end
    elseif b == 111 then  -- o
      k = k - 1
      b = line:byte(k)

      if b == 100 then  -- d
        -- do
        goto kw_do
      elseif b == 114 then  -- r
        k = k - 1
        b = line:byte(k)

        if b == 99 then  -- c
          k = k - 1
          b = line:byte(k)

          if b == 97 then  -- a
            k = k - 1
            b = line:byte(k)

            if b == 109 then  -- m
              -- macro
              offset = k + 4
              goto kw_define
            end
          end
        end
      end
    elseif b == 115 then  -- s
      k = k - 1
      b = line:byte(k)

      if b == 115 then  -- s
        k = k - 1
        b = line:byte(k)

        if b == 97 then  -- a
          k = k - 1
          b = line:byte(k)

          if b == 108 then  -- l
            k = k - 1
            b = line:byte(k)

            if b == 99 then  -- c
              -- class
              offset = k + 4
              goto kw_define
            end
          end
        elseif b == 101 then  -- e
          k = k - 1
          b = line:byte(k)

          if b == 108 then  -- l
            k = k - 1
            b = line:byte(k)

            if b == 110 then  -- n
              k = k - 1
              b = line:byte(k)

              if b == 117 then  -- u
                -- unless
                offset = k + 5
                goto kw_start
              end
            end
          end
        end
      end
    elseif b == 116 then  -- t
      k = k - 1
      b = line:byte(k)

      if b == 99 then  -- c
        k = k - 1
        b = line:byte(k)

        if b == 117 then  -- u
          k = k - 1
          b = line:byte(k)

          if b == 114 then  -- r
            k = k - 1
            b = line:byte(k)

            if b == 116 then  -- t
              k = k - 1
              b = line:byte(k)

              if b == 115 then  -- s
                -- struct
                offset = k + 5
                goto kw_define
              end
            end
          end
        end
      end
    end

    goto default

    ::kw_start::

    if (k == 1 or is_boundary(line:byte(k - 1))) and (offset == j or is_boundary(line:byte(offset + 1))) then
      if syngroup_at(lnum, k) == "crystalKeyword" then
        if pairs == 0 then
          -- If this is a macro tag keyword, return the column for the
          -- macro tag.
          for l = k - 1, i, -1 do
            local b = line:byte(l)

            if b > 32 then
              if b == 37 and line:byte(l - 1) == 123 then
                if line:byte(l - 2) == 92 then
                  return l - 2
                else
                  return l - 1
                end
              end

              break
            end
          end

          return k
        else
          pairs = pairs + 1
        end
      end
    end

    goto next

    ::kw_middle::

    if pairs == 0 then
      if (k == 1 or is_boundary(line:byte(k - 1))) and (offset == j or is_boundary(line:byte(offset + 1))) then
        local syngroup = syngroup_at(lnum, k)

        if syngroup == "crystalKeyword" or syngroup == "crystalBlockControl" or syngroup == "crystalDefineBlockControl" then
          return i
        end
      end
    end

    goto next

    ::kw_define::

    if (k == 1 or is_boundary(line:byte(k - 1))) and (offset == j or is_boundary(line:byte(offset + 1))) then
      if syngroup_at(lnum, k) == "crystalDefine" then
        if pairs == 0 then
          return i
        else
          pairs = pairs + 1
        end
      end
    end

    goto next

    ::kw_do::

    if (k == 1 or is_boundary(line:byte(k - 1))) and (k + 1 == j or is_boundary(line:byte(k + 2))) then
      if syngroup_at(lnum, k) == "crystalKeyword" then
        if pairs == 0 then
          return i
        else
          pairs = pairs + 1
        end
      end
    end

    goto next

    ::kw_end::

    if (k == 1 or is_boundary(line:byte(k - 1))) and (k + 2 == j or is_boundary(line:byte(k + 3))) then
      local syngroup = syngroup_at(lnum, k)

      if syngroup == "crystalKeyword" or syngroup == "crystalDefine" then
        pairs = pairs - 1
      end
    end

    goto next

    ::default::

    if b == 40 or b == 91 or b == 123 then  -- ( [ {
      if syngroup_at(lnum, k) == "crystalDelimiter" then
        if pairs == 0 then
          for l = k + 1, j do
            if line:byte(l) > 32 then
              return l
            end
          end

          return i
        else
          pairs = pairs + 1
        end
      end
    elseif b == 41 or b == 93 or b == 125 then  -- ) ] }
      if syngroup_at(lnum, k) == "crystalDelimiter" then
        pairs = pairs - 1
      end
    elseif b == 124 then  -- |
      if syngroup_at(lnum, k) == "crystalDelimiter" then
        if pairs == 0 then
          return i
        end
      end
    end

    goto next

    ::next::

    k = k - 1
  end
end

local function has_starting_keyword(lnum, line, i, j)
  local pairs = 0

  local k = j

  while k >= i do
    local offset
    local b = line:byte(k)

    if b == 98 then  -- b
      k = k - 1
      b = line:byte(k)

      if b == 105 then  -- i
        k = k - 1
        b = line:byte(k)

        if b == 108 then  -- l
          -- lib
          offset = k + 2
          goto kw_start
        end
      end
    elseif b == 100 then  -- d
      k = k - 1
      b = line:byte(k)

      if b == 110 then  -- n
        k = k - 1
        b = line:byte(k)

        if b == 101 then  -- d
          -- end
          goto kw_end
        end
      end
    elseif b == 101 then  -- e
      k = k - 1
      b = line:byte(k)

      if b == 108 then  -- l
        k = k - 1
        b = line:byte(k)

        if b == 105 then  -- i
          k = k - 1
          b = line:byte(k)

          if b == 104 then  -- h
            k = k - 1
            b = line:byte(k)

            if b == 119 then  -- w
              -- while
              offset = k + 4
              goto kw_start
            end
          end
        elseif b == 117 then  -- u
          k = k - 1
          b = line:byte(k)

          if b == 100 then  -- d
            k = k - 1
            b = line:byte(k)

            if b == 111 then  -- o
              k = k - 1
              b = line:byte(k)

              if b == 109 then  -- m
                -- module
                offset = k + 5
                goto kw_start
              end
            end
          end
        end
      elseif b == 114 then  -- r
        k = k - 1
        b = line:byte(k)

        if b == 117 then  -- u
          k = k - 1
          b = line:byte(k)

          if b == 115 then  -- s
            k = k - 1
            b = line:byte(k)

            if b == 110 then  -- n
              k = k - 1
              b = line:byte(k)

              if b == 101 then  -- e
                -- ensure
                offset = k + 5
                goto kw_middle
              end
            end
          end
        end
      elseif b == 115 then  -- s
        k = k - 1
        b = line:byte(k)

        if b == 97 then  -- a
          k = k - 1
          b = line:byte(k)

          if b == 99 then  -- c
            -- case
            offset = k + 3
            goto kw_start
          end
        elseif b == 108 then  -- l
          k = k - 1
          b = line:byte(k)

          if b == 101 then  -- e
            -- else
            offset = k + 3
            goto kw_middle
          end
        end
      elseif b == 117 then  -- u
        k = k - 1
        b = line:byte(k)

        if b == 99 then  -- c
          k = k - 1
          b = line:byte(k)

          if b == 115 then  -- s
            k = k - 1
            b = line:byte(k)

            if b == 101 then  -- e
              k = k - 1
              b = line:byte(k)

              if b == 114 then  -- r
                -- rescue
                offset = k + 5
                goto kw_middle
              end
            end
          end
        end
      end
    elseif b == 102 then  -- f
      k = k - 1
      b = line:byte(k)

      if b == 101 then  -- e
        k = k - 1
        b = line:byte(k)

        if b == 100 then  -- d
          -- def
          offset = k + 2
          goto kw_start
        end
      elseif b == 105 then  -- i
        if k == i or is_boundary(line:byte(k - 1)) then
          -- if
          offset = k + 1
          goto kw_start
        else
          k = k - 1
          b = line:byte(k)

          if b == 115 then  -- s
            k = k - 1
            b = line:byte(k)

            if b == 108 then  -- l
              k = k - 1
              b = line:byte(k)

              if b == 101 then  -- e
                -- elsif
                offset = k + 4
                goto kw_middle
              end
            end
          end
        end
      end
    elseif b == 108 then  -- l
      k = k - 1
      b = line:byte(k)

      if b == 105 then  -- i
        k = k - 1
        b = line:byte(k)

        if b == 116 then  -- t
          k = k - 1
          b = line:byte(k)

          if b == 110 then  -- n
            k = k - 1
            b = line:byte(k)

            if b == 117 then  -- u
              -- until
              offset = k + 4
              goto kw_start
            end
          end
        end
      end
    elseif b == 109 then  -- m
      k = k - 1
      b = line:byte(k)

      if b == 117 then  -- u
        k = k - 1
        b = line:byte(k)

        if b == 110 then  -- n
          k = k - 1
          b = line:byte(k)

          if b == 101 then  -- e
            -- enum
            offset = k + 3
            goto kw_start
          end
        end
      end
    elseif b == 110 then  -- n
      k = k - 1
      b = line:byte(k)

      if b == 101 then  -- e
        k = k - 1
        b = line:byte(k)

        if b == 104 then  -- h
          k = k - 1
          b = line:byte(k)

          if b == 119 then  -- w
            -- when
            offset = k + 3
            goto kw_middle
          end
        end
      elseif b == 105 then  -- i
        if k == i or is_boundary(line:byte(k - 1)) then
          -- in
          offset = k + 1
          goto kw_middle
        else
          k = k - 1
          b = line:byte(k)

          if b == 103 then  -- g
            k = k - 1
            b = line:byte(k)

            if b == 101 then  -- e
              k = k - 1
              b = line:byte(k)

              if b == 98 then  -- b
                -- begin
                offset = k + 4
                goto kw_start
              end
            end
          end
        end
      elseif b == 111 then  -- o
        k = k - 1
        b = line:byte(k)

        if b == 105 then  -- i
          k = k - 1
          b = line:byte(k)

          if b == 110 then  -- n
            k = k - 1
            b = line:byte(k)

            if b == 117 then  -- u
              -- union
              offset = k + 4
              goto kw_start
            end
          elseif b == 116 then  -- t
            k = k - 1
            b = line:byte(k)

            if b == 97 then  -- a
              k = k - 1
              b = line:byte(k)

              if b == 116 then  -- t
                k = k - 1
                b = line:byte(k)

                if b == 111 then  -- o
                  k = k - 1
                  b = line:byte(k)

                  if b == 110 then  -- n
                    k = k - 1
                    b = line:byte(k)

                    if b == 110 then  -- n
                      k = k - 1
                      b = line:byte(k)

                      if b == 97 then  -- a
                        -- annotation
                        offset = k + 9
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
    elseif b == 111 then  -- o
      k = k - 1
      b = line:byte(k)

      if b == 100 then  -- d
        -- do
        offset = k + 1
        goto kw_start
      elseif b == 114 then  -- r
        k = k - 1
        b = line:byte(k)

        if b == 99 then  -- c
          k = k - 1
          b = line:byte(k)

          if b == 97 then  -- a
            k = k - 1
            b = line:byte(k)

            if b == 109 then  -- m
              -- macro
              offset = k + 4
              goto kw_start
            end
          end
        end
      end
    elseif b == 115 then  -- s
      k = k - 1
      b = line:byte(k)

      if b == 115 then  -- s
        k = k - 1
        b = line:byte(k)

        if b == 97 then  -- a
          k = k - 1
          b = line:byte(k)

          if b == 108 then  -- l
            k = k - 1
            b = line:byte(k)

            if b == 99 then  -- c
              -- class
              offset = k + 4
              goto kw_start
            end
          end
        elseif b == 101 then  -- e
          k = k - 1
          b = line:byte(k)

          if b == 108 then  -- l
            k = k - 1
            b = line:byte(k)

            if b == 110 then  -- n
              k = k - 1
              b = line:byte(k)

              if b == 117 then  -- u
                -- unless
                offset = k + 5
                goto kw_start
              end
            end
          end
        end
      end
    elseif b == 116 then  -- t
      k = k - 1
      b = line:byte(k)

      if b == 99 then  -- c
        k = k - 1
        b = line:byte(k)

        if b == 117 then  -- u
          k = k - 1
          b = line:byte(k)

          if b == 114 then  -- r
            k = k - 1
            b = line:byte(k)

            if b == 116 then  -- t
              k = k - 1
              b = line:byte(k)

              if b == 115 then  -- s
                -- struct
                offset = k + 5
                goto kw_start
              end
            end
          end
        end
      end
    end

    goto next

    ::kw_start::

    if (k == 1 or is_boundary(line:byte(k - 1))) and (offset == j or is_boundary(line:byte(offset + 1))) then
      if syngroup_at(lnum, k) == "crystalKeyword" then
        if pairs == 0 then
          return true
        else
          pairs = pairs + 1
        end
      end
    end

    goto next

    ::kw_middle::

    if pairs == 0 then
      if (k == 1 or is_boundary(line:byte(k - 1))) and (offset == j or is_boundary(line:byte(offset + 1))) then
        if syngroup_at(lnum, k) == "crystalKeyword" then
          return true
        end
      end
    end

    goto next

    ::kw_end::

    if (k == 1 or is_boundary(line:byte(k - 1))) and (k + 2 == j or is_boundary(line:byte(k + 3))) then
      if syngroup_at(lnum, k) == "crystalKeyword" then
        pairs = pairs - 1
      end
    end

    goto next

    ::next::

    k = k - 1
  end
end

local function get_msl(lnum, line, start, finish, skip_commas, pairs)
  local prev_lnum = prevnonblank(lnum - 1)

  if prev_lnum == 0 then
    return lnum, start - 1, false
  end

  -- This line is *not* the MSL if:

  -- It is part of a multiline region.
  if MULTILINE_REGIONS[syngroup_at(lnum, 1)] then
    local prev_line = getline(prev_lnum)
    return get_msl(prev_lnum, prev_line, 1, #prev_line, skip_commas)
  end

  -- It starts with a leading dot.
  local first_col

  if start == 1 then
    for i = start, finish do
      if line:byte(i) > 32 then
        first_col = i
        break
      end
    end
  else
    first_col = start
  end

  local first_byte = line:byte(first_col)

  if first_byte == 46 and line:byte(first_col + 1) ~= 46 then  -- .
    local prev_line = getline(prev_lnum)
    return get_msl(prev_lnum, prev_line, 1, #prev_line, skip_commas)
  end

  -- It contains a positive number of unpaired closing brackets or
  -- keywords; find the corresponding starting line...
  --
  -- *unless* the line starts with an `end` that is part of
  -- a definition.
  if pairs then
    goto pairs_skipped
  end

  pairs = 0

  if first_byte == 101 and line:byte(first_col + 1) == 110 and line:byte(first_col + 2) == 100 and  -- e n d
    (first_col + 2 == finish or is_boundary(line:byte(first_col + 3))) then
    if first_col == 1 then
      return lnum, first_col - 1, false
    end

    if syngroup_at(lnum, first_col) == "crystalDefine" then
      return lnum, first_col - 1, false
    end

    pairs = get_pairs(lnum, line, first_col + 4, #line, -1)
  else
    pairs = get_pairs(lnum, line, first_col, #line)
  end

  if pairs < 0 then
    for i = prev_lnum, 1, -1 do
      local line = getline(i)

      pairs = get_pairs(i, line, 1, #line, pairs)

      if pairs >= 0 then
        return get_msl(i, line, 1, #line, skip_commas, pairs)
      end
    end
  end

  ::pairs_skipped::

  -- The previous line ends with a comma, backslash, or hanging
  -- operator.
  local prev_line = getline(prev_lnum)
  local last_byte, last_col = get_last_byte(prev_lnum, prev_line)

  if last_byte == 44 then  -- ,
    if not skip_commas then
      return get_msl(prev_lnum, prev_line, 1, last_col - 1, false)
    end
  elseif last_byte == 92 or is_operator(last_byte, last_col, prev_line, prev_lnum) then  -- \
    return get_msl(prev_lnum, prev_line, 1, last_col - 1, skip_commas)
  end

  -- Else, this line is the MSL.
  return lnum, first_col - 1, pairs > 0
end
-- }}}

if vim.g.crystal_simple_indent == 1 then
  -- Simple {{{
  function get_crystal_indent()
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
    local prev_line = getline(prev_lnum)
    local last_byte, last_col = get_last_byte(prev_lnum, prev_line)

    local first_col, first_byte, start_lnum, start_line

    -- This variable tells whether or not the previous line is
    -- a continuation of another line.
    -- 0 -> no continuation
    -- 1 -> continuation caused by a backslash or hanging operator
    -- 2 -> continuation caused by a comma (list continuation)
    -- 3 -> continuation caused by an opening bracket
    local continuation = 0

    if last_byte then
      -- If the previous line begins in a multiline region, find the line
      -- that began that region; this line will be referred to as the
      -- "starting line".

      if MULTILINE_REGIONS[syngroup_at(prev_lnum, 1)] then
        start_lnum = prev_non_multiline(prevnonblank(prev_lnum - 1))
        start_line = getline(start_lnum)
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
      if first_byte == 46 then  -- .
        if start_line:byte(first_col + 1) ~= 46 then
          continuation = 1
        end
      elseif first_byte ~= 41 and first_byte ~= 93 and first_byte ~= 125 then  -- ) ] }
        local lnum = prevnonblank(start_lnum - 1)

        if lnum ~= 0 then
          local line = getline(lnum)
          local b, col = get_last_byte(lnum, line)

          if b then
            if b == 44 then  -- ,
              continuation = 2
            elseif b == 40 or b == 91 or b == 123 then  -- ( [ {
              continuation = 3
            elseif b == 92 or is_operator(b, col, line, lnum) then  -- \
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

      if i == #line or is_boundary(b) then
        local shift = 1

        if continuation == 1 then
          shift = shift + 1
        end

        if has_starting_keyword(start_lnum, start_line, first_col, #start_line) then
          shift = shift - 1
        end

        return first_col - 1 - shift * shiftwidth()
      end
    end

    -- If we can't determine the indent from the current line, examine the
    -- previous line.

    if not last_byte then
      -- If the previous line was a comment, do nothing.
      return first_col - 1
    end

    if last_byte == 92 or last_byte == 40 or last_byte == 91 or last_byte == 123 or  -- \ ( [ {
      last_byte == 124 and syngroup_at(prev_lnum, last_col) == "crystalDelimiter" or  -- |
      is_operator(last_byte, last_col, prev_line, prev_lnum) then
      if continuation == 1 then
        return first_col - 1
      else
        return first_col - 1 + shiftwidth()
      end
    elseif last_byte == 44 then  -- ,
      -- If the last character was a comma, add a shift unless:
      --
      -- The previous line begins with a closing bracket or `end`.
      --
      -- The line before the starting line ends with a comma or
      -- a hanging bracket.

      if prev_lnum == start_lnum then
        if first_byte == 41 or first_byte == 93 or first_byte == 125 then  -- ) ] }
          return first_col - 1
        elseif first_byte == 101 and start_line:byte(first_col + 1) == 110 and start_line:byte(first_col + 2) == 100 and (first_col + 2 == #start_line or is_boundary(start_line:byte(first_col + 3))) then
          return first_col - 1
        end
      end

      if continuation == 1 then
        return first_col - 1 - shiftwidth()
      elseif continuation == 2 or continuation == 3 then
        return first_col - 1
      else
        return first_col - 1 + shiftwidth()
      end
    end

    local shift

    if has_starting_keyword(start_lnum, start_line, first_col, #start_line) then
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
  function get_crystal_indent()
    local lnum = v.lnum

    -- If the current line is inside of a multiline region, do nothing.
    if MULTILINE_REGIONS[syngroup_at(lnum, 1)] then
      return -1
    end

    -- If there is no previous line in the file, do nothing.
    local prev_lnum = prevnonblank(lnum - 1)

    if prev_lnum == 0 then
      return 0
    end

    -- Find the last non-comment byte of the previous line.
    local prev_line = getline(prev_lnum)
    local last_byte, last_col = get_last_byte(prev_lnum, prev_line)

    -- Before we proceed, we need to determine which column we will use as
    -- the starting position.
    --
    -- If there is a floating column somewhere in the previous line, that
    -- is the starting column.
    --
    -- Else, the first column of the previous line is the starting
    -- position.
    local start_col, first_col, floating_col

    if not last_byte then
      -- The previous line was a comment line.
      first_col = last_col
      start_col = last_col
    else
      for i = 1, last_col do
        if prev_line:byte(i) > 32 then
          first_col = i
          break
        end
      end

      floating_col = find_floating_column(prev_lnum, prev_line, first_col, last_col)
      start_col = floating_col or first_col

      -- Check the last byte of the previous line.
      if last_byte == 92 or is_operator(last_byte, last_col, prev_line, prev_lnum) then  -- \
        -- If the previous line ends with a hanging operator or backslash...

        do
          -- Find the next previous line.
          local prev_prev_lnum = prevnonblank(prev_lnum - 1)

          local prev_prev_line, prev_last_byte, prev_last_col

          if prev_prev_lnum == 0 then
            goto exit
          end

          prev_prev_line = getline(prev_prev_lnum)
          prev_last_byte, prev_last_col = get_last_byte(prev_prev_lnum, prev_prev_line)

          -- If the next previous line also ends with a hanging operator or
          -- backslash...
          if prev_last_byte == 92 or is_operator(prev_last_byte, prev_last_col, prev_prev_line, prev_prev_lnum) then  -- \
            -- Align with the starting column.
            return first_col - 1
          end

          ::exit::
        end

        do
          local b = prev_line:byte(start_col)
          local offset

          -- If the first character of the previous line is part of
          -- a keyword, align with the first character after that word.
          if b == 99 then  -- c
            if prev_line:byte(start_col + 1) == 97 and prev_line:byte(start_col + 2) == 115 and prev_line:byte(start_col + 3) == 101 then  -- a s e
              offset = 4
              goto found
            end
          elseif b == 101 then  -- e
            if prev_line:byte(start_col + 1) == 108 and prev_line:byte(start_col + 2) == 115 and prev_line:byte(start_col + 3) == 105 and prev_line:byte(start_col + 4) == 102 then  -- l s i f
              offset = 5
              goto found
            end
          elseif b == 105 then  -- i
            b = prev_line:byte(start_col + 1)

            if b == 102 or b == 110 then  -- f n
              offset = 2
              goto found
            end
          elseif b == 117 then  -- u
            if prev_line:byte(start_col + 1) == 110 then  -- n
              b = prev_line:byte(start_col + 2)

              if b == 108 then  -- l
                if prev_line:byte(start_col + 3) == 101 and prev_line:byte(start_col + 4) == 115 and prev_line:byte(start_col + 5) == 115 then  -- e s s
                  offset = 6
                  goto found
                end
              elseif b == 116 then  -- t
                if prev_line:byte(start_col + 3) == 105 and prev_line:byte(start_col + 4) == 108 then  -- i l
                  offset = 5
                  goto found
                end
              end
            end
          elseif b == 119 then  -- w
            if prev_line:byte(start_col + 1) == 104 then  -- h
              b = prev_line:byte(start_col + 2)

              if b == 101 then  -- e
                if prev_line:byte(start_col + 3) == 110 then  -- n
                  offset = 4
                  goto found
                end
              elseif b == 105 then  -- i
                if prev_line:byte(start_col + 3) == 108 and prev_line:byte(start_col + 4) == 101 then  -- l e
                  offset = 5
                  goto found
                end
              end
            end
          end

          goto exit

          ::found::

          b = prev_line:byte(start_col + offset)

          if is_boundary(b) then
            -- Find the first non-whitespace character after the
            -- keyword.
            for i = start_col + offset + 1, last_col - 1 do
              if prev_line:byte(i) > 32 then
                return i - 1
              end
            end
          end

          ::exit::
        end

        -- Otherwise, align with the first character after the first
        -- assignment operator in the line, if one can be found.
        --
        -- NOTE: Make sure to skip bracketed groups.
        local pairs = 0

        for i = start_col, last_col - 1 do
          local b = prev_line:byte(i)

          if b > 32 then
            if b == 40 or b == 91 or b == 123 then  -- ( [ {
              if syngroup_at(prev_lnum, i) == "crystalDelimiter" then
                pairs = pairs + 1
              end
            elseif b == 41 or b == 93 or b == 125 then  -- ) ] }
              if pairs > 0 and syngroup_at(prev_lnum, i) == "crystalDelimiter" then
                pairs = pairs - 1
              end
            elseif pairs == 0 and is_assignment_operator(b, i, prev_line, prev_lnum) then
              for j = i + 1, last_col - 1 do
                if prev_line:byte(j) > 32 then
                  return j - 1
                end
              end
            end
          end
        end

        -- Otherwise, simply align with the starting position and add
        -- a shift.
        return start_col - 1 + shiftwidth()
      elseif last_byte == 44 then  -- ,
        -- If the previous line ends with a comma...

        do
          -- First, find the MSL of the previous line.
          local msl, ind = get_msl(prev_lnum, prev_line, start_col, last_col, true)

          -- Find the line prior to the MSL.
          local prev_prev_lnum = prevnonblank(msl - 1)

          if prev_prev_lnum == 0 then
            goto exit
          end

          local prev_prev_line = getline(prev_prev_lnum)
          local prev_last_byte, prev_last_col = get_last_byte(prev_prev_lnum, prev_prev_line)

          if prev_last_byte == 44 or prev_last_byte == 40 or prev_last_byte == 91 or prev_last_byte == 123 then  -- , ( [ {
            -- If the next previous line also ended with a comma or an
            -- opening bracket, align with the MSL, unless the current line
            -- begins with a closing bracket.
            local line = nvim_get_current_line()

            for i = 1, #line do
              local b = line:byte(i)

              if b > 32 then
                if b == 41 or b == 93 or b == 125 then  -- ) ] }
                  return ind - shiftwidth()
                end

                break
              end
            end

            return ind
          elseif prev_last_byte == 92 or is_operator(prev_last_byte, prev_last_col, prev_prev_line, prev_prev_lnum) then  -- \
            -- If the next previous line ended with a backslash or hanging
            -- operator, align with the MSL.
            return ind
          end

          ::exit::
        end

        -- Else, align with the previous line and add a shift.
        if floating_col then
          return floating_col - 1
        else
          return first_col - 1 + shiftwidth()
        end
      elseif last_byte == 40 or last_byte == 91 or last_byte == 123 or  -- ( [ {
        last_byte == 124 and syngroup_at(prev_lnum, last_col) == "crystalDelimiter" then  -- |
        -- If the previous line ends with an opening bracket, align with
        -- the starting column and add a shift unless the current line
        -- begins with a closing bracket or `end`.
        local line = nvim_get_current_line()

        for i = 1, #line do
          local b = line:byte(i)

          if b > 32 then
            if b == 41 or b == 93 or b == 125 then  -- ) ] }
              return start_col - 1
            elseif b == 101 and line:byte(i + 1) == 110 and line:byte(i + 2) == 100 then  -- e n d
              if (i == 1 or is_boundary(line:byte(i - 1))) and (i + 2 == #line or is_boundary(line:byte(i + 3))) then
                return start_col - 1
              end
            end

            break
          end
        end

        return start_col - 1 + shiftwidth()
      end
    end

    -- Next, examine the first byte of the current line.
    local line = nvim_get_current_line()
    local i, b

    for j = 1, #line do
      b = line:byte(j)

      if b > 32 then
        i = j
        break
      end
    end

    local keyword_dedent = false

    if b == 46 then  -- .
      -- If the current line starts with a leading dot:
      --
      -- If the previous line also started with a leading dot, align with
      -- the previous line.
      --
      -- Else, align with the first leading dot in the previous line, if
      -- any.
      --
      -- Else, add a shift.

      if line:byte(i + 1) ~= 46 then  -- .
        for i = start_col, last_col do
          local b = prev_line:byte(i)

          if b == 46 and prev_line:byte(i + 1) ~= 46 then  -- .
            return i - 1
          end
        end

        return start_col - 1 + shiftwidth()
      end
    elseif b == 41 or b == 93 or b == 125 then  -- ) ] }
      -- If the current line begins with a closing bracket, subtract
      -- a shift.

      if floating_col then
        return floating_col - 1
      else
        local _, ind = get_msl(prev_lnum, prev_line, first_col, last_col, true)
        return ind - shiftwidth()
      end
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

      if i == #line or is_boundary(b) then
        if floating_col then
          return floating_col - 1
        else
          local _, ind, shift = get_msl(prev_lnum, prev_line, first_col, last_col)

          if shift then
            return ind
          else
            return ind - shiftwidth()
          end
        end
      end
    end

    if floating_col then
      return floating_col - 1 + shiftwidth()
    else
      local _, ind, shift = get_msl(prev_lnum, prev_line, first_col, last_col)

      if shift then
        ind = ind + shiftwidth()
      end

      return ind
    end
  end
  -- }}}
end

-- vim:fdm=marker
