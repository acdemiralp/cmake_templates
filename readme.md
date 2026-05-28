# cmake_templates
Concise CMake templates for C++ libraries and executables.

## Usage

### Normal project
- Copy the chosen template directory somewhere.
- Rename `include/PROJECT_NAME_HERE/` to your project name.
- Open `CMakeLists.txt` and replace `PROJECT_NAME_HERE`.
```cmake
cmake_minimum_required(VERSION 3.28...4.3 FATAL_ERROR)
project               (PROJECT_NAME_HERE VERSION 1.0 LANGUAGES CXX)
list                  (APPEND CMAKE_MODULE_PATH "${PROJECT_SOURCE_DIR}/cmake")
```
- Add dependencies in the Dependencies section.
```cmake
# Prefer imported targets when the package provides them:
find_package(GLM REQUIRED)
list(APPEND PROJECT_LIBRARIES GLM::GLM)

# Use import_library only as a fallback for packages without imported targets:
find_package  (OpenGL REQUIRED)
import_library(OPENGL_INCLUDE_DIR OPENGL_LIBRARIES)
```
- Configure and build with the shipped presets.
```shell
cmake --preset default
cmake --build --preset default
```

### vcpkg project
Same as the normal project setup, plus:
- Open `vcpkg.json` and set the `name` field (lowercase, hyphens only) and list your dependencies.
```json
{
  "name": "my-project",
  "version": "1.0.0",
  "dependencies": [
    "boost-filesystem",
    "glm"
  ]
}
```
- For reproducible dependency versions, add a real `builtin-baseline` commit SHA from your vcpkg checkout before your first `vcpkg install`.
- Run the bootstrap script. It clones vcpkg, installs packages from `vcpkg.json`, then uses vcpkg's bundled CMake to configure and build — no system CMake required.
```shell
./bootstrap.sh   # Linux / macOS
bootstrap.bat    # Windows
```
vcpkg reads `vcpkg.json` automatically (manifest mode). No port names in the script.

### Publishing as a vcpkg port
vcpkg templates ship a `ports/PROJECT_NAME_HERE/` directory containing a template `portfile.cmake`, `vcpkg.json`, and `usage` file, plus a `vcpkg-configuration.json` that registers `./ports` as an overlay. To test installing your own project as a vcpkg port:
```shell
cd build/vcpkg
./vcpkg install PROJECT_NAME_HERE --overlay-ports=../../ports   # Linux / macOS
vcpkg install PROJECT_NAME_HERE --overlay-ports=..\..\ports     # Windows
```
Before a real release, replace `GITHUB_USER/PROJECT_NAME_HERE` in `portfile.cmake` and set the correct `SHA512` hash. Add runtime dependencies to `ports/PROJECT_NAME_HERE/vcpkg.json`.
