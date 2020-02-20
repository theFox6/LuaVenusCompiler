if VenusParser then
  print("VenusParser warning: already initialized")
else
  VenusParser = {}
end

function VenusParser.loadFromPath(path)
  VenusParser.path = path
  local ret = dofile(path.."VenusParser.lua")
  for i,v in pairs(ret) do
    VenusParser[i] = v
  end
  return ret
end

return VenusParser.loadFromPath
