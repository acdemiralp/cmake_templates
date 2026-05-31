#!/bin/bash

(

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null && pwd)"

if [ ! -d "$SCRIPT_DIR/build"             ]; then mkdir "$SCRIPT_DIR/build"                                                 ; fi
if [ ! -d "$SCRIPT_DIR/build/vcpkg"       ]; then git clone https://github.com/Microsoft/vcpkg.git "$SCRIPT_DIR/build/vcpkg"; fi
if [ ! -x "$SCRIPT_DIR/build/vcpkg/vcpkg" ]; then "$SCRIPT_DIR/build/vcpkg/bootstrap-vcpkg.sh"                              ; fi

"$SCRIPT_DIR/build/vcpkg/vcpkg" install --x-manifest-root="$SCRIPT_DIR"

CMAKE=$("$SCRIPT_DIR/build/vcpkg/vcpkg" fetch cmake | tail -1)
"$CMAKE" -S "$SCRIPT_DIR" --preset ninja-multi
"$CMAKE" --build "$SCRIPT_DIR/build/ninja-multi" --preset release --parallel

)
