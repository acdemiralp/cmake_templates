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
- Configure and build with the shipped presets.
```shell
cmake --preset default
cmake --build --preset default
```

## Notes on the template defaults
- The templates keep `file(GLOB ...)` on purpose: for a starter project, easy file discovery is usually more helpful
  than manually maintaining source lists from day one.
- Every template now ships with a `CMakePresets.json` containing `default`, `debug`, and `release` presets. That keeps
  the default configuration out of `CMakeLists.txt` and gives IDEs and the CLI the same entry points.
- The templates use a small `INTERFACE` warning target so the project and its tests get the default warning set
  without pushing those warning flags onto third-party dependencies or downstream consumers.
- Unity builds and IPO/LTO are available as OFF-by-default options (`ENABLE_UNITY_BUILD` and `ENABLE_IPO`) for users
  who want faster builds or whole-program optimization without turning those choices into hard-coded defaults.
- The library templates now generate `Config.cmake`, `ConfigVersion.cmake`, and namespaced target exports so installed
  packages can be consumed with `find_package(YourProject CONFIG)` and `target_link_libraries(... YourProject::YourProject)`.
- `CPack` is CMake's packaging tool for producing archives or installers. It is still intentionally left out of these
  starter templates, since packaging needs vary much more from project to project than the basic configure/build flow.

## Further reading
- [Professional CMake: A Practical Guide](https://crascit.com/professional-cmake/)
- [An Introduction to Modern CMake](https://cliutils.gitlab.io/modern-cmake/)
- [CMake Best Practices](https://www.oreilly.com/library/view/cmake-best-practices/9781804611554/)

## License
This project is licensed under the [MIT License](license.md).
