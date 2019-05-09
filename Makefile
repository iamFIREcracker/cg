.PHONY: vendor clean binary-sbcl binary

all: binary

# Clean -----------------------------------------------------------------------
clean:
	rm -rf bin

# Build -----------------------------------------------------------------------
lisps := $(shell find .  -type f \( -iname \*.asd -o -iname \*.lisp \))

bin:
	mkdir -p bin

binary-sbcl: bin
	sbcl --noinform --load "src/build.lisp"

binary: binary-sbcl

bin/cg: $(lisps) Makefile
	make binary-sbcl
