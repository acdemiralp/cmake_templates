# CMake Templates
Concise and modern CMake templates for C++ executables and libraries.

## Automatic Configuration
Prompt your AI assistant with:
```text
Create a new [executable|header-only library|library] project called [project_name] from acdemiralp/cmake_templates.
Apply the Manual Configuration steps from the repository README.
[Add the following dependencies: ...]
```

## Manual Configuration
1. Copy the desired template folder.
2. Rename include/PROJECT_NAME_HERE and replace PROJECT_NAME_HERE in project files.
3. Update project metadata in CMakeLists.txt (name, version, description, homepage).
4. Configure and build with presets: cmake --preset ninja-multi, then cmake --build --preset debug or release.
5. If tests exist, run ctest --preset test-debug.
6. For vcpkg templates only: rename ports/PROJECT_NAME_HERE, update vcpkg.json files, run bootstrap.bat or ./bootstrap.sh.

## Design Decisions
- Templates follow modern CMake best practices and the [VCPKG CMake Style Guide](https://learn.microsoft.com/en-us/vcpkg/contributing/cmake-guidelines).
- Intentional exceptions: GLOB is used, alignment is used, variable names are uppercase.

## Future Work
- Integrate CppCheck, Clang-Tidy, common CIs, agents, ...
