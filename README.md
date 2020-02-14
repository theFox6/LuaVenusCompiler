# venus lua parser
A parser that loads venus files into lua. Written in lua.  
The parser reads a venus file and replaces venus syntax by lua syntax.  
It can also load and run the result.

## features
### foreach
The `foreach` statement will geneate a `pairs` statement.

```lua
local table = {2,1,3,"test"}

foreach el in table {
  print(el)
}
```
will generate
```lua
local table = {2,1,3,"test"}

for _, el in table do
  print(el)
end
```

### comments
for comments `--`, `//` and `##` can be used
if something follows a `--` it will always be treated as comment

### curly braces
The `do`,`then` and `end` statements can be replaced by curly brace syntax.  
They can be used in functions, loops, conditions.  
For example:
```lua
local table = {2,1,3,"test","test2",3}

function findTest(t) {
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
```
will generate
```lua
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
```

### functions
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

### lambdas
Lambda syntax `(args) => {...}` can be used to create functions.
```lua
local result
fn store_it(f) {
	result = f(10,6)
}

store_it((a,b) => {
	return (a - b) * 2
})
```
will generate
```lua
local result
function store_it(f)
	result = f(10,6)
end

store_it(function(a,b)
	return (a - b) * 2
end)
```

### incrrement and decrement
`++` and `--` can be used to in/decrement by 1
```lua
local i = 0
local j = 0

i++
j--
```
will generate
```lua
local i = 0
local j = 0

i = i + 1
j = j - 1
```
`--` can also be a comment!  
If there is anything behind a `--` the `--` treated as comment.

### assignments
Assignment operators `+=`, `-=`, `*=`, `/=`, `^=` and `.=` can be used.
```lua
local a = 0
-- increment
a += 2
-- decrement
a -= 1
-- multiply
a *= 8
-- divide
a /= 2
-- to the power of
a ^= 3
-- concatenate string
a .= " str"
```
will generate
```lua
local a = 0
-- increment
a = a + 2
-- decrement
a = a - 1
-- multiply
a = a * 8
-- divide
a = a / 2
-- to the power of
a = a ^ 3
-- concatenate string
a = a .. " str"
```

## working with the parser
### loading
The init.lua returns a table containing the parser.  
In case you have the VenusParser directory within your project's  
ways of loding it may be:
```lua
-- using require (cached)
local vc = require("VenusParser")
-- using dofile
local vc = dofile("VenusParser/init.lua")
```

### running venus files
`vc.dovenus(file)` works like `dofile(file)`  
It's argument can be a relative or absolute path to the file that should be run.

### loading venus files
`vc.loadvenus(file)` works like `loadfile(file)`  
It's argument can be a relative or absolute path to the file that should be loaded.  
It returns a function that runs the generated lua.

### generating lua code
`vp.tl_venus_file(file)` returns the lua generated from the files contents  
It's argument can be a relative or absolute path to the file that should be translated.  
It returns the generated lua as string.

`vp.tl_venus_string(str)` returns the lua generated from the given string  
It returns the generated lua as string.

### generating lua files
`vp.convert_venus_file(venus_file_in,lua_file_out)` generates a lua file  
It's arguments can be relative or absolute paths.  
The venus_file_in will be converted to lua and written to lua_file_out.
