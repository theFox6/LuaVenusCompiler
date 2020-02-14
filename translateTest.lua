local vp = dofile("init.lua")
local o = "testout/test.lua"

local s = vp.tl_venus_file("test.venus")
local f = io.open(o,"w")
f:write(s)
f:close()

dofile(o)
