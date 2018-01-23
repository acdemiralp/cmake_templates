# cmake_templates
A set of cmake templates for creating a C++ library or executable.

Instructions to configure into an actual project (also available in respective CMakeLists.txts):
- Copy the chosen project template somewhere.
- Rename the folder include/PROJECT_NAME_HERE/.
- Open up CMakeLists.txt.
- Change PROJECT_NAME_HERE to your project name.
```cmake
#################################################    Project     #################################################
cmake_minimum_required(VERSION 3.2 FATAL_ERROR)
project               (PROJECT_NAME_HERE VERSION 1.0 LANGUAGES CXX)
list                  (APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake")
```
- Add your source files to the PROJECT_SOURCES list.
```cmake
#################################################    Sources     #################################################
set(PROJECT_SOURCES
  CMakeLists.txt
  cmake/assign_source_group.cmake
  cmake/import_library.cmake
  
  # ADD HEADERS AND SOURCES HERE. EXAMPLES:
  include/example_project/example_header.hpp
  source/example_source.cpp
)
```
- Add your third party libraries via the import_library function which creates a cmake library target for the given 
include directories and libraries. You may also choose to manually add your libraries to the PROJECT_LIBRARIES list.
```cmake
#################################################  Dependencies  #################################################
include(import_library)

# ADD LIBRARIES HERE. EXAMPLES:
# Header Only:
find_package  (GLM REQUIRED)
import_library(GLM_INCLUDE_DIRS)
# Identical Debug and Release:
find_package  (OpenGL REQUIRED)
import_library(OPENGL_INCLUDE_DIR OPENGL_LIBRARIES)
# Separate Debug and Release:
find_package  (Boost REQUIRED iostreams)
import_library(Boost_INCLUDE_DIRS Boost_IOSTREAMS_LIBRARY_DEBUG Boost_IOSTREAMS_LIBRARY_RELEASE)
```
- Add your test files to the PROJECT_TEST_SOURCES list (optional).
```cmake
#################################################    Testing     #################################################
if(BUILD_TESTS)
  enable_testing()
  set(PROJECT_TEST_SOURCES
    # ADD TESTS HERE. EXAMPLES:
    tests/example_test.cpp
  )
endif()
```
- Extend as you like.
