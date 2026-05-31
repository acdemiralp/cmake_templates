#!/bin/bash

if [ ! -d "build" ] ; then mkdir build ; fi
cd build
if [ ! -d "vcpkg" ] ; then git clone https://github.com/Microsoft/vcpkg.git ; fi
cd vcpkg
if [ ! -f "vcpkg" ] ; then ./bootstrap-vcpkg.sh ; fi

_OS="$(uname -s)"
_ARCH="$(uname -m)"
if   [ "$_OS" = "Darwin" ] && [ "$_ARCH" = "arm64" ]; then
  export VCPKG_DEFAULT_TRIPLET=arm64-osx
elif [ "$_OS" = "Darwin" ]; then
  export VCPKG_DEFAULT_TRIPLET=x64-osx
elif [ "$_ARCH" = "aarch64" ] || [ "$_ARCH" = "arm64" ]; then
  export VCPKG_DEFAULT_TRIPLET=arm64-linux
else
  export VCPKG_DEFAULT_TRIPLET=x64-linux
fi
# Add your library ports to vcpkg.json, then install all declared dependencies:
./vcpkg install

# Use vcpkg's own bundled cmake — no system cmake required.
CMAKE=$(./vcpkg fetch cmake 2>/dev/null | tail -1)
cd ../..

"$CMAKE" --preset default
"$CMAKE" --build --preset default --parallel
