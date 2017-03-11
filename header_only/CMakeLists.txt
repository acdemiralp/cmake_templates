cmake_minimum_required(VERSION 3.2 FATAL_ERROR)

project     (PROJECT_NAME_HERE VERSION 1.0 LANGUAGES CXX)
list        (APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake/modules")
set_property(GLOBAL PROPERTY USE_FOLDERS ON)

include("cmake/options.cmake")
include("cmake/sources.cmake")
include("cmake/dependencies.cmake")

add_library(${PROJECT_NAME} INTERFACE)
target_include_directories(${PROJECT_NAME} INTERFACE 
  $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
  $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}>
  $<INSTALL_INTERFACE:include>)
target_link_libraries(${PROJECT_NAME} INTERFACE ${PROJECT_LIBRARIES})

# Hack for header-only project to appear in the IDEs.
add_library(${PROJECT_NAME}_ STATIC ${PROJECT_SOURCES})
target_include_directories(${PROJECT_NAME}_ 
  PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/include ${CMAKE_CURRENT_BINARY_DIR})
target_link_libraries(${PROJECT_NAME}_ PUBLIC ${PROJECT_LIBRARIES})
set_target_properties(${PROJECT_NAME}_ PROPERTIES LINKER_LANGUAGE CXX)

include("cmake/postbuild.cmake")
include("cmake/install.cmake")
include("cmake/tests.cmake")
