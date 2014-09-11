SimpleXP:init(function()
  if not sbSettings then
    sb.main.createInitialSettings();
  end
  sb.xp:loadModule()
end)

SimpleXP:on('CINEMATIC_START', function()
  sb.xp:hide();
end)

SimpleXP:on('CINEMATIC_STOP', function()
  sb.xp:show();
end)

SimpleXP:on('UNIT_ENTERING_VEHICLE', function(unitId)
  if unitId == 'player' then
    sb.xp:hide();
  end
end)

SimpleXP:on('UNIT_EXITED_VEHICLE', function(unitId)
  if unitId == 'player' then
    sb.xp:show();
  end
end)

SimpleXP:on('PLAYER_ENTERING_WORLD', function()
  sb.xp:updateXpBar();
  sb.xp:updateRepBar();
end)

SimpleXP:on('PLAYER_XP_UPDATE', function(unitId)
  if unitId == 'player' then
    sb.xp:updateXpBar();
  end
end)

SimpleXP:on('UPDATE_EXHAUSTION', function()
  sb.xp:updateXpBar();
end)

SimpleXP:on('UPDATE_FACTION', function()
  sb.xp:updateRepBar();
end)
