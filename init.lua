local parser = {}

local elements = {
  names = "(%a%w+)",
  spaces = "(%s+)",
  special = "[%%%(%)%{%}%;%,]",
  strings = "[\"']",
  special_combined = "([%+%-%*/%^#=~<>%[%]:%.][%+%-/#=%[%]:%.]?[%.]?)",
}

function parser.warn(msg)
  print("VenusParser warning: " .. msg)
end

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
  if el == "" then
    return el
  end
  local prefix
  if el == "elseif" then
    if pc.ifend then
      pc.ifend = false
    end
    pc.curlyopt = "if"
  elseif el == "else" then
    pc.ifend = false
    pc.curlyopt = true
    pc.precurly = el
  elseif pc.ifend then
    prefix = pc.ifend
    pc.ifend = false
  end
  
  if el == '"' or el == "'" then
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
  elseif pc.instring then
    return el
  end

  if pc.foreach == 2 then
    pc.foreach = 3
    if el == "{" then
      table.insert(pc.opencurly, "table")
    end
    return "pairs("..el
  elseif el == "{" then
    if pc.foreach == 3 then
      pc.foreach = 0
      table.insert(pc.opencurly, "for")
      pc.curlyopt = false
      return ") do"
    elseif not pc.curlyopt then
      if pc.linestart then
        table.insert(pc.opencurly, "do")
        return "do "
      else
        table.insert(pc.opencurly, "table")
        return el
      end
    elseif pc.curlyopt == true then
      if pc.precurly == "function" or pc.precurly == "repeat" or pc.precurly == "else" then
        table.insert(pc.opencurly, pc.precurly)
        pc.precurly = false
        pc.curlyopt = false
        return ""
      end
    elseif pc.curlyopt == "for" or pc.curlyopt == "while" then
      table.insert(pc.opencurly, pc.curlyopt)
      pc.curlyopt = false
      return " do"
    elseif pc.curlyopt == "if" then
      table.insert(pc.opencurly, pc.curlyopt)
      pc.curlyopt = false
      return " then"
    end
  elseif pc.precurly then
    pc.precurly = false
    pc.curlyopt = false
  end

  if el == "}" then
    local closecurly = table.remove(pc.opencurly)
    if closecurly == "table" then
      return el
    elseif closecurly == "repeat" then
      return "" -- until will follow
    elseif closecurly == "for" or closecurly == "while" or
        closecurly == "function" or closecurly == "repeat" or
        closecurly == "do" or closecurly == "else" then
      return "end"
    elseif closecurly == "if" then
      pc.ifend = "end"
      return ""
    else
      parser.warn(("closing curly bracket in line %i could not be matched to an opening one"):format(pc.line))
      return el
    end
  elseif el == "foreach" then
    pc.curlyopt = "for"
    pc.foreach = 1
    return "for _,"
  elseif el == "for" then
    pc.curlyopt = el
    pc.foreach = 0
  elseif el == "in" then
    if pc.foreach == 1 then
      pc.foreach = 2
    end
  elseif el == "do" then
    pc.curlyopt = false
    if pc.foreach == 3 then
      pc.foreach = 0
      return ") " .. el
    end
  elseif el == "while" then
    pc.curlyopt = el
  elseif el == "repeat" then
    pc.precurly = el
    pc.curlyopt = true
  elseif el == "if" then
    pc.curlyopt = el
  elseif el == "then" then
    pc.curlyopt = false
  elseif el == "fn" then
    pc.curlyopt = "function"
    return "function"
  elseif el == "function" then
    pc.curlyopt = el
  elseif el == ")" then
    if pc.curlyopt == "function" then
      pc.precurly = pc.curlyopt
      pc.curlyopt = true
    end
  elseif el == "//" or el=="##" then
    if not pc.instring then
      return "--"
    end
  end
  --print(el,pc.instring and "in string" or "")
  return el, prefix
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
        local el, pre = parse_element(st,pc)
        if pre then
          pl = pl .. pre
          if el ~= "" then
            pl = pl .. " " .. el
          end
        else
          pl = pl .. el
        end
        if pc.linestart then
          pc.linestart = false
        end
      end
      end
      end
    end
  end
  return pl
end

function parser.translate_venus(file)
  local fc = ""
  local pc = {instring == false, opencurly = {}, line = 0}
  for l in io.lines(file) do
    pc.line = pc.line + 1
    pc.linestart = true
    fc = fc .. parse_line(l,pc)
    if pc.ifend then
      if pc.linestart then
        fc = fc .. pc.ifend
      else
        fc = fc .. " " .. pc.ifend
      end
      pc.ifend = false
    end
    fc = fc .. "\n"
  end
  if (#pc.opencurly > 0) then
    parser.warn("not all curly brackets were closed")
  end
  return fc
end

function parser.loadvenus(file,env)
  local fc = parser.translate_venus(file)
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
