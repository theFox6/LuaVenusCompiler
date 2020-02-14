---
--A module with lots of helpers for the VenusParser.
--
--@module vp_util
local vp_util = {}

---
--Find the first match of a set of patterns within a string.
--
--The pattern, that can be found at the earliest position within the string is used to match.
--If two patterns are at the same position the shorter match is returned.
--
--@function [parent=#vp_util] find_min_match
--@param #string str the string to be searched for the patterns
--@param patterns the pattern or patterns that are searched within the string
--@return the starting and the end position of the match
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

---
--A generator to iterate over a string splitting it wherever matches of a pattern can be found.
--
--A single or multiple patterns are searched within a string.
--If the string starts with a matching sequence the sequence itself is given to the iteration.
--If a matching sequence is found further within the string the sequence before the match is given to the iteration.
--Every sequence given to the iteration is removed from the iterator.
--Like this it will traverse the string splitting it into the matches and non-matches.
--
--@function [parent=#vp_util] optmatch
--@param #string str the string to search for matches
--@param patterns the pattern or patterns to split by
--@return #function the iterator for a loop
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

---
--A function generating a table from an iterator.
--
--@function [parent=#vp_util] gen_table
--@param #function it the iterator to use in a for loop 
--@return #table the table containing the returns of the iterator
function vp_util.gen_table(it)
  local tab = {}
  for el in it do
    table.insert(tab,el)
  end
  return tab
end

---
--double flat table compare  
--A function comparing the contents of two tables.
--
--It iterates over both tables checking if the other contains the same elements.
--
--@function [parent=#vp_util] dftc
--@param #table t1 the table to compare with t2
--@param #table t2 the table to compare with t1
--@return #boolean whether the tables contents are the same
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

---
--The unit tests for the vp utilities.
local function tests()
  assert(vp_util.dftc({},{}))
  assert(vp_util.dftc({1},{1}))
  assert(not vp_util.dftc({1},{2}))
  assert(vp_util.dftc({1,"2",true},{1,"2",true}))
  assert(not vp_util.dftc({true,"1",1},{1,1,1}))
  
  assert(vp_util.dftc(vp_util.gen_table(vp_util.optmatch("123","123")),{"123"}))
  assert(vp_util.dftc(vp_util.gen_table(vp_util.optmatch("123","321")),{"123"}))
  assert(vp_util.dftc(vp_util.gen_table(vp_util.optmatch("123", "1")), {"1","23"}))
  assert(vp_util.dftc(vp_util.gen_table(vp_util.optmatch("123", "2")), {"1","2","3"}))
end

tests()

return vp_util
