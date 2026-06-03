# CMake Templates
Concise CMake 3.31+ templates for C++ executables and libraries.

## Setup
Prompt your AI assistant with:
```text
Create a new [executable|header-only library|library] [with vcpkg] called [project name] from acdemiralp/cmake_templates and apply the setup steps from the repository readme.
```
Alternatively:
- Copy the desired template directory and rename it to your project name.
- Rename the `include/PROJECT_NAME_HERE` directory to your project name.
- Replace the `PROJECT_NAME_HERE` in the `CMakeLists.txt` with your project name.
- Optional: Add your dependencies to the `CMakeLists.txt`.
- For templates with vcpkg:
  - Replace the `project-name-here` in the `vcpkg.json` with your project name.
  - Optional: Add your dependencies to the `vcpkg.json`.
  - Run `bootstrap.[bat|sh]`.

## Usage
- Configure : `cmake --preset ninja-multi`.
- Build     : `cmake --build --preset [debug|release|relwithdebinfo]`.
- Test      : `ctest --preset [debug|release|relwithdebinfo]`.
- Package   : `cpack --preset [binary|source]`.
- Workflows : `cmake --workflow --preset [test|package]`.

## Notes
Templates follow modern CMake best practices and the [VCPKG CMake Style Guide](https://learn.microsoft.com/en-us/vcpkg/contributing/cmake-guidelines), with the following exceptions: Alignment and glob are used, variable names are uppercase.
