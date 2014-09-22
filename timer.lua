local inspect = require 'inspect'
-- https://github.com/kikito/inspect.lua.git
-- evt kopier til /usr/local/lib/lua/5.2/inspect.lua

local utils        = require 'lem.utils'

local toilets = require 'toilets'
local get_toilet = toilets.get

local messages = require 'messages'
local handle_msg = messages.handle

local helpers    = require 'utils'
local parse_line   = helpers.parse_line

print(get_toilet(5):is_locked())
get_toilet(5):set_locked()
print(get_toilet(5):is_locked())
print(get_toilet(4):is_locked())
print (get_toilet(5).id)

local t = get_toilet(4)
t:flush()
t.name = 'stinkeren'
t:flush()


local msg1, line1, cmd, cb, err
msg1 = {type = "state", state = true, id = 1}
line1 = "id = 1 & type = state& state = true"
--line1 = "type = log& val = true& id = 5"

line1 = "id = t1 & type = log & ms = 1000"
cmd = parse_line(line1)
cb, err = handle_msg(cmd)

line1 = "id = t1 & type = log & ms = 2000"
cmd = parse_line(line1)
cb, err = handle_msg(cmd)

line1 = "id = t1 & type = log & ms = 3000"
cmd = parse_line(line1)
cb, err = handle_msg(cmd)

line1 = "id = t1 & type = log & ms = 4000"
cmd = parse_line(line1)
cb, err = handle_msg(cmd)


print(inspect(cmd))
print(inspect(get_toilet(cmd.id)))


cb, err = handle_msg(cmd)


-- print(cb)
-- print(inspect(cb),err)
-- local function socket_handler(client)
--    while true do
--       local line = client:read('*l')
--       local msg, err = parser(line)
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


-- assert(handler(msg))
