-- -*- coding: utf-8 -*-

utils = {}


function utils.logfile(message)
   -- write message to file
   local file = io.open("time-server.log", "a")
   file:write(message)
   file:flush()
   file:close()
end


function utils.parse_line(str)
   -- remove spaces, if any
   str = str:gsub("%s+", "")
   local t = {}
   -- match everything from &key = value&, excluding &.
   for k, v in str:gmatch('([^&]+)=([^&]*)') do
      -- print("parse_reading: ",k,v)
      t[k] = v
   end
   return t
end


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


function utils.parse_qs(str)
   -- save the decoded keys and values into a table
   local t = {}
   -- match everything from &key = value&, excluding &.
   for k, v in str:gmatch('([^&]+)=([^&]*)') do
      -- print("parse: ",k,v)
      t[urldecode(k)] = urldecode(v)
   end
   -- if not t.id then
   --    return nil, 'No id in AJAX call - parse_qs: ' .. str
   -- end
   return t
end


function utils.add_json_row(t)
   d = {}
   for k,v in pairs(t) do
      if k == nil then
      elseif k == 'id' then
         d[k] = v --tonumber(v)
         -- d2[v] = d
      elseif k == 'last_ms' then
         d[k] = v --tonumber(v)
      elseif k == 'last_stamp' then
         d[k] = v --tonumber(v)
      elseif k == 'locked' then
         d[k] = v
      elseif k == 'stamp' then
         d[k] = tonumber(v)
      elseif k == 'stamp_state' then
         d[k] = tonumber(v)
      end
   end
   return d
end


return utils
