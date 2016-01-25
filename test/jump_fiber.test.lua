fiber = require('fiber')
function f()
  -- check that tdb created in fiber
  -- do not jumps into the others fibers or main
  require('tdb').start()
  fiber.name('f1(inspected)')
  local i = 0
  while true do
    i = i + 1
    fiber.sleep(0.5)
  end
end
function f2()
  fiber.name('f2')
  local j = 0
  while true do
    j = j + 1
    fiber.sleep(0.1)
  end
end

fiber.create(f2)
fiber.create(f)

while true do
    fiber.sleep(0.1)
end

os.exit(0)
