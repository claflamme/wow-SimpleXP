Bootstrap = {}
Bootstrap.__index = Bootstrap

---
-- Creates a new addon scaffold.
--
-- @param addonName The name of the addon as specified in the .toc file.
--
function Bootstrap:new(addonName)

  local self = { name = addonName, EventHandlers = {} }

  setmetatable(self, Bootstrap);

  -- Create the initial set of frames for a blank addon. Includes a namespaced
  -- event frame for registering event listeners to.
  self.Frames = self:__createInitialFrames()

  return self

end

---
-- Registers an event handler for a given event name and callback function.
-- Events can be namespaced by adding a dot followed by the namespace to the
-- event name. E.g. 'ADDON_LOADED.sampleNamespace'. This makes it easier to
-- remove event handlers later on.
--
-- @param eventName
-- @param callback
--
function Bootstrap:on(eventName, callback)

  local handler = { callback = callback }

  eventName, handler.namespace = strsplit('.', eventName)

  -- Event handlers are grouped together in arrays by the type of event they
  -- respond to. If an array for that event type doesn't exist, then create it.
  if (self.EventHandlers[eventName] == nil) then
    self.EventHandlers[eventName] = {}
  end

  -- Add the handler to the array for its respective event name. table.insert()
  -- doesn't work but the WoW API provides tinsert() which is the same thing.
  tinsert(self.EventHandlers[eventName], handler)

  self.Frames.event:RegisterEvent(eventName)

  -- When a registered event is triggered, dispatch all handlers for it.
  self.Frames.event:SetScript('OnEvent', function(eventFrame, eventName, ...)
    self:__dispatch(eventName, ...)
  end);

end

---
-- A convenience method for the ADDON_LOADED event handler.
--
-- @param callback Function to execute when the addon is loaded.
--
function Bootstrap:init(callback)

  self:on('ADDON_LOADED', function(addonName)
    if addonName == self.name then
      callback()
    end
  end)

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

---
-- Goes through all of the registered handlers for a given event and executes
-- them in sequence.
--
-- @param eventName
function Bootstrap:__dispatch(eventName, ...)

  for _, handler in pairs(self.EventHandlers[eventName]) do
    handler.callback(...)
  end

end
