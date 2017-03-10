cmake_minimum_required(VERSION 3.2 FATAL_ERROR)

project     (PROJECT_NAME_HERE VERSION 1.0 LANGUAGES CXX)
list        (APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake/modules")
set_property(GLOBAL PROPERTY USE_FOLDERS ON)
set         (CMAKE_CXX_VISIBILITY_PRESET hidden)
set         (CMAKE_VISIBILITY_INLINES_HIDDEN 1)

include("cmake/options.cmake")

include("cmake/sources.cmake")
add_library(${PROJECT_NAME} ${PROJECT_SOURCES}) 
# Change if building an executable: add_executable(${PROJECT_NAME} ${PROJECT_SOURCES})

include("cmake/dependencies.cmake")
target_include_directories(${PROJECT_NAME} PUBLIC 
  $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
  $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}>
  $<INSTALL_INTERFACE:include> PRIVATE source)
target_link_libraries     (${PROJECT_NAME} PUBLIC ${PROJECT_LIBRARIES})
if(NOT BUILD_SHARED_LIBS)
  string                  (TOUPPER ${PROJECT_NAME} PROJECT_NAME_UPPER)
  set_target_properties   (${PROJECT_NAME} PROPERTIES COMPILE_FLAGS -D${PROJECT_NAME_UPPER}_STATIC)
endif()

include("cmake/postbuild.cmake")
include("cmake/install.cmake")
include("cmake/tests.cmake")
