sb = {};
sb.main = {};
sb.xp = {};

function sb.main:loadModule()
    self.registerEvents();
end

function sb.main:registerEvents()

    sb.main.eventFrame = CreateFrame("Frame", "sbGlobalEventFrame");
    sb.main.events = {};

    function sb.main.events:ADDON_LOADED(addonName)
        if addonName == "sb" then
            if not sbSettings then
                sb.main.createInitialSettings();
            end
            sb.main:loadCompleteAddon();
        end
    end

    function sb.main.events:CINEMATIC_START()
        sb.xp:hide();
    end

    function sb.main.events:CINEMATIC_STOP()
        sb.xp:show();
    end

    function sb.main.events:VEHICLE_ENTERED(unitId)
        if unitId == "player" then
            sb.xp:Hide();
        end
    end

    function sb.main.events:VEHICLE_EXITED(unitId)
        if unitId == "player" then
            sb.xp:Show();
        end
    end

    sb.main.eventFrame:SetScript("OnEvent", function(self, eventName, ...)
        sb.main.events[eventName](self, ...);
    end);

    for event in pairs(sb.main.events) do
        sb.main.eventFrame:RegisterEvent(event);
    end

end

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

function sb.main:loadCompleteAddon()
    sb.xp:loadModule();
    -- sb.config:loadModule();
end

sb.main:loadModule();
