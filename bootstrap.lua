Bootstrap = {}
Bootstrap.__index = Bootstrap

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

  tinsert(self.EventHandlers[eventName], callback)

  self.Frames.event:RegisterEvent(eventName)
  self.Frames.event:SetScript('OnEvent', callback);

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

  frames.event = self:__createEventFrame()

  return frames

end

---
-- Creates a new frame for the purpose of assigning event handlers to. All
-- handlers created for this addon will be bound to the frame.
--
-- @param addonName
--
-- @return Frame
--
function Bootstrap:__createEventFrame()
  return CreateFrame('Frame', self.name .. 'GlobalEventFrame');
end
