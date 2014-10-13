#!/usr/bin/env lem
-- -*- coding: utf-8 -*-

-- libjason-xs-perl
-- curl -s http | json_xs

-- netstat -lnptu | grep LISTEN | grep lem
-- lsof -p 27490 | grep TCP
-- nmap localhost

-- test with http://toilet/ajax/shit



local function usage()
   print('This is the Powermeter daemon')
   print('usage:    ' .. arg[0] .. '\'bind\'')
   print('defaults: bind=*:8000')
   os.exit(1)
end

-- settings
local pg_connect_str = 'user=powermeter dbname=powermeter' -- password=blabla
local bind = arg[1] or '*:8000'
-- end

-- extract bind info
local bind_colon = string.find(bind, ':', 1, true)
if bind_colon == nil then
   usage()
end
local bind_addr = string.sub(bind, 1, bind_colon-1)
local bind_port = tonumber(string.sub(bind, bind_colon+1))


local utils      = require 'lem.utils'
local io         = require 'lem.io'
local queue      = require 'lem.io.queue'
local postgres   = require 'lem.postgres'
local qpostgres  = require 'lem.postgres.queued'
local httpserv   = require 'lem.http.server'
local hathaway   = require 'lem.hathaway'

package.path     = "/home/pawse/lua/toiletserver/lua/?.lua;" .. package.path
package.path     = "lua/?.lua;" .. package.path
local json       = require 'dkjson'
local toilets    = require 'toilets'
local get_toilet = toilets.get

--local messages   = require 'messages'
--local handle_msg = messages.handle

local helpers    = require 'utils'
local parse_qs   = helpers.parse_qs
local parse_line = helpers.parse_line
local add_json_row = helpers.add_json_row

local assert = assert
local format = string.format
local tonumber = tonumber

local socket = assert(io.tcp.listen('*', '5555'))
local clients = {}

local get_blipv1, put_blipv1
do
   local thisthread, suspend, resume
      = utils.thisthread, utils.suspend, utils.resume
   local queue, n = {}, 0

   -- queue thread(from http request) until put-blip is called
   function get_blipv1()
      n = n + 1;
      queue[n] = thisthread()
      return suspend()
   end

   -- resume all http request with the recieved ms.
   function put_blipv1(stamp, ms)
      print(stamp, ms, n)
      for i = 1, n do
         resume(queue[i], stamp, ms)
         queue[i] = nil
      end
      n = 0
   end
end

local get_blipv2, put_blipv2
do
   local thisthread, suspend, resume
      = utils.thisthread, utils.suspend, utils.resume
   local queue, n = {}, 0
   function get_blipv2()
      n = n + 1;
      queue[n] = thisthread()
      return suspend()
   end
   function put_blipv2(stamp, ms)
      print(stamp, ms, n)
      for i = 1, n do
         resume(queue[i], stamp, ms)
         queue[i] = nil
      end
      n = 0
   end
end

local get_dump, put_dump
do
   local thisthread, suspend, resume
      = utils.thisthread, utils.suspend, utils.resume
   local queue, n = {}, 0
   function get_dump()
      n = n + 1;
      queue[n] = thisthread()
      return suspend()
   end
   function put_dump(t)
      for i = 1, n do
         resume(queue[i], t)
         queue[i] = nil
      end
      n = 0
   end
end


local pg_connect_str = 'user=powermeter dbname=powermeter'
local db = assert(postgres.connect(pg_connect_str))
assert(db:prepare('put', 'INSERT INTO toilets VALUES ($1, $2, $3)'))
local msgtypes = {}
function msgtypes.state(msg)
   local t = get_toilet(msg.id)
   if msg.state == 'true' or msg.state == "1" then
      t:set_locked()
   else
      t:set_unlocked()
   end
   t.stamp_state = string.format('%0.f', utils.now() * 1000)
   put_dump(t)
   return true
end

function msgtypes.log(msg)
   -- we got a log message
   local t = get_toilet(msg.id)
   t.ms = tonumber(msg.ms)
   t.stamp = string.format('%0.f', utils.now() * 1000) - t.ms
   -- save the duration of the last 5 visits

   t.last_ms[#t.last_ms + 1] = t.ms
   t.last_stamp[#t.last_stamp + 1] = t.stamp
   if #t.last_ms > 1 then
      for i = #t.last_ms,2,-1 do
         t.last_ms[i] = t.last_ms[i-1]
         t.last_stamp[i] = t.last_stamp[i-1]
      end
   end
   if #t.last_ms > 5 then
      table.remove(t.last_ms,#t.last_ms)
      table.remove(t.last_stamp,#t.last_stamp)
   end
   t.last_ms[1] = t.ms
   t.last_stamp[1] = t.stamp

   assert(db:run('put', t.id, t.stamp, t.ms))
   return true
end

local function handle_msg(msg)
   msg.id = msg.id
   local type = msg.type
   local cb = msgtypes[type]
   if not cb then
      return nil, 'unknown command type - handle_msg'
   end
   -- return true if type is known
   return cb(msg)
end


local inspect = require 'inspect'
-- setup TCP server
local function socket_handler(client)
   local self = queue.wrap(client)
   clients[self] = true

   while true do
      local line = client:read('*l')
      if not line then break end
      print(line)
      local msg, err = parse_line(line)
      print(inspect(msg),err,'\n')
      if not msg then
         print(err, line)
      else
         local ret, err = handle_msg(msg)
         if not ret then
            print(err, line)
         end
      end
   end

   clients[self] = nil
   client:close()
end


-- local function serial_handler()

--    local serial = assert(io.open('/dev/blipduino', 'r'))
--    -- local serial = assert(io.open('/dev/ttyACM0', 'r'))

--    -- discard first two readings
--    assert(serial:read('*l'))
--    assert(serial:read('*l'))

--    while true do
--       local line = assert(serial:read('*l'))
--       if not line then break end

--       local msg, err = parse_line(line)
--       if not msg then
--          print(err, line)
--       else
--          local ret, err = handle_msg(msg)
--          if not ret then
--             print(err, line)
--          end
--       end
--    end
-- end

-- spawn TCP server and Serial listener
utils.spawn(socket.autospawn, socket, socket_handler)
-- utils.spawn(serial_handler)


local function sendfile(content, path)
   return function(req, res)
      res.headers['Content-Type'] = content
      res.file = path
   end
end


hathaway.import()
GET('/',               sendfile('text/html; charset=UTF-8',       'index.html'))
GET('/index.html',     sendfile('text/html; charset=UTF-8',       'index.html'))
GET('/jquery.js',      sendfile('text/javascript; charset=UTF-8', 'jquery.js'))
GET('/jquery.flot.js', sendfile('text/javascript; charset=UTF-8', 'jquery.flot.js'))
GET('/excanvas.js',    sendfile('text/javascript; charset=UTF-8', 'excanvas.js'))
GET('/favicon.ico',    sendfile('image/x-icon',                   'favicon.ico'))

local function apiheaders(headers)
   headers['Content-Type'] = 'text/javascript; charset=UTF-8'
   headers['Cache-Control'] = 'max-age=0, must-revalidate'
   headers['Access-Control-Allow-Origin'] = '*'
   headers['Access-Control-Allow-Methods'] = 'GET'
   headers['Access-Control-Allow-Headers'] = 'origin, x-requested-with, accept'
   headers['Access-Control-Max-Age'] = '60'
end

local function apioptions(req, res)
   apiheaders(res.headers)
   res.status = 200
end


function add_json_table(list)
   local d = {}
   for k,v in pairs(list) do
      d[v] = add_json_row(get_toilet(v))
   end
   local M = json.encode(d,
                         { indent = true,
                           keyorder = {'id','locked','last_state','stamp','last_ms'} })
   return M
end


local function add_table(values)
   local n = #values -- #: length operator
   local ms_array = {}
   local stamp_array = {}
   if n > 0 then
      for i = 1, n-1 do
         local point = values[i]
         table.insert(stamp_array, tonumber(point[1]))
         table.insert(ms_array, tonumber(point[2]))
      end
      local point = values[n]
      table.insert(stamp_array, tonumber(point[1]))
      table.insert(ms_array, tonumber(point[2]))
   end
   t = {}
   t[values[0][1]] = stamp_array
   t[values[0][2]] = ms_array
   return t
end


local function add_json_raw(res, id, values)
   local n = #values -- #: length operator
   if n > 0 then
      for i = 1, n-1 do
         local point = values[i]
         res:add('{"id":"%s","stamp":%s,"ms":%s},', id, point[1], point[2])
      end
      local point = values[n]
      res:add('{"id":"%s","stamp":%s,"ms":%s}', id, point[1], point[2])
   end
end


local function add_json(res, values)
   res:add('[')
   local n = #values -- #: length operator
   if n > 0 then
      for i = 1, n-1 do
         local point = values[i]
         res:add('[%s,%s],', point[1], point[2])
      end
      local point = values[n]
      res:add('[%s,%s]', point[1], point[2])
   end
   res:add(']')
end


-- DB queries
local db = assert(qpostgres.connect(pg_connect_str))
assert(db:prepare('get', 'SELECT stamp, ms FROM toilets WHERE id = $1'
                     .. ' AND stamp >= $2 ORDER BY stamp LIMIT 2000'))
assert(db:prepare('last', 'SELECT stamp, ms FROM toilets WHERE id = $1'
                     .. ' ORDER BY stamp DESC LIMIT 1'))
assert(db:prepare('usage', 'SELECT COUNT(*) FROM toilets WHERE id = $1'
                     .. ' AND stamp >= $2'))
assert(db:prepare('between', 'SELECT stamp, ms FROM toilets WHERE id = $1'
                     .. ' AND stamp >= $2 AND stamp <= $3'))

-- API calls

-- /dump&id=1
OPTIONS('/dump(.*)$', apioptions)
GETM('/dump(.*)$', function(req, res, qsraw)

        local qs, err = parse_qs(qsraw)
        apiheaders(res.headers)
        if qs.id == nil then
           res:add('{}')
        else
           t = get_dump()
           res:add('{"id": "%s", "locked": %s, "stamp_state": %s, "stamp": %s, "last_stamp": [%s], "last_ms": [%s]}',
                   t.id, t:is_locked(), t.stamp_state, t.stamp, table.concat(t.last_stamp,","), table.concat(t.last_ms,","))
        end
end)

-- /occupied&id=1
OPTIONS('/occupied(.*)$', apioptions)
GETM('/occupied(.*)$', function(req, res, qsraw)

        local qs, err = parse_qs(qsraw)
        apiheaders(res.headers)
        if qs.id == nil then
           local toilet_list = {'t1', 't2', 'b1', 'b2', 'b3'}
           res:add('%s',add_json_table(toilet_list))
           -- print(err)
           -- httpserv.bad_request(req, res)
           -- return
        else
           local t = get_toilet(qs.id)
           res:add('{"id": "%s", "locked": %s, "stamp_state": %s, "stamp": %s, "last_stamp": [%s], "last_ms": [%s]}',
                   t.id, t:is_locked(), t.stamp_state, t.stamp, table.concat(t.last_stamp,","), table.concat(t.last_ms,","))
        end
end)


-- /blip&id=1
OPTIONS('/blip(.*)$', apioptions)
GETM('/blip(.*)$', function(req, res, qsraw)
        -- Get the next blip

        local qs, err = parse_qs(qsraw)
        if qs == nil then
           print(err)
           httpserv.bad_request(req, res)
           return
        end
        apiheaders(res.headers)
        -- get_blip queues and returns when a blip is received
        local stamp, ms
        if qs.id == "1" then
           stamp, ms = get_blipv1()
        else
           stamp, ms = get_blipv2()
        end
        res:add('[%s,%s]', stamp, ms)
end)


-- /last&id=1 or /last&id=1&ms=val
OPTIONS('/last(.*)$', apioptions)
GETM('/last(.*)$', function(req, res, qsraw)
        -- get the latest blip OR
        -- get the last #ms blips

        local qs, err = parse_qs(qsraw)
        if qs == nil then
           print(err)
           httpserv.bad_request(req, res)
           return
        end
        apiheaders(res.headers)

       if qs.ms == nil then
          -- just get latest blip
          local point = assert(db:run('last', qs.id))[1]
          res:add('[%s,%s]', point[1], point[2])
       else
          -- get the last #ms blips
          if #qs.ms > 15 then
             httpserv.bad_request(req, res)
             return
          end
          local since = format('%0.f',
                               utils.now() * 1000 - tonumber(qs.ms))
          add_json(res, assert(db:run('get', qs.id, since)))
       end
end)

-- /since&id=1&from=val or /since&id=1&from=val&to=val
OPTIONSM('^/since(.*)$', apioptions)
GETM('^/since(.*)$', function(req, res, qsraw)
        -- get blips from a given time - MAX 2000 readings OR
        -- get blips from an interval
        qs = parse_qs(qsraw)

        -- print(inspect(qsraw))
        -- print(inspect(qs))
        -- if since is longer than 15 digit ...
        if (qs.id == nil) then
           httpserv.bad_request(req, res)
           return
        end
        apiheaders(res.headers)
        local n = #qs.id
        local tres = {}

        res:add('[')
        for i = 1, n do
           local blips = nil
           local id = qs.id[i]
           if qs.to == nil then
              blips = assert(db:run('get', id, qs.from))
           else
              blips = assert(db:run('between', id, qs.from, qs.to))
           end
           add_json_raw(res, qs.id[i], blips)
           if i < n and n > 1 then
              res:add(',')
           end
        end
        res:add(']')

end)


-- /usage&id=1&ms=val
OPTIONS('/usage(.*)$', apioptions)
GETM('/usage(.*)$', function(req, res, qsraw)
        -- get the power usage the last #ms

        qs = parse_qs(qsraw)
        -- if #qs.ms > 15 then
        --    httpserv.bad_request(req, res)
        --    return
        -- end
        apiheaders(res.headers)

        local ms = format('%0.f',
                             utils.now() * 1000 - tonumber(qs.ms))
        local blips = assert(db:run('usage', qs.id, ms))[1]
        res:add('[%s]', blips[1])
end)


OPTIONSM('^/between/(%d+)$', apioptions)
GETM('^/between/(%d+)/(%d+)$', function(req, res, since)
        if #since > 15 then
           httpserv.bad_request(req, res)
           return
        end
        apiheaders(res.headers)

        local since = format('%0.f',
                             utils.now() * 1000 - tonumber(stop))
        local blips = assert(db:run('usage', id, since, since))[1]
        res:add('[%s]', blips[1])
end)



hathaway.debug = print
-- assert(Hathaway(bind_addr, bind_port))
assert(Hathaway('*', arg[1] or 8000))

-- vim: syntax=lua ts=2 sw=2 noet:
