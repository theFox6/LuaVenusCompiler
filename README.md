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
for comments --, // and ## can be used
if something follows a -- it will always be treated as comment

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
`vp.translate_venus(file)` returns the lua generated from the files contents  
It's argument can be a relative or absolute path to the file that should be translated.  
It returns the generated lua as string.

##todo
- lambdas
- increment, decrement, etc.
- generate lua from a venus string
- perhaps write generated lua files to disk
