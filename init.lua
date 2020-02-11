local parser = {}

local elements = "(%s*%g+)"

local function parse_element(el,pc)
  local space = el:match("%s*")
  local word = el:sub(#space+1)
  if pc.foreach == 2 then
    pc.foreach = 3
    return space.."pairs("..word
  end
  if word == "foreach" then
    pc.foreach = 1
    return space .. "for"
  elseif word == "for" then
    pc.foreach = 0
  elseif word == "in" then
    if pc.foreach == 1 then
      pc.foreach = 2
    end
  elseif word == "do" then
    if pc.foreach == 3 then
      return ")" .. el
    end
  end
  --print(el)
  return el
end

local function parse_line(l,pc)
  local pl = ""
  for w in l:gmatch(elements) do
    pl = pl .. parse_element(w,pc)
  end
  return pl
end

function parser.loadvenus(file)
  local fc = ""
  local pc = {opencurly = {}}
  for l in io.lines(file) do
    fc = fc .. parse_line(l,pc) .. "\n"
  end
  return loadstring(fc,"@"..file)
end

function parser.dovenus(file)
  local ff, err = parser.loadvenus(file)
  if ff == nil then
    error(err,2)
  end
  return ff()
end

return parser
