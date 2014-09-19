#!/usr/bin/env lem
-- -*- coding: utf-8 -*-

-- libjason-xs-perl
-- curl -s http | jason-xs

-- netstat -lnptu | grep LISTEN | grep lem
-- lsof -p 27490 | grep TCP
-- nmap localhost

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


local utils        = require 'lem.utils'
local io           = require 'lem.io'
local queue        = require 'lem.io.queue'
local postgres     = require 'lem.postgres'
local qpostgres    = require 'lem.postgres.queued'
local httpserv     = require 'lem.http.server'
local hathaway     = require 'lem.hathaway'

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

local function logfile(message)
   -- write message to file
   local file = io.open("time-server.log", "a")
   file:write(message)
   file:flush()
   file:close()
end

local function socket_handler(client)

      local db = assert(postgres.connect(pg_connect_str))
      local now = utils.now
      assert(db:prepare('put', 'INSERT INTO toilets VALUES ($1, $2, $3)'))
      local self = queue.wrap(client)
      clients[self] = true

  while true do
    local line = client:read('*l')

    if not line then break end

    reading  = parse_reading(line)
    -- Time toilet is occupied
    reading.stamp = format('%0.f', now() * 1000) - reading.ms
    --local stamp = format('%0.f', now() * 1000) - ms

    if reading.type == "log" then
       if reading.id == "t1" then
          put_blipv1(stamp, ms)
       elseif reading.id == "t2" then
          put_blipv2(stamp, ms)
       end
       assert(db:run('put', reading.id, reading.stamp, reading.ms))
    elseif reading.type == "state" then
       -- FREE == 0, BUSY == 1
       
    else
       -- Wrong type - log the incident and the wrongly recieved data
       logfile(format('## error, recieved %s(type), %s(id), %s(ms), %s(stamp)',
                      reading.type, reading.id, reading.ms, reading.stamp))
    end



    -- if occupied do this:, otherwise save value in db
    -- if type_t == "log" then
    --    if id == "t1" then
    --       put_blipv1(stamp, ms)
    --    elseif id == "t2" then
    --       put_blipv2(stamp, ms)
    --    end
    --    assert(db:run('put', id, stamp, ms))
    -- elseif type_t == "state" then
    --    -- FREE == 0, BUSY == 1
    -- else
    --    -- Wrong type - log the incident and the wrongly recieved data
    --    logfile(format('## error, recieved %s(type), %s(id), %s(ms), %s(stamp)',
    --                   type_t, id, ms))
    -- end

  end
  clients[self] = nil
  client:close()
end

utils.spawn(socket.autospawn, socket, socket_handler)

local function parse_reading(str)

   local t = {}
   -- match everything from &key = value&, excluding &.
   for k, v in str:gmatch('([^&]+)=([^&]*)') do
      print("parse_reading: ",k,v)
      t[k] = v
   end
   return t
end

loop
    local msg = parse_reading(line)
    


& type = state & state = true

& type = log & id = t1 & ms = 10000

& type = state & state = false

id, stamp, ms



-- API calls


-- /blip&id=1
OPTIONS('/blip(.*)$', apioptions)
GETM('/blip(.*)$', function(req, res, qsraw)
        -- Get the next blip

        qs = parse_qs(qsraw)
        apiheaders(res.headers)
        -- get_blip queues and returns when a blip is received
        local stamp, ms
        if qs.id == "1" then



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


local function urldecode(str)
   --[[ URLs can only be sent over the Internet using the ASCII character-set.
      Since URLs often contain characters outside the ASCII set, the URL has to
      be converted into a valid ASCII format. This is done by 'percent-encoding'
      where two hex-values represent a character. Space can be either + or %20.
      If there's no hex-values in the string, this function does nothing.

      see http://en.wikipedia.org/wiki/Percent-encoding and
      http://www.w3schools.com/tags/ref_urlencode.asp ]]
   return str:gsub('+', ' '):gsub('%%(%x%x)', function (str)
                                     return string.char(tonumber(str, 16))
                                 end)
end

local function parse_qs(str)
   -- save the decoded keys and values into a table
   local t = {}
   -- match everything from &key = value&, excluding &.
   for k, v in str:gmatch('([^&]+)=([^&]*)') do
      print("parse: ",k,v)
      t[urldecode(k)] = urldecode(v)
   end
   return t
end



-- API calls


-- /blip&id=1
OPTIONS('/blip(.*)$', apioptions)
GETM('/blip(.*)$', function(req, res, qsraw)
        -- Get the next blip

        qs = parse_qs(qsraw)
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

       qs = parse_qs(qsraw)

       if qs.id == nil then -- some error in the ajax call.
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
        -- if since is longer than 15 digit ...
        if #qs.since > 15 then
           httpserv.bad_request(req, res)
           return
        end
        apiheaders(res.headers)
        add_json(res, assert(db:run('get', qs.id, qs.since)))
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
