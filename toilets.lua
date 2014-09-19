local toilets = {} -- stores all the toilet objects

local toilet = {}
toilet.__index = toilet

function toilet:set_locked()
	self.locked = true
end

function toilet:set_unlocked(ms)
	self.locked = false
	-- log time to db
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

local function fresh_toilet(id)
   return setmetatable({
         id = id,
         locked = false,
         last_ms = {},
   }, toilet)
end

local M = {}

function M.get(id)
	local t = toilets[id]
	if not t then
		t = fresh_toilet(id)
		toilets[id] = t
	end
	return t
end

return M
