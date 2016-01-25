# tdb
[Tarantool](https://github.com/tarantool/tarantool) database interactive debugger. Compatible with: 
* 1.6.7
* 1.6.8
* 1.7.x


### Features:
* Code navigation
* Locals and globals watch
* Working with tarantool fibers
* Eval lua code in current execution context
* Backtrace info

### Install
```
git clone https://github.com/Sulverus/tdb
cd tdb
make
sudo make install prefix=/usr/share/tarantool/
```

### Usage
Anywhere in lua code you can set a brakepoint
```lua
require('tdb').start()
```

**Commands:**

* **n** - next line
* **c** - continue
* **bt** - traceback
* **locals** - get local context
* **globals** - get global scope
* **e** - enter to eval mode
* **-e** - return to default mode
* **f** - fiber info
* **q** - exit
* **h** - help

**Eval mode**

In eval mode you can run lua code in current execution context
```
(TDB) 7: local i = 0
(TDB)>
(TDB) 8: while true do
(TDB)>
(TDB) 9: i = i + 1
(TDB)>
(TDB) 10: fiber.sleep(0.5)
(TDB)>
(TDB) 8: while true do
(TDB)>e
(TDB) Eval mode ON
(TDB)>return i * 2
2
(TDB)>
```


### How it works
Example for `test/test.lua` interactive debugging
```
$ tarantool test.lua 
(TDB) Tarantool debugger v.0.0.3. Type h for help
(TDB) [/home/Sulverus/tdb/test/test.lua]
(TDB) 14: local a = 1
(TDB)>
(TDB) 15: local b = 2
(TDB)>
(TDB) 18: local t = {x=1, y=2}
(TDB)>
(TDB) 21: c = a + b
(TDB)>
(TDB) 22: print(c)
(TDB)>locals
b       2
(*temporary)    line
t       table: 0x0f316b68
a       1
(TDB)>
3
(TDB) 25: print(f(c))
(TDB)>
9
(TDB) 28: local sum = 0
(TDB)>
(TDB) 29: for i=1,3 do
(TDB)>
(TDB) 30: sum = sum + i
(TDB)>
(TDB) 29: for i=1,3 do
(TDB)>locals
t       table: 0x0f316b68
(for step)      1
(for limit)     3
b       2
sum     1
(*temporary)    1
(for index)     1
a       1
(TDB)>e
(TDB) Eval mode ON
(TDB)>a
a       1
(TDB)>b
b       2
(TDB)>c
c       3
(TDB)>sum
sum     1
(TDB)>t
table: 0x0f316b68:
y       2
x       1
(TDB)>print(a+b+c)                  
6

(TDB)>-e
(TDB) Eval mode OFF
(TDB)>c
(TDB) 30: sum = sum + i
(TDB) 29: for i=1,3 do
(TDB) 30: sum = sum + i
(TDB) 29: for i=1,3 do
(TDB) 32: print(sum)
6
(TDB) 33: os.exit(0)

```
