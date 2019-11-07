#!/usr/bin/env bash

ROSWELL_VERSION=19.09.12.102
ROSWELL_URL="https://github.com/roswell/roswell/releases/download/v$ROSWELL_VERSION/roswell_${ROSWELL_VERSION}_amd64.zip"

OS_WIN=$(uname -s | grep -e MSYS_NT)
if [ -n "$OS_WIN" ]; then
  ROSWELL_IN_PATH=$(echo $PATH | grep -F /tmp/roswell)
  if [ -z "$ROSWELL_IN_PATH" ] ; then
    echo "/tmp/roswell not found \$PATH"
    exit 1
  fi

  echo "Downloading Roswell (v$ROSWELL_VERSION) from: $ROSWELL_URL"
  curl -L "$ROSWELL_URL" \
      --output /tmp/roswell.zip
  unzip -n /tmp/roswell.zip -d /tmp/
fi

# Run roswell's CI script, and since it will find `ros` already available
# in $PATH, it would not try to build it but instead will install the specified
# CL implementation + quicklisp
curl -L "https://raw.githubusercontent.com/roswell/roswell/v$ROSWELL_VERSION/scripts/install-for-ci.sh"
