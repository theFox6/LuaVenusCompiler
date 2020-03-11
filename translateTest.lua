local vc = dofile("init.lua")("")
local o = "testout/test.lua"

vc.convert_venus_file("test.venus",o)

dofile(o)
