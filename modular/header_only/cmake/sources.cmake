set(PROJECT_SOURCES
  cmake/modules/assign_source_group.cmake
  cmake/modules/import_library.cmake
  cmake/dependencies.cmake
  cmake/install.cmake
  cmake/options.cmake
  cmake/postbuild.cmake
  cmake/sources.cmake
  cmake/tests.cmake
  
  include/PROJECT_NAME_HERE/temp.hpp
  # Add headers here.
  
  CMakeLists.txt
  Readme.txt
)

include(assign_source_group)
assign_source_group(${PROJECT_SOURCES})
