local toilets = require 'toilets'
local get_toilet = toilets.get

print(get_toilet(5):is_locked())
get_toilet(5):set_locked()
print(get_toilet(5):is_locked())
print(get_toilet(4):is_locked())
print (get_toilet(5).id)

local t = get_toilet(4)
t:flush()
t.name = 'stinkeren'
t:flush()


local msgtypes = {}

function msgtypes.state(msg)
	local t = get_toilet(msg.id)
	if msg.state then
		t:set_locked()
	else
		t:set_unlocked()
	end
	return true
end

local inspect = require 'inspect' -- https://github.com/kikito/inspect.lua.git
-- evt kopier til /usr/local/lib/lua/5.2/inspect.lua

function msgtypes.log(msg)
	-- we got a log message
	print(inspect(msg))
	return true
end

local function handle_msg(msg)
	local type = msg.type
	local cb = msgtypes[type]
	if not cb then
		return nil, 'unknown type'
	end
	return cb(msg)
end

local function socket_handler(client)
	while true do
		local line = client:read('*l')
		local msg, err = parser(line)
		if not msg then
			print(err, line)
		else
			local ret, err = handle_msg(msg)
			if not ret then
				print(err, line)
			end
		end
	end
end


assert(handler(msg))
