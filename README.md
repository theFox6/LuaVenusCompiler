# LuaVenusCompiler
[![luacheck][luacheck badge]][luacheck workflow]  
A compiler that translates Venus files into Lua. Written in Lua.  
The compiler reads a Venus file and replaces Venus syntax by Lua syntax.  
It can also load and run the result.

## Features:
### "foreach" loop
The `foreach` statement will geneate a `pairs` statement.
```lua
local table = {2,1,3,"test"}

foreach el in table {
  print(el)
}
```
will generate:
```lua
local table = {2,1,3,"test"}

for _, el in table do
  print(el)
end
```

### Comments
For comments `--` and `##` can be used
If something follows a `--` it will always be treated as comment


### Functions
`fn` can be used instead of `function`.
```lua
fn test() {
	print("hi")
}
```
will generate
```lua
function test()
	print("hi")
end
```

### Curly braces based syntax
The `do`,`then` and `end` statements can be replaced by curly braces syntax.  
They can be used in functions, loops, conditions, etcetera.  
For example:
```lua
do {
	local table = {2,1,3,"test","test2",3}

	fn findTest(t) {
		repeat {
			local found = false
			local el = table.remove(t)
			if el == "test" {
				found = true
			} else {
				print(el)
			}
		} until found
	}
}
```
will generate:
```lua
do
	local table = {2,1,3,"test","test2",3}

	function findTest(t) 
		repeat
			local found = false
			local el = table.remove(t)
			if el == "test" then
				found = true
			else
				print(el)
			end
		until found
	end
end
```

### Lambdas / Anonymous functions
Lambda syntax `(args) => {...}` can be used to create anonymous functions.
```lua
local result
fn store_it(f) {
	result = f(10,6)
}

store_it((a,b) => {
	return (a - b) * 2
})
```
will generate:
```lua
local result
function store_it(f)
	result = f(10,6)
end

store_it(function(a,b)
	return (a - b) * 2
end)
```

### Increment and Decrement
`++` and `--` can be used to add/sub by 1
```lua
local i = 0
local j = 0

i++
j--
```
will generate:
```lua
local i = 0
local j = 0

i = i + 1
j = j - 1
```

### assignments
Assignment operators `+=`, `-=`, `*=`, `/=`, `^=` and `.=` can be used for math on variables.
```lua
local a = 0
-- Increased by
a += 2
## Decreased by
a -= 1
## Multiplied by
a *= 8
-- Divided by
a /= 2
-- Powered by
a ^= 3
## Concatenate string
a .= " str"
```
will generate
```lua
local a = 0
-- Increased by
a = a + 2
-- Decreased by
a = a - 1
-- Multiplied by
a = a * 8
-- Divided by
a = a / 2
-- Powered by
a = a ^ 3
-- Concatenate string
a = a .. " str"
```

## Working with the compiler
### Loading 
The init.lua returns a function for loading the compiler.  
You have to call it with the path to the script itself as argument.  
In case you have the LuaVenusCompiler directory within your project's  
ways of loding it may be:
```lua
--in case your project is run within it's own folder
local vc = dofile("LuaVenusCompiler/init.lua")("LuaVenusCompiler/")
--in case you have a variable called project_loc containing the path to your projects folder
local vc = dofile(project_loc.."/LuaVenusCompiler/init.lua")(project_loc.."/LuaVenusCompiler/")
--using require
local vc = require("LuaVenusCompiler")("LuaVenusCompiler/")
```
When it is loaded it can also be accessed with the global called "LuaVenusCompiler".

### Running Venus files
`vc.dovenus(file)` works like `dofile(file)`  
It's argument can be a relative or absolute path to the file that should be run.

### Loading Venus files
`vc.loadvenus(file)` works like `loadfile(file)`  
It's argument can be a relative or absolute path to the file that should be loaded.  
It returns a function that runs the generated lua.

### Generating Lua code
`vc.tl_venus_file(file)` returns the lua generated from the files contents  
It's argument can be a relative or absolute path to the file that should be translated.  
It returns the generated lua as string.

`vc.tl_venus_string(str)` returns the lua generated from the given string  
It returns the generated lua as string.

### Generating Lua files
`vc.convert_venus_file(venus_file_in,lua_file_out)` generates a lua file  
It's arguments can be relative or absolute paths.  
The venus_file_in will be converted to lua and written to lua_file_out.

[luacheck badge]: https://github.com/theFox6/LuaVenusCompiler/workflows/luacheck/badge.svg
[luacheck workflow]: https://github.com/theFox6/LuaVenusCompiler/actions?query=workflow%3Aluacheck
