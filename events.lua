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

SimpleXP:on('VEHICLE_ENTERED', function(unitId)
  if unitId == "player" then
    sb.xp:Hide();
  end
end)

SimpleXP:on('VEHICLE_EXITED', function(unitId)
  if unitId == "player" then
    sb.xp:Show();
  end
end)
