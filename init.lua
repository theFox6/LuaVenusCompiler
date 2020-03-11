if rawget(_G,"LuaVenusCompiler") then
  print("LuaVenusCompiler warning: already initialized")
else
  LuaVenusCompiler = {}
end

function LuaVenusCompiler.loadFromPath(path)
  LuaVenusCompiler.path = path
  local ret = dofile(path.."LuaVenusCompiler.lua")
  for i,v in pairs(ret) do
    LuaVenusCompiler[i] = v
  end
  return ret
end

return LuaVenusCompiler.loadFromPath
