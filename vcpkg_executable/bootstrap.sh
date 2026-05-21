#!/bin/bash

if [ ! -d "build" ] ; then mkdir build ; fi
cd build
if [ ! -d "vcpkg" ] ; then git clone https://github.com/Microsoft/vcpkg.git ; fi
cd vcpkg
if [ ! -f "vcpkg" ] ; then ./bootstrap-vcpkg.sh ; fi

export VCPKG_DEFAULT_TRIPLET=x64-linux
# Add your library ports to vcpkg.json, then install all declared dependencies:
./vcpkg install
cd ..

cd ..
cmake --preset default
cmake --build --preset default --parallel 8
