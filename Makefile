.PHONY: clean binary-sbcl binary install

PREFIX?=/usr/local
lisps := $(shell find .  -type f \( -iname \*.asd -o -iname \*.lisp \))

all: binary

# Clean -----------------------------------------------------------------------
clean:
	rm -rf bin

# Build -----------------------------------------------------------------------
bin:
	mkdir -p bin

binary-sbcl: bin $(lisps)
	sbcl --noinform \
		--load "build/info.lisp" \
		--load "build/setup.lisp" \
		--load "build/build.lisp"

binary-ros: bin $(lisps)
	ros run -- --noinform \
		--load "build/info.lisp" \
		--load "build/setup.lisp" \
		--load "build/build.lisp"

binary: binary-sbcl

# Install ---------------------------------------------------------------------
install:
	cp bin/cg* $(PREFIX)/bin/
