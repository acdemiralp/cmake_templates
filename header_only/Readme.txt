Configuring this template into an actual project:
- Required steps:
  - Rename folder include/PROJECT_NAME_HERE/ to your project name.
  - In CMakeLists.txt          : Change PROJECT_NAME_HERE to your project name.
  - In cmake/sources.cmake     : Add your source files to the list.
  - In cmake/dependencies.cmake: Add your third party libraries via the import_library function.
- Optional steps:
  - In cmake/options.cmake     : Add your custom build options.
  - In cmake/postbuild.cmake   : Add your custom postbuild commands.
  - In cmake/tests.cmake       : Add your test source files to the list.

Future work:
- Integrate target_compile_definitions, target_compile_options, target_compile_features.
