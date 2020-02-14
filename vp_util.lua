local vp_util = {}

--TODO: documentation

function vp_util.find_min_match(str,patterns)
  local pats
  local patt = type(patterns)
  if patt == "string" then
    pats = {patterns}
  elseif patt == "table" then
    pats = patterns
  else
    error(("bad argument #2 to optmatch, expected string or table got %s"):format(patterns),2)
  end
  local minspos
  local matchepos
  for _, pat in pairs(pats) do
    local spos,epos = str:find(pat)
    if spos then
      if not minspos then
        minspos = spos
        matchepos = epos
      elseif spos < minspos then
        minspos = spos
        matchepos = epos
      elseif spos == minspos then
        if epos < matchepos then
          minspos = spos
          matchepos = epos
        end
      end
    end
  end
  return minspos, matchepos
end

function vp_util.optmatch(str,patterns)
  local cutstr = str
  return function()
    if not cutstr then return end
    local spos, epos = vp_util.find_min_match(cutstr,patterns)
    local match
    local found = (spos == 1)
    if found then
      match =  cutstr:sub(1,epos)
      cutstr = cutstr:sub(epos+1)
      --print("f",match,cutstr,pat)
    elseif not spos then
      if cutstr == "" then
        match = nil
      else
        match = cutstr
      end
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

function vp_util.gen1_table(gen,...)
  local tab = {}
  for el in gen(...) do
    table.insert(tab,el)
  end
  return tab
end

-- double_flat_table_compare
function vp_util.dftc(t1,t2)
  for i,el in pairs(t1) do
    if t2[i] ~= el then
      return false
    end
  end
  for i,el in pairs(t2) do
    if t1[i] ~= el then
      return false
    end
  end
  return true
end

local function tests()
  assert(vp_util.dftc({},{}))
  assert(vp_util.dftc({1},{1}))
  assert(not vp_util.dftc({1},{2}))
  assert(vp_util.dftc({1,"2",true},{1,"2",true}))
  assert(not vp_util.dftc({true,"1",1},{1,1,1}))
  
  assert(vp_util.dftc(vp_util.gen1_table(vp_util.optmatch,"123","123"),{"123"}))
  assert(vp_util.dftc(vp_util.gen1_table(vp_util.optmatch,"123","321"),{"123"}))
  assert(vp_util.dftc(vp_util.gen1_table(vp_util.optmatch,"123", "1"), {"1","23"}))
  assert(vp_util.dftc(vp_util.gen1_table(vp_util.optmatch,"123", "2"), {"1","2","3"}))
end

tests()

return vp_util
