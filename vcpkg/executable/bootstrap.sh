#!/bin/bash

if [ ! -d "build" ] ; then mkdir build ; fi
cd build
if [ ! -d "vcpkg" ] ; then git clone https://github.com/Microsoft/vcpkg.git ; fi
cd vcpkg
if [ ! -f "vcpkg" ] ; then ./bootstrap-vcpkg.sh ; fi

VCPKG_DEFAULT_TRIPLET=x64-linux
# Add your library ports here. 
./vcpkg install --recurse
cd ..

cd ..
cmake --preset release
cmake --build --preset release --parallel 8
