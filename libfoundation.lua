-- Whenever WoW loads and runs a .lua file, it passes in two parameters which
-- can be accessed via the ... token:
local currentAddonName, addonTable = ...

-- This is the table that gets "exported".
local Foundation = {}
Foundation.__index = Foundation

-- =============================================================================
-- Base Functionality
-- =============================================================================

---
-- A convenience method for bootstrapping an addon once its loaded.
--
-- @param callback Function to execute when the addon is loaded.
--
-- @return Foundation
--------------------------------------------------------------------------------
function Foundation:init(callback)

  self:on('ADDON_LOADED', function(addonName)
    if addonName == self.name then
      callback()
    end
  end)

  return self

end


---
-- Creates a new Foundation instance for use in an addon.
--
-- @param addonName The name of the addon as specified in the .toc file.
--------------------------------------------------------------------------------
function Foundation:__new()

  local self = {
    name = currentAddonName,
    EventHandlers = {}
  }

  setmetatable(self, Foundation);

  -- Create the initial set of frames for a blank addon. Includes a namespaced
  -- event frame for registering event listeners to.
  self.Frames = self:__createInitialFrames()

  return self

end

---
-- Creates all the frames required for a blank addon and returns a table
-- containing references to all of them.
--
-- @param addonName
--
-- @return Table
--------------------------------------------------------------------------------
function Foundation:__createInitialFrames()

  local frames = {}

  -- The frame that all event handlers for this addon will be bound to.
  frames.event = CreateFrame('Frame', self.name .. 'GlobalEventFrame')

  return frames

end

-- =============================================================================
-- Event Handling
-- =============================================================================

---
-- Registers an event handler for a given event name and callback function.
-- Events can be namespaced by adding a dot followed by the namespace to the
-- event name. E.g. 'ADDON_LOADED.sampleNamespace'. This makes it easier to
-- remove event handlers later on.
--
-- @param eventName
-- @param callback
--------------------------------------------------------------------------------
function Foundation:on(eventName, callback)

  local handler = { callback = callback }

  eventName, handler.namespace = self:__parseEventName(eventName)

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
-- Unregisters events. You can use it to remove all handlers for a given event,
-- all handlers in a given namespace, or both.
--
-- @param eventName
--------------------------------------------------------------------------------
function Foundation:off(eventName)

  local eventName, namespace = self:__parseEventName(eventName)

  -- Remove all handlers for a given event.
  if namespace == nil then

    self.EventHandlers[eventName] = nil
    self.Frames.event:UnregisterEvent(eventName)

  -- Remove all handlers using a given namespace.
  elseif eventName == '' and namespace ~= nil then

    self:__unregisterNamespace(namespace)

  -- Remove all handlers for a given event that have a given namespace.
  elseif eventName ~= '' and namespace ~= nil then

    self:__unregisterNamespacedEvent(eventName, namespace)

  end

end

---
-- Goes through all of the registered handlers for a given event and executes
-- them in sequence.
--
-- @param eventName
--------------------------------------------------------------------------------
function Foundation:__dispatch(eventName, ...)

  for _, handler in pairs(self.EventHandlers[eventName]) do
    handler.callback(...)
  end

end

---
-- Splits a namespaced event name in to its two parts. If the event name is not
-- namespaced, the return value for namespace will be nil.
--
-- @param eventName
--
-- @return eventName
-- @return namespace
--------------------------------------------------------------------------------
function Foundation:__parseEventName(eventName)
  return strsplit('.', eventName)
end

---
-- Unregisters all event handlers that use a given namespace.
--
-- @param namespace
--------------------------------------------------------------------------------
function Foundation:__unregisterNamespace(namespace)

  for eventName, _ in pairs(self.EventHandlers) do
    self:__unregisterNamespacedEvent(eventName, namespace)
  end

end

---
-- Unregisters any handlers for [eventName] that use the given namespace.
--
-- @param eventName
-- @param namespace
--------------------------------------------------------------------------------
function Foundation:__unregisterNamespacedEvent(eventName, namespace)

  for i, handler in ipairs(self.EventHandlers[eventName]) do

    if (handler.namespace == namespace) then
      self.EventHandlers[eventName][i] = nil
    end

  end

end

addonTable.Foundation = Foundation:__new()
