local vp = dofile("init.lua")
local o = "testout/test.lua"

local s = vp.translate_venus("test.venus")
local f = io.open(o,"w")
f:write(s)
f:close()

dofile(o)
