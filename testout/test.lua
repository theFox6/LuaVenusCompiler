print("venus test")

local testt = {
	venus = "awesome",
	"lots of test",1,2,
	test2 = "hi"
}

for i = 0,5 do
	print(i)
end

for i,el in pairs(testt) do
	print(i.." = "..el)
end

for _, el in pairs(testt ) do
	print(el)
end

-- comment
-- comment
--comment
assert("//"=="/".."/")
-- comment
assert([[
##]]=="#".."#","comment within [[string]] falsely detected")

function a()
	return "function"
end

assert(a()=="function")
assert([[
fn]]=="f".."n")

do
	(function(...)
		local a = {...}
		for _, a in pairs(a ) do
			print(a)
		end
	end)("a","still a","also a")
end

do 
	local a = 12
	print(a)
end
a()

function t() 
	return "hi"
end
assert(t()=="hi")

function t2() 
	return "also hi"
end
assert(t2()=="also hi")

if (true)  then
	print("weewoo")
 end

for i = 0, 10  do
	print(i)
end

for _, el in pairs({"lot's of test",2,"3",1} ) do
	print(el)
end

do 
	local i = 0
	while i < 10  do
		i = i + 1
		if i%3 == 0  then
			print(i)
		 elseif i%4 == 0  then
			print(i/4)
		 end
	end
end

print("test end")

--[[ coming soon
function callit(fun,arg)
	fun(arg)
end

callit(() => {
	print("testing")
})

callit((t) => {
	print(t)
}, "more test")

local i = 0
local j = 0

i = i + 1
j = j + 2
i++
j += 2

function dec(n)
	n--
	return n-- not a decrement, only returns n, this is a comment
end
--]]
