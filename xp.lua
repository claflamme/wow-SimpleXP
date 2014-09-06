function sb.xp:loadModule()

	-- Used to store tooltip text fragments
	self.xpText, self.repText = "";

	self:createFrames();
	self:registerEvents();

end

function sb.xp:createFrames()

	-- Dummy parent frame
	self.container = CreateFrame("Frame", "sbXpContainer");

	-- XP Bar
	self.xpBar = CreateFrame("StatusBar", "sbXpBar", self.container);
	self.xpBar:SetSize(sbSettings.xp.width, sbSettings.xp.height);
	self.xpBar:SetPoint("BOTTOM", "UIParent" ,"BOTTOM", 0, 0);
	self.xpBar:SetStatusBarTexture(sbSettings.xp.texture);
	self.xpBar:SetScript("OnEnter", sb.xp.showTooltip);
	self.xpBar:SetScript("OnLeave", sb.xp.hideTooltip);
	self.xpBar:Show();

	-- Rested XP Bar
	self.restedBar = CreateFrame("StatusBar", "sbRestedXpBar", self.xpBar);
	self.restedBar:SetAllPoints(sb.xp.xpBar);
	self.restedBar:SetStatusBarTexture(sbSettings.xp.texture);
	self.restedBar:SetStatusBarColor(sbSettings.xp.restedColor.r, sbSettings.xp.restedColor.g, sbSettings.xp.restedColor.b, 0.5);
	self.restedBar:Show();

	-- Reputation watch bar
	self.repBar = CreateFrame("StatusBar", "sbRepBar", self.container);
	self.repBar:SetSize(sbSettings.xp.width, sbSettings.xp.height);
	self.repBar:SetPoint("BOTTOM", "UIParent" ,"BOTTOM", 0, 0);
	self.repBar:SetFrameLevel(1); 
	self.repBar:SetStatusBarTexture(sbSettings.xp.texture);
	self.repBar:SetScript("OnEnter", sb.xp.showTooltip);
	self.repBar:SetScript("OnLeave", sb.xp.hideTooltip);
	self.repBar:Show();

	-- Tooltip frame
	self.tooltip = CreateFrame("SimpleHTML", "sbXpTooltip", self.container);
	self.tooltip:SetSize(sbSettings.xp.width, sbSettings.xp.fontSize);
	self.tooltip:SetPoint("BOTTOM", "UIParent", "BOTTOM", 0, sbSettings.xp.tooltipOffset);
	self.tooltip:SetFrameLevel(2);
	self.tooltip:SetFont(sbSettings.xp.font, sbSettings.xp.fontSize, "OUTLINE");
	self.tooltip:SetText("Oh great it's broken. How did you even break this? Shit.");
	self.tooltip:Hide();

end

function sb.xp:registerEvents()

	-- Create a dummy frame to handle game events
	sb.xp.eventFrame = CreateFrame("Frame");

	-- Store all the events in here
	sb.xp.events = {};

	function sb.xp.events:PLAYER_ENTERING_WORLD(...)
		sb.xp:updateXpBar();
		sb.xp:updateRepBar();
	end

	function sb.xp.events:PLAYER_XP_UPDATE(...)
		if select(1, ...) == "player" then
			sb.xp:updateXpBar();
		end
	end

	function sb.xp.events:UPDATE_EXHAUSTION(...)
		sb.xp:updateXpBar();
	end

	function sb.xp.events:UPDATE_FACTION(...)
		sb.xp:updateRepBar();
	end

	-- When an event is called for the frame, trigger the function
	-- called "event:EVENT_NAME()"
	sb.xp.eventFrame:SetScript("OnEvent", function(self, eventName, ...)
		sb.xp.events[eventName](self, ...);
	end);

	-- Register all events for which handler functions have been defined
	for event in pairs(sb.xp.events) do
		sb.xp.eventFrame:RegisterEvent(event);
	end

end

function sb.xp:updateXpBar()

	-- If the player is max level then move the bar off the screen
	if playerIsMaxLevel() then
		self.xpBar:SetPoint("TOP", "UIParent", "BOTTOM", 0, 0);
		do return end
	end

	local current, max 	= UnitXP("player"), UnitXPMax("player");
	local min 			= math.min(0, current)
	local rested 		= GetXPExhaustion();

	if rested then
		self.xpBar:SetStatusBarColor(sbSettings.xp.restedColor.r, sbSettings.xp.restedColor.g, sbSettings.xp.restedColor.b, 1.0);
	else
		self.xpBar:SetStatusBarColor(sbSettings.xp.xpColor.r, sbSettings.xp.xpColor.g, sbSettings.xp.xpColor.b, 1.0);
		rested = 0;
	end

	-- Update mouseover text
	self.xpText = string.format("|cFFFFCC00 Level %s|r %s/%s (%.2f%%), %s Rested", UnitLevel("player"), formatNumber(current), formatNumber(max), (max > 0 and current / max or 0) * 100, formatNumber(rested));	

	self.xpBar:SetMinMaxValues(min, max);
	self.xpBar:SetValue(current);

	self.restedBar:SetMinMaxValues(min, max);
	self.restedBar:SetValue(current + rested);

	self.setBarDisplayLevels();

end;

function sb.xp:updateRepBar()

	local factionName, standing, min, max, current = GetWatchedFactionInfo();

	if factionName then

		-- Get the status label (Friendly, Honored, etc) for the player's standing level
		standing = getglobal("FACTION_STANDING_LABEL" .. standing);

		-- Blizzard returns weird values for min, max, and current.
		-- "min" and "max" return the minimum or maximum "bound" for the current
		-- standing level (so min 21,000 and max 42,000 for revered), and "current"
		-- can be any number in between.
		-- We have to normalize it, so revered is handled as 0 - 21,000.
		current = current - min;
		max = max - min;

		-- Update mouseover text
		self.repText = string.format("|cFFFFCC00 %s|r %s -  %s/%s (%.2f%%)", factionName, standing, formatNumber(current), formatNumber(max), (max > 0 and current / max or 0) * 100);
		
		self.repBar:SetStatusBarColor(sbSettings.xp.repColor.r, sbSettings.xp.repColor.g, sbSettings.xp.repColor.b, 1.0);
		self.repBar:SetMinMaxValues(0, max);
		self.repBar:SetValue(current);

		self.repBar:Show();

	else

		self.repBar:Hide();

	end

	self:setBarDisplayLevels();

end

function sb.xp:showTooltip()

	local text = "";

	-- Max level, tracking a reputation
	if playerIsMaxLevel() and sb.xp.repBar:IsVisible() then
		text = sb.xp.repText;
	-- Not max level, tracking a reputation
	elseif (not playerIsMaxLevel()) and sb.xp.repBar:IsVisible() then
		text = sb.xp.xpText .. " " .. sb.xp.repText;
	-- Max level, not tracking a reputation
	elseif playerIsMaxLevel() and (not sb.xp.repBar:IsVisible()) then
		text = "";
	-- Not max level, not tracking a reputation
	elseif (not playerIsMaxLevel()) and (not sb.xp.repBar:IsVisible()) then
		text = sb.xp.xpText
	end

	sb.xp.tooltip:SetText("<html><body><p align='center'>" .. text .. "</p></body></html>");
	sb.xp.tooltip:Show();

end

function sb.xp:setBarDisplayLevels()

	local repMin, repMax = sb.xp.repBar:GetMinMaxValues();
	local restedMin, restedMax = sb.xp.restedBar:GetMinMaxValues();

	local repBarSize = math.floor((sb.xp.repBar:GetValue() / repMax) * 1000);
	local xpBarSize = math.floor((sb.xp.restedBar:GetValue() / restedMax) * 1000);

	if repBarSize < xpBarSize then

		sb.xp.repBar:SetFrameLevel(2);
		sb.xp.xpBar:SetFrameLevel(1);
		sb.xp.restedBar:SetFrameLevel(0);

	else

		sb.xp.repBar:SetFrameLevel(0);
		sb.xp.xpBar:SetFrameLevel(2);
		sb.xp.restedBar:SetFrameLevel(1);

	end

end

function sb.xp:hideTooltip()

	sb.xp.tooltip:Hide();

end

function sb.xp:hide()

	sb.xp.container:Hide();

end

function sb.xp:show()

	sb.xp.container:Show();

end
