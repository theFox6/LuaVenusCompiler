local vp = dofile("init.lua")
local o = "testout/test.lua"

vp.convert_venus_file("test.venus",o)

dofile(o)
