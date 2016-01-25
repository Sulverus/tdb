local tst = 1

print(debug.getlocal(1,1))

tdb = require('tdb')
tdb.start()

-- function def
function f(x)
    return x*x
end

-- locals
local a = 1
local b = 2

-- tables
local t = {x=1, y=2}

-- globals
c = a + b
print(c)

-- func call
print(f(c))

-- flow controls
local sum = 0
for i=1,3 do
    sum = sum + i
end
print(sum)
os.exit(0)
