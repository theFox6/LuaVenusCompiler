local vp_util = dofile("vp_util.lua")

local parser = {}

local elements = {
  names = "^(%a%w*)$",
  spaces = "(%s+)",
  special = "[%%%(%)%{%}%;%,]",
  strings = "[\"']",
  special_combined = "([%+%-%*/%^#=~<>%[%]:%.][%+%-/#=>%[%]:%.]?[%.]?)",
  lambda_args = "[,%(%)]"
}

local non_space_elements = {elements.special_combined,elements.special,elements.strings}

function parser.warn(msg)
  print("VenusParser warning: " .. msg)
end

--TODO: make some functions handling each group of commands
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
  
  if pc.deccheck then
    local cpos = pc.deccheck
    pc.deccheck = false
    pc.optassign = false
    if cpos == true then
      pc.slcomm = true
      return "--"..el
    else
      pc.slcomm = true
      return "--"..cpos..el
    end
  end
  
  if el == "=>" then
    if not pc.lambargs then
      parser.warn(("invalid lambda in line %i"):format(pc.line))
      return el
    end
    local larg = pc.lambargs
    pc.lambargs = false
    pc.lambend = false
    pc.precurly = "function"
    pc.curlyopt = true
    return "function" .. larg .. " "
  elseif pc.lambend then
    if prefix then
      parser.warn(("end statement and lambda match end may be mixed in line %i"):format(pc.line))
      prefix = pc.lambargs .. prefix
    else
      prefix = pc.lambargs
    end
    pc.lambargs = false
    pc.lambend = false
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
    return el,prefix
  end

  if pc.foreach == 2 then
    pc.foreach = 3
    if el == "{" then
      table.insert(pc.opencurly, "table")
    end
    return "pairs("..el,prefix
  elseif el == "{" then
    if pc.foreach == 3 then
      pc.foreach = 0
      table.insert(pc.opencurly, "for")
      pc.curlyopt = false
      return ") do",prefix
    elseif not pc.curlyopt then
      table.insert(pc.opencurly, "table")
      return el,prefix
    elseif pc.curlyopt == true then
      if pc.precurly == "function" or pc.precurly == "repeat" or
          pc.precurly == "else" or pc.precurly == "do" then
        table.insert(pc.opencurly, pc.precurly)
        pc.precurly = false
        pc.curlyopt = false
        return "",prefix
      end
    elseif pc.curlyopt == "for" or pc.curlyopt == "while" then
      table.insert(pc.opencurly, pc.curlyopt)
      pc.curlyopt = false
      return " do",prefix
    elseif pc.curlyopt == "if" then
      table.insert(pc.opencurly, pc.curlyopt)
      pc.curlyopt = false
      return " then",prefix
    end
  elseif pc.precurly then
    pc.precurly = false
    pc.curlyopt = false
  end

  if el == "}" then
    local closecurly = table.remove(pc.opencurly)
    if closecurly == "table" then
      return el,prefix
    elseif closecurly == "repeat" then
      return "",prefix
    elseif closecurly == "for" or closecurly == "while" or
        closecurly == "function" or closecurly == "repeat" or
        closecurly == "do" or closecurly == "else" then
      return "end",prefix
    elseif closecurly == "if" then
      pc.ifend = "end"
      return "",prefix
    else
      parser.warn(("closing curly bracket in line %i could not be matched to an opening one"):format(pc.line))
      return el,prefix
    end
  elseif el == "foreach" then
    pc.curlyopt = "for"
    pc.foreach = 1
    return "for _,",prefix
  elseif el == "for" then
    pc.curlyopt = el
    pc.foreach = 0
  elseif el == "in" then
    if pc.foreach == 1 then
      pc.foreach = 2
    end
  elseif el == "do" then
    pc.curlyopt = true
    pc.precurly = "do"
    if pc.foreach == 3 then
      pc.foreach = 0
      return ") " .. el,prefix
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
    return "function",prefix
  elseif el == "function" then
    pc.curlyopt = el
  elseif el == "(" then
    pc.newlamb = el
    pc.lambend = false
    return "",prefix
  elseif el == ")" then
    if pc.curlyopt == "function" then
      pc.precurly = pc.curlyopt
      pc.curlyopt = true
    end
    if pc.lambargs then
      pc.lambend = true
    end
  elseif el == "//" or el=="##" then
    if not pc.instring then
      pc.slcomm = true
      return "--",prefix
    end
  elseif el == "--" then
    if pc.optassign then
      pc.deccheck = true
      return "",prefix
    else
      pc.slcomm = true
      return el,prefix
    end
  elseif el == "++" then
    if pc.optassign then
      local nam = pc.optassign
      pc.optassign = false
      return " = " .. nam .. " + 1"
    else
      parser.warn(("empty increment in line %i"):format(pc.line))
      return el, prefix
    end
  elseif el == "+=" then
    if pc.optassign then
      local nam = pc.optassign
      pc.optassign = false
      return "= " .. nam .. "+"
    else
      parser.warn(("empty increment assignment in line %i"):format(pc.line))
    end
  elseif el == "-=" then
    if pc.optassign then
      local nam = pc.optassign
      pc.optassign = false
      return "= " .. nam .. "-"
    else
      parser.warn(("empty decrement assignment in line %i"):format(pc.line))
    end
  elseif el == "*=" then
    if pc.optassign then
      local nam = pc.optassign
      pc.optassign = false
      return "= " .. nam .. "*"
    else
      parser.warn(("empty multiply assignment in line %i"):format(pc.line))
    end
  elseif el == "/=" then
    if pc.optassign then
      local nam = pc.optassign
      pc.optassign = false
      return "= " .. nam .. "/"
    else
      parser.warn(("empty divide assignment in line %i"):format(pc.line))
    end
  elseif el == "^=" then
    if pc.optassign then
      local nam = pc.optassign
      pc.optassign = false
      return "= " .. nam .. "^"
    else
      parser.warn(("empty power assignment in line %i"):format(pc.line))
    end
  elseif el == ".=" then
    if pc.optassign then
      local nam = pc.optassign
      pc.optassign = false
      return "= " .. nam .. ".."
    else
      parser.warn(("empty concatenation assignment in line %i"):format(pc.line))
    end
  end
  --print(el,pc.instring and "in string" or "")
  return el, prefix
end

--TODO: make functions handling the lambdas
local function parse_line(l,pc)
  local pl = ""
  local i = 0
  for sp,s in vp_util.optmatch(l,elements.spaces) do
    if s then
      if pc.lambargs then
        pc.lambargs = pc.lambargs .. sp
      elseif pc.deccheck then
        if pc.deccheck == true then
          pc.deccheck = sp
        else
          pc.deccheck = pc.deccheck .. sp
        end
      else
        pl = pl .. sp
      end
      if pc.optassign then
        if pc.optassign ~= true then
          pc.optassign = pc.optassign .. sp
        end
      end
    else
      for st in vp_util.optmatch(sp,non_space_elements) do
        if pc.slcomm then
          pl = pl .. st
        else
          local el,pre = parse_element(st,pc)
          local lpre
          if pre then
            while pre:match("\n") do
              if lpre then
                lpre = lpre .. pre:sub(1,pre:find("\n"))
              else
                lpre = pre:sub(1,pre:find("\n"))
              end
              pre = pre:sub(pre:find("\n")+1)
            end
            local pres = pre:match("^%s*") or ""
            if lpre then
              lpre = lpre .. pres
            else
              lpre = pres
            end
            pre = pre:sub(#pres+1)
            --[[
            if (pre ~= "") then
              print("pre:".. pre..":")
            else
              print("prel:" .. el)
            end
            --]]
            if el == "" then
              el = pre
            elseif pre ~= "" then
              el = pre .. " " .. el
            end
          end
          if pc.newlamb then
            if pc.lambargs then
              el = pc.lambargs .. el
            end
            pc.lambargs = pc.newlamb
            pc.newlamb = false
            --print("newl:", pc.lambargs, el)
          elseif pc.lambargs then
            if el:match(elements.names) or el:match(elements.lambda_args) then
              pc.lambargs = pc.lambargs .. el
              el = ""
            elseif el ~= "" then
              el = pc.lambargs .. el
              pc.lambargs = false
              pc.lambend = false
              --print("notl:", el)
            end
          end
          if pc.optassign and el ~= "" then
            if pc.linestart and el:match(elements.names) then
              if pc.optassign == true then
                pc.optassign = el
              else
                pc.optassign = pc.optassign .. el
              end
            elseif el ~= "--" then
              pc.optassign = false
            end
          end
          if lpre then
            pl = pl .. lpre .. el
          else
            pl = pl .. el
          end
          if pc.linestart and el ~= "" then
            pc.linestart = false
          end
        end
      end
    end
  end
  return pl
end

local function handle_linestart(pc)
  pc.line = pc.line + 1
  pc.linestart = true
  pc.optassign = true
end

local function handle_lineend_curly(pc)
  if pc.ifend then
    local ret
    if pc.linestart then
      ret = pc.ifend
    else
      ret = " " .. pc.ifend
    end
    pc.ifend = false
    return ret
  end
  return ""
end

local function handle_lineend_decrement(pc)
  if pc.deccheck then
    if pc.optassign == false then
      pc.deccheck = false
    elseif pc.optassign == true then
      pc.deccheck = false
    else
      local ret = " = " .. pc.optassign .. " - 1"
      pc.deccheck = false
      pc.optassign = false
      return ret
    end
  end
  return ""
end

local function handle_lineend_lambargs(pc)
  if pc.lambargs then
    pc.lambargs = pc.lambargs .. "\n"
  else
    return "\n"
  end
  return ""
end

function parser.tl_venus_string(str)
  local fc = ""
  local pc = {instring = false, opencurly = {}, line = 0}
  for l,e in vp_util.optmatch(str,"\n") do
    if e then
      if pc.slcomm then
        pc.slcomm = false
        fc = fc .. "\n"
      else
        fc = fc .. handle_lineend_curly(pc)
        fc = fc .. handle_lineend_decrement(pc)
        fc = fc .. handle_lineend_lambargs(pc)
      end
    else
      handle_linestart(pc)
      fc = fc .. parse_line(l,pc)
    end
  end
  if (#pc.opencurly > 0) then
    parser.warn("not all curly brackets were closed")
  end
  return fc
end

function parser.tl_venus_file(file)
  local f = io.open(file)
  local ret = parser.tl_venus_string(f:read("*a"))
  f:close()
  return ret
end

function parser.loadvenus(file,env)
  local fc = parser.tl_venus_file(file)
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

function parser.convert_venus_file(venus_file_in,lua_file_out)
  local s = parser.tl_venus_file(venus_file_in)
  local f = io.open(lua_file_out,"w")
  f:write(s)
  f:close()
end

return parser
