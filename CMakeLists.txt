cmake_minimum_required(VERSION 3.31)
project               (cmake_templates VERSION 0.0.0 LANGUAGES CXX)

include               (CTest)

add_subdirectory      (./executable)
add_subdirectory      (./executable_with_vcpkg)
add_subdirectory      (./header_only_library)
add_subdirectory      (./header_only_library_with_vcpkg)
add_subdirectory      (./library)
add_subdirectory      (./library_with_vcpkg)

set                   (CPACK_SOURCE_IGNORE_FILES
  ".git/;/.idea/;/.qt.*/;/.vs.*/;/build/;/out/;/cmake-build-.*/;CMakeUserPresets.json")
include               (CPack)
