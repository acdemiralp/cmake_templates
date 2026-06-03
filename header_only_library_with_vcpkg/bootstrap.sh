#!/bin/bash

(

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)

BUILD_DIR="$SCRIPT_DIR/build"
VCPKG_DIR="$BUILD_DIR/vcpkg"
VCPKG="$VCPKG_DIR/vcpkg"

if [ ! -d "$BUILD_DIR" ]; then mkdir "$BUILD_DIR"                                                     ; fi
if [ ! -d "$VCPKG_DIR" ]; then git clone --depth 1 https://github.com/Microsoft/vcpkg.git "$VCPKG_DIR"; fi
if [ ! -x "$VCPKG"     ]; then "$VCPKG_DIR/bootstrap-vcpkg.sh" -disableMetrics                        ; fi

"$VCPKG" install --vcpkg-root "$VCPKG_DIR" --x-manifest-root "$SCRIPT_DIR" --x-install-root "$BUILD_DIR/vcpkg_installed"
CMAKE=$("$VCPKG" fetch cmake --vcpkg-root "$VCPKG_DIR" | tail -n 1)

cd "$SCRIPT_DIR"
"$CMAKE" --preset ninja-multi
"$CMAKE" --build --preset debug
"$CMAKE" --build --preset release

)
