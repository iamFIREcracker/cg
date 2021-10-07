.PHONY: clean binary binary-ros binary-sbcl install lisp-info lisp-info-ros

PREFIX?=/usr/local
lisps := $(shell find .  -type f \( -iname \*.asd -o -iname \*.lisp \))

all: binary

# Clean -----------------------------------------------------------------------
clean:
	rm -rf bin

# Build -----------------------------------------------------------------------
bin:
	mkdir -p bin

lisp-info:
	sbcl --noinform --quit \
		--load "build/info.lisp"

binary-sbcl: lisp-info bin $(lisps)
	sbcl --noinform \
		--load "build/setup.lisp" \
		--load "build/build.lisp"

lisp-info-ros:
	ros run -- --noinform --quit \
		--load "build/info.lisp"

binary-ros: lisp-info-ros bin $(lisps)
	ros run -- --noinform \
		--load "build/setup.lisp" \
		--load "build/build.lisp"

binary: binary-sbcl

# Install ---------------------------------------------------------------------
install:
	cp bin/cg* $(PREFIX)/bin/
