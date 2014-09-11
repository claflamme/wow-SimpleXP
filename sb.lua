sb = {};
sb.main = {};
sb.xp = {};

local currentAddonName, addonTable = ...

SimpleXP = addonTable.Foundation

function sb.main:createInitialSettings()
    sbSettings = {
        xp = {
            width = GetScreenWidth(),
            height = 2,
            font = "Fonts\\FRIZQT__.TTF",
            fontSize = 8,
            texture = "Interface\\TargetingFrame\\UI-StatusBar",
            xpColor = { r = 1.0, g = 0.0, b = 1.0 },
            restedColor = { r = 0.0, g = 0.5, b = 1.0 },
            repColor = { r = 0.0, g = 0.6, b = 0.0 },
            tooltipOffset = 6
        },
        unitframes = {
            width = 300,
            healthHeight = 20,
            healthColor = { r = 1.0, g = 0.0, b = 0.0 },
            powerHeight = 20,
            texture = "Interface\\TargetingFrame\\UI-StatusBar"
        }
    };
end
