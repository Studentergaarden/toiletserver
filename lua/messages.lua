-- -*- coding: utf-8 -*-

--[[
   Not in use. The same functionality is in toiletserver.lua
--]]

-- local postgres   = require 'lem.postgres'

local utils      = require 'lem.utils'
local toilets    = require 'toilets'
local get_toilet = toilets.get

local msgtypes = {}

-- local pg_connect_str = 'user=powermeter dbname=powermeter'
-- local db = assert(postgres.connect(pg_connect_str))
-- assert(db:prepare('put', 'INSERT INTO toilets VALUES ($1, $2, $3)'))

function msgtypes.state(msg)
   local t = get_toilet(msg.id)
   if msg.state == 'true' or msg.state == '1' then
      t:set_locked()
   else
      t:set_unlocked()
   end
   return true
end

function msgtypes.log(msg)
   -- we got a log message
   local t = get_toilet(msg.id)
   t.ms = tonumber(msg.ms)
   -- save the time the door was locked
   t.stamp = string.format('%0.f', utils.now() * 1000) - t.ms
   -- save the duration of the last 5 visits
   t.last_ms[#t.last_ms + 1] = t.ms
   if #t.last_ms > 5 then
      table.remove(t.last_ms,1)
   end
   -- assert(db:run('put', t.id, t.stamp, t.ms))
   return true
end


local M = {}
function M.handle(msg)
   -- msg.id = tonumber(msg.id)
   local type = msg.type
   local cb = msgtypes[type]
   if not cb then
      return nil, 'unknown command type - handle_msg'
   end
   -- return true if type is known
   return cb(msg)
end

return M
