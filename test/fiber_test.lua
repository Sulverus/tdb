tdb = require('tdb')
tdb.start()


fiber = require('fiber')
function f()
  local i = 0
  while true do
    i = i + 1
    fiber.sleep(0.5)
  end
end

fiber.create(f)

local a = 1
local b = 2
local t = {x=1, y=2}
c = a + b
print(c)

local sum = 0
for i=1,3 do
    sum = sum + i
end
print(sum)

os.exit(0)
