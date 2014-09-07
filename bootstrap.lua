Bootstrap = {}
Bootstrap.__index = Bootstrap

---
-- Creates a new addon scaffold.
--
-- @param addonName The name of the addon as specified in the .toc file.
--
function Bootstrap:new(addonName)

  local self = { name = addonName }

  setmetatable(self, Bootstrap);

  -- Create the initial set of frames for a blank addon. Includes a namespaced
  -- event frame for registering event listeners to.
  self.Frames = self:__createInitialFrames()

  self.EventHandlers = {}

  return self

end

---
-- Registers an event handler for a given event name and callback function.
--
-- @param eventName
-- @param callback
--
function Bootstrap:on(eventName, callback)

  -- Event handlers are grouped together in arrays by the type of event they
  -- respond to. If an array for that event type doesn't exist, then create it.
  if (self.EventHandlers[eventName] == nil) then
    self.EventHandlers[eventName] = {}
  end

  -- Add the handler to the array for its respective event name. table.insert()
  -- doesn't work but the WoW API provides tinsert() which is the same thing.
  tinsert(self.EventHandlers[eventName], callback)

  self.Frames.event:RegisterEvent(eventName)

  -- When a registered event is triggered, go through the array of handlers for
  -- that event and execute each one in turn.
  self.Frames.event:SetScript('OnEvent', function(eventFrame, eventName, ...)
    for _, handler in pairs(self.EventHandlers[eventName]) do
      handler(...)
    end
  end);

end

---
-- Creates all the frames required for a blank addon and returns a table
-- containing references to all of them.
--
-- @param addonName
--
-- @return Table
--
function Bootstrap:__createInitialFrames()

  local frames = {}

  -- The frame that all event handlers for this addon will be bound to.
  frames.event = CreateFrame('Frame', self.name .. 'GlobalEventFrame')

  return frames

end
