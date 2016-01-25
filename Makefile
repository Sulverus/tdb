all:
	mkdir -p build
	cp src/*.lua build
	cp ansicolors/ansicolors.lua build

install:
	cp build/*.lua $(prefix)/


clean:
	rm -rf build
