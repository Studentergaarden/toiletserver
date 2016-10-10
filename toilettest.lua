#!/usr/bin/env lem
-- -*- coding: utf-8 -*-

--[[
   Testing:
   Setup netcat to listen to the relevant (TCP) port on the server.
   In this case:
   $ nc -l -vv -p 5555

   In case of gateway:
   $ nc -l -vv -p 5555 -g 172.16.0.1
   $ nc -l -k --broker 5555

   Connect to the server with:
   $ nc loki 5555

   Client sending:
   id=t1&type=state&state=1
   id=t2&type=log&ms=29561

   Server sending:
   log id=t1 time=746269 avg=1234567890

   netstat -lnptu | grep LISTEN | grep lem
   lsof -p 27490 | grep TCP
   nmap localhost
   test with http://toilet/ajax/shit

   or using
   libjason-xs-perl
   curl -s http | json_xs
--]]


local utils      = require 'lem.utils'
local io         = require 'lem.io'
local queue      = require 'lem.io.queue'
local postgres   = require 'lem.postgres'
local qpostgres  = require 'lem.postgres.queued'
local httpserv   = require 'lem.http.server'
local hathaway   = require 'lem.hathaway'

package.path     = "/home/paw/lua/toiletserver/lua/?.lua;" .. package.path
package.path     = "lua/?.lua;" .. package.path
local json       = require 'dkjson'
local toilets    = require 'toilets'
local get_toilet = toilets.get

local inspect = require 'inspect'


local helpers    = require 'utils'
local parse_qs   = helpers.parse_qs
local parse_line = helpers.parse_line
local add_json_row = helpers.add_json_row

local assert = assert
local format = string.format
local tonumber = tonumber

table.reduce = function (list, fn)
   local acc
   for k, v in ipairs(list) do
      if 1 == k then
         acc = v
      else
         acc = fn(acc, v)
      end
   end
   return acc
end

-- settings
local pg_connect_str = 'user=powermeter dbname=powermeter' -- password=blabla

-- DB queries
local db = assert(qpostgres.connect(pg_connect_str))
assert(db:prepare('put', 'INSERT INTO toilets VALUES ($1, $2, $3)'))
--local db = assert(qpostgres.connect(pg_connect_str))
assert(db:prepare('get', 'SELECT stamp, ms FROM toilets WHERE id = $1'
                     .. ' AND stamp >= $2 ORDER BY stamp LIMIT 2000'))
assert(db:prepare('last', 'SELECT stamp, ms FROM toilets WHERE id = $1'
                     .. ' ORDER BY stamp DESC LIMIT 1'))
assert(db:prepare('usage', 'SELECT COUNT(*) FROM toilets WHERE id = $1'
                     .. ' AND stamp >= $2'))
assert(db:prepare('between', 'SELECT stamp, ms FROM toilets WHERE id = $1'
                     .. ' AND stamp >= $2 AND stamp <= $3'))

local date = os.date("*t")
date["min"], date["sec"] = 0, 0
local hour = date["hour"]
if hour < 5 then
   -- after midnigth but before 05.00
   -- get previous day's date. No problem if day = 1, lua can handle day = 0
   date["day"] = date["day"] -1
end
local timestamp = os.time(date)*1000

local id = 't1'
local n_visit = assert(db:run('usage', id, timestamp))[1]
n_visit = tonumber( n_visit[1])

local values = assert(db:run('get', id, timestamp))

local avg = 0
local n = #values -- #: length operator
if n > 0 then
   for i = 1, n-1 do
      local point = values[i]
      avg = avg + tonumber(point[2])
      -- print(point[1] .. ' : ' .. point[2])
   end
   local point = values[n]
   avg = avg + tonumber(point[2])
end

print(avg)
avg = math.floor(avg/n)

print(avg)

print(inspect(values))

local ms = 10

displayString = string.format('log id=%s time=%d avg=%d visits=%d\n',
			      id, ms, avg, n_visit)
print(displayString)
print('n: ' .. n)
