local parser = {}

local elements = {
  names = "(%a%w+)",
  spaces = "(%s+)",
  special = "[%%%(%)%{%}%;%,]",
  strings = "[\"']",
  special_combined = "([%+%-%*/%^#=~<>%[%]%:.][%+%-/#=%[%]:%.]?[%.]?)",
}

--FIXME: allow multiple paterns
local function optmatch(str,pat)
  local cutstr = str
  return function()
    if not cutstr then return end
    local spos,epos = cutstr:find(pat)
    local match
    local found = (spos == 1)
    if found then
      match =  cutstr:sub(spos,epos)
      cutstr = cutstr:sub(epos+1)
      --print("f",match,cutstr,pat)
    elseif not spos then
      match = cutstr
      cutstr = nil
      --print("n",match,pat)
    else
      match = cutstr:sub(1,spos-1)
      cutstr = cutstr:sub(spos)
      --print("p",match,cutstr,pat)
    end
    return match, found
  end
end

function parser.test_optmatch()
  assert(optmatch("123","123")() == "123")
  assert(optmatch("123","321")() == "123")
  assert(optmatch("123","1")() == "1")
  assert(optmatch("123","2")() == "1")
end

local function parse_element(el,pc)
  if pc.foreach == 2 then
    pc.foreach = 3
    return "pairs("..el
  end
  if el == "foreach" then
    pc.foreach = 1
    return "for _,"
  elseif el == "for" then
    pc.foreach = 0
  elseif el == "in" then
    if pc.foreach == 1 then
      pc.foreach = 2
    end
  elseif el == "do" then
    if pc.foreach == 3 then
      return ")" .. el
    end
  elseif el == '"' or el == "'" then
    if not pc.instring then
      pc.instring = el
    elseif pc.instring == el then
      pc.instring = false
    end
  elseif el == "[[" then
    if not pc.instring then
      pc.instring = el
    end
  elseif el == "]]" then
    if pc.instring == "[[" then
      pc.instring = false
    end
  elseif el == "//" or el=="##" then
    if not pc.instring then
      return "--"
    end
  end
  --print(el,pc.instring and "in string" or "")
  return el
end

local function parse_line(l,pc)
  local pl = ""
  local i = 0
  for sp,s in optmatch(l,elements.spaces) do
    if s then
      pl = pl .. sp
    else
      for sc in optmatch(sp,elements.special_combined) do
      for ss in optmatch(sc,elements.special) do
      for st in optmatch(ss,elements.strings) do
        pl = pl .. parse_element(st,pc)
      end
      end
      end
    end
  end
  return pl
end

function parser.loadvenus(file,env)
  local fc = ""
  local pc = {instring == false, opencurly = {}}
  for l in io.lines(file) do
    fc = fc .. parse_line(l,pc) .. "\n"
  end
  if env then
    return loadstring(fc,"@"..file,"t",env)
  else
    return loadstring(fc,"@"..file)
  end
end

function parser.dovenus(file)
  local ff, err = parser.loadvenus(file)
  if ff == nil then
    error(err,2)
  end
  return ff()
end

-- in case anybody wants to use it too
parser.optmatch = optmatch

return parser
