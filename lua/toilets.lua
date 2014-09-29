-- -*- coding: utf-8 -*-

local toilets = {} -- stores all the toilet objects


-- When you look up a table with a key, regardless of what the key is (t[4],
-- t.foo, and t["foo"], for example), and a value hasn't been assigned for that
-- key, Lua will look for an __index key in the table's metatable (if it has a
-- metatable). If __index contains a table, Lua will look up the key originally
-- used in the table belonging to__index.

-- Thus you're seeing is the simplest way to achieve OOP (Object-Oriented
-- Programming) in Lua. The toilet table represents the class, which contains
-- all the functions that instances can use
-- http://nova-fusion.com/2011/06/30/lua-metatables-tutorial/
local toilet = {}
toilet.__index = toilet

function toilet:set_locked()
   self.locked = true
end
-- equal to
-- function toilet.set_locked(self)
--    self.locked = false
-- end

function toilet:set_unlocked(ms)
   self.locked = false
end

function toilet:is_locked()
   return self.locked
end

function toilet:get_name()
   if self.name then
      return self.name
   else
      return string.format('number %d', self.id)
   end
end

function toilet:flush()
   print(string.format('flushed toilet %s', self:get_name()))
end

local function new_toilet(id)
   -- create new instance of toilet; use the object toilet as metatable and set
   -- the default values.
   return setmetatable({
         id = id,
         locked = false,
         stamp = nil,
         ms = nil,
         last_state,
         last_ms = {},
         last_stamp = {},
   }, toilet)
end

local M = {}

function M.get(id)
   local t = toilets[id]
   if not t then
      t = new_toilet(id)
      toilets[id] = t
   end
   return t
end

function M.get_readonly(id)
   local t = toilets[id]
   if not t then
      return nil, "id does not exist"
   end
   return t
end


return M
