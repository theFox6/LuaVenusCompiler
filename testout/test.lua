print("running venus test script")

local vp_util = dofile("vp_util.lua")

local function for_range_test()
	local a = 0

	for i = 0,5 do
		a = a + i
	end

	assert(a == 15)
end

for_range_test()

local function for_in_test()
	local testt = {
		venus = "awesome",
		"lots of test",1,2,
		test2 = "hi"
	}

	local reft = {}
	for i,el in pairs(testt)  do
		reft[i] = el
	end
	assert(vp_util.dftc(reft, testt) )

	reft = {}
	for _,el in pairs(testt)  do
		table.insert(reft,el)
	end

	local reft2 = {}
	for _, el in pairs(testt ) do
		table.insert(reft2,el)
	end
	assert(vp_util.dftc(reft, reft2) )
end

for_in_test()

-- comments
-- yay a comment
--comment
assert("//"=="/".."/")
-- another comment
assert([[
##]]=="#".."#","comment within [[string]] falsely detected")

assert([[
fn]]=="f".."n")

local function shadow_test()
	local function a()
		return "function"
	end
	assert(a() =="function")

	local reft = {}
	do
		(function(...)
			local a = {...}
			for _, a in pairs(a ) do
				table.insert(reft,a)
			end
		end)("a","still a","also a")
	end
	assert(vp_util.dftc(reft, {"a","still a","also a"}))

	local n
	do 
		local a = 12
		n = a
	end
	assert(n == 12)

	assert(a() =="function")
end

shadow_test()

local function t() 
	return "hi"
end
assert(t() =="hi")

local function t2() 
	return "also hi"
end
assert(type(t2) =="function")
assert(t2() =="also hi")

local b = true
if (true)   then
	b = "weewoo"
 end
assert(b == "weewoo")

local reft = {}
for i = 0, 10  do
	table.insert(reft,i)
end
assert(vp_util.dftc(reft,{0,1,2,3,4,5,6,7,8,9,10}))

local reft2 = {}
for _, el in pairs({"lot's of test",2,"3",1} ) do
	table.insert(reft2,el)
end
assert(vp_util.dftc(reft2,{"lot's of test",2,"3",1}))

do 
	local reft = {}
	local i = 0
	while i < 10  do
		i = i + 1
		if i%3 == 0  then
			table.insert(reft,i)
		 elseif i%4 == 0  then
			table.insert(reft,i/4)
		 end
	end
	assert(vp_util.dftc(reft,{3,1,6,2,9}))
end

local function callit(fun,t1,t2)
	return fun(t1,t2)
end

assert(
	callit(function()   
		return "testing"
	end)
	== "testing")

assert(
	callit(function(k,v)   
		return k.." = "..v
	end, "this test", "more test")
	== "this test = more test"
)
	
assert(
	callit(function(a , b)   
		return (a-b)*4
	end, 10, 6) == 16
)

assert(callit(function() end,false)==nil)

---
--comment


local i = 0
local j = 0

i = i + 1
j = j + 2

local function decj()
	j = j - 1
	return j-- not a decrement, only returns n, this is a comment
end
assert(decj() ==1)
assert(j == 1)

local function reti()
	-- this only returns i the -- is a comment
	return i--
end

i = i + 1
assert(reti()  == 2)

-- () => {}

j= j+ 3
assert(j == 4)
j = j *-8
assert(j ==-32)
j = j / -4
assert(j== 8)
j = j ^ 2
assert(j == 64)
j= j- 32
assert(j ==32)
j = j .." test"
assert(j == "32 test")

print("venus test end")
