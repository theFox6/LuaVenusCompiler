# venus lua parser
A parser that loads venus files into lua. Written in lua.  
The parser reads the lua file replaces venus syntax by lua syntax and loads the result.

## features
### foreach
The `foreach` statement will geneate a `pairs` statement.

```lua
local table = {2,1,3,"test"}

foreach el in table do
  print(el)
end
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

## todo
- curly braces
- increment, decrement, etc.
- fn and lambdas
- eventually be able to produce lua files

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
