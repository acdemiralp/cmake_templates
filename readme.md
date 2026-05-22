# cmake_templates
Concise CMake templates for C++ libraries and executables.

## Templates

| Directory                  | Description                                     |
|----------------------------|-------------------------------------------------|
| `executable`               | Console application                             |
| `library`                  | Compiled library (shared or static)             |
| `header_only_library`      | Header-only library                             |
| `vcpkg_executable`         | Console application with vcpkg dependency manager |
| `vcpkg_library`            | Compiled library with vcpkg                     |
| `vcpkg_header_only_library`| Header-only library with vcpkg                  |

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
  "builtin-baseline": "VCPKG_COMMIT_SHA_HERE",
  "dependencies": [
    "boost-filesystem",
    "glm"
  ]
}
```
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

## Notes

- `file(GLOB ... CONFIGURE_DEPENDS ...)` is used throughout. CMake re-runs configure when files are added or removed. Explicit source lists are still more robust for large teams, but for a starter project GLOB is more practical.
- Every template ships a `CMakePresets.json` with `default`, `debug`, and `release` configure/build presets.
- Library and header-only-library presets also include `testPresets`. After setting `BUILD_TESTS=ON`, run tests with `ctest --preset default`.
- An `INTERFACE` warning target applies `-Wall -Wextra -pedantic` (GCC/Clang) or `/W4` (MSVC) to the project and its tests without propagating those flags to downstream consumers.
- `ENABLE_UNITY_BUILD` and `ENABLE_IPO` are OFF-by-default options for faster builds or link-time optimization.
- Library templates generate `Config.cmake`, `ConfigVersion.cmake`, and namespaced target exports. Installed packages are consumable via `find_package(YourProject CONFIG)` and `target_link_libraries(... YourProject::YourProject)`.
- `ENABLE_CPACK` (OFF by default) activates CPack. Fill in `CPACK_PACKAGE_VENDOR` and `CPACK_PACKAGE_DESCRIPTION_SUMMARY`, then run `cpack` after building to produce archives or installers.
- Tests use [doctest](https://github.com/doctest/doctest). Normal templates vendor `doctest.h`; vcpkg templates acquire it via `find_package(doctest CONFIG REQUIRED)`. `doctest_discover_tests()` registers each `TEST_CASE` as a separate CTest test entry.
- vcpkg bootstrap scripts (`bootstrap.sh` / `bootstrap.bat`) use `vcpkg fetch cmake` to acquire vcpkg's own bundled CMake. No system CMake installation is required before running the script.
- vcpkg templates use [manifest mode](https://learn.microsoft.com/en-us/vcpkg/concepts/manifest-mode): dependencies are declared in `vcpkg.json` and installed automatically when `vcpkg install` is run. The `name` field must be lowercase with hyphens.
- The vcpkg templates include a `builtin-baseline` placeholder (`VCPKG_COMMIT_SHA_HERE`). Replace it with a real commit SHA from your vcpkg checkout (for example from `git log --oneline`) to make dependency versions reproducible.
- The templates default to C++20 (full compiler support: GCC 10+, Clang 13+, MSVC 19.29+).

## Further reading
- [Professional CMake: A Practical Guide](https://crascit.com/professional-cmake/)
- [An Introduction to Modern CMake](https://cliutils.gitlab.io/modern-cmake/)
- [CMake Best Practices](https://www.oreilly.com/library/view/cmake-best-practices/9781804611554/)

## License
[Unlicense](license.md) — public domain, no attribution required.
