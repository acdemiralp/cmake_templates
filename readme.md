# cmake_templates
Concise cmake templates for creating C++ libraries and executables.

## Creating a normal cmake project
- Copy the chosen project template somewhere.
- Rename the folder include/PROJECT_NAME_HERE/.
- Open CMakeLists.txt and change `PROJECT_NAME_HERE`.
```cmake
#################################################    Project     #################################################
cmake_minimum_required(VERSION 3.28...4.2 FATAL_ERROR)
project               (PROJECT_NAME_HERE VERSION 1.0 LANGUAGES CXX)
list                  (APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake")
...
```
- Prefer imported targets when the package already provides them.
```cmake
find_package(GLM REQUIRED)
list(APPEND PROJECT_LIBRARIES GLM::GLM)
```
- Use `import_library` only as a fallback for packages that do not export imported targets. You may also set the
`PROJECT_INCLUDE_DIRS` and `PROJECT_LIBRARIES` variables manually instead.
```cmake
...
#################################################  Dependencies  #################################################
include(import_library)

# ADD LIBRARIES HERE. EXAMPLES:
# Imported Target:
find_package(GLM REQUIRED)
list(APPEND PROJECT_LIBRARIES GLM::GLM)
# Fallback for non-CMake or legacy packages:
find_package  (OpenGL REQUIRED)
import_library(OPENGL_INCLUDE_DIR OPENGL_LIBRARIES)
# Separate Debug and Release:
find_package  (Boost REQUIRED iostreams)
import_library(Boost_INCLUDE_DIRS Boost_IOSTREAMS_LIBRARY_DEBUG Boost_IOSTREAMS_LIBRARY_RELEASE)
...
```

## Creating a vcpkg cmake project
- Copy the chosen project template somewhere.
- Rename the folder include/PROJECT_NAME_HERE/.
- Open CMakeLists.txt and change `PROJECT_NAME_HERE`.
```cmake
#################################################    Project     #################################################
cmake_minimum_required(VERSION 3.28...4.2 FATAL_ERROR)
project               (PROJECT_NAME_HERE VERSION 1.0 LANGUAGES CXX)
list                  (APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake")
...
```
- Prefer imported targets when the package already provides them.
```cmake
find_package(GLM REQUIRED)
list(APPEND PROJECT_LIBRARIES GLM::GLM)
```
- Use `import_library` only as a fallback for packages that do not export imported targets. You may also set the
`PROJECT_INCLUDE_DIRS` and `PROJECT_LIBRARIES` variables manually instead.
```cmake
...
#################################################  Dependencies  #################################################
include(import_library)

# ADD LIBRARIES HERE. EXAMPLES:
# Imported Target:
find_package(GLM REQUIRED)
list(APPEND PROJECT_LIBRARIES GLM::GLM)
# Fallback for non-CMake or legacy packages:
find_package  (OpenGL REQUIRED)
import_library(OPENGL_INCLUDE_DIR OPENGL_LIBRARIES)
# Separate Debug and Release:
find_package  (Boost REQUIRED iostreams)
import_library(Boost_INCLUDE_DIRS Boost_IOSTREAMS_LIBRARY_DEBUG Boost_IOSTREAMS_LIBRARY_RELEASE)
...
```
- Open bootstrap.bat and bootstrap.sh, and add your third party library ports.
```batch
...
rem Add your library ports here.
%VCPKG_COMMAND% doctest
...
```
```shell
...
# Add your library ports here. 
$VCPKG_COMMAND doctest
...
```

## Notes on the template defaults
- The templates keep `file(GLOB ...)` on purpose: for a starter project, easy file discovery is usually more helpful
  than manually maintaining source lists from day one.
- `CMAKE_BUILD_TYPE` now defaults to `Release` only on single-config generators when the user did not choose a build
  type. Multi-config generators such as Visual Studio still use their normal configuration selection flow.
- The templates set C++ standard requirements and warning flags per target, so the project and its tests get the
  defaults without pushing those warning flags onto third-party dependencies or downstream consumers.
- `CMakePresets.json` is CMake's shared JSON format for configure/build/test presets used by IDEs and the CLI. It is
  useful once a concrete project has stable workflows, but these starter templates keep that out of the box to stay
  lightweight and language-only.
- `CPack` is CMake's packaging tool for producing archives or installers. Unity builds merge translation units to
  reduce build overhead, and IPO/LTO enables whole-program optimization. Those are valuable project-level choices, but
  they are intentionally left for the generated project to opt into when it has real packaging or performance needs.

## License
This project is licensed under the [MIT License](license.md).
