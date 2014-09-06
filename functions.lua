---
-- Formats a number with thousands separators. Taken from:
-- http://lua-users.org/wiki/FormattingNumbers
--
-- @param number
-- @return string
--
function formatNumber(number)

  -- The number of matches for a regex of 3 digits. Once this is zero, it means
  -- all the thousands have been separated.
  local numMatches

  while (true) do

    number, numMatches = string.gsub(number, '^(-?%d+)(%d%d%d)', '%1,%2')

    if (numMatches == 0) then
      break;
    end

  end

  return number

end

---
-- Determines if the player is the highest possible level. Should work
-- regardless of which expansion the game is running under.
--
-- @return boolean
--
function playerIsMaxLevel()

  local maxLevel = MAX_PLAYER_LEVEL_TABLE[GetAccountExpansionLevel()]

  return UnitLevel('player') == maxLevel

end
