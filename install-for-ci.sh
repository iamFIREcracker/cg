#!/usr/bin/env sh

if [ "$TRAVIS_OS_NAME" == "windows" ]; then
  # Install: make
  curl -L "https://sourceforge.net/projects/ezwinports/files/make-4.2.1-without-guile-w32-bin.zip/download" \
      --output /tmp/make.zip
  unzip -n /tmp/make.zip -d /mingw64

  # Install: rowsell
  curl -L "https://ci.appveyor.com/api/projects/snmsts/roswell-en89n/artifacts/Roswell-x86_64.zip?branch=master&job=Environment%3A%20MSYS2_ARCH%3Dx86_64,%20MSYS2_BITS%3D64,%20MSYSTEM%3DMINGW64,%20METHOD%3Dcross" \
      --output /tmp/roswell.zip
  unzip -n /tmp/roswell.zip -d /tmp/ # there is a `roswell` toplevel directory already
  export PATH="/tmp/roswell:$PATH"
fi

# Run roswell's CI script, and since it will find `ros` already available
# in $PATH, it would not try to build it but instead will install the specified
# CL implementation + quicklisp
curl -L https://raw.githubusercontent.com/snmsts/roswell/release/scripts/install-for-ci.sh | sh
