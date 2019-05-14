.PHONY: vendor clean binary-sbcl binary

quicklisp := vendor/quicklisp.lisp
lisps := $(shell find .  -type f \( -iname \*.asd -o -iname \*.lisp \))

all: binary

# Clean -----------------------------------------------------------------------
clean:
	rm -rf bin $(quicklisp)

# Build -----------------------------------------------------------------------
bin:
	mkdir -p bin

$(quicklisp):
	curl -o $@ -O https://beta.quicklisp.org/quicklisp.lisp

binary-sbcl: bin $(quicklisp) $(lisps)
	sbcl --noinform --load "src/build.lisp"

binary: binary-sbcl
