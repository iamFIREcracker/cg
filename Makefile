.PHONY: vendor clean binary-sbcl binary

lisps := $(shell find .  -type f \( -iname \*.asd -o -iname \*.lisp \))

all: binary

# Clean -----------------------------------------------------------------------
clean:
	rm -rf bin

# Build -----------------------------------------------------------------------
bin:
	mkdir -p bin

binary-sbcl: bin $(lisps)
	sbcl --noinform --load "src/build.lisp"

binary-ros: bin $(lisps)
	ros run -- --noinform --load "src/build.lisp"

binary: binary-sbcl
