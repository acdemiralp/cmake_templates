##################################################    Project     ##################################################
cmake_minimum_required(VERSION 3.12 FATAL_ERROR)
project               (PROJECT_NAME_HERE VERSION 1.0 LANGUAGES CXX)
list                  (APPEND CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR}/cmake)
set_property          (GLOBAL PROPERTY USE_FOLDERS ON)
set                   (CMAKE_BUILD_TYPE Release)
set                   (CMAKE_CXX_STANDARD 17)
set                   (CMAKE_CXX_VISIBILITY_PRESET hidden)
set                   (CMAKE_VISIBILITY_INLINES_HIDDEN 1)

if   (MSVC)
  add_compile_options (/W4)
else ()
  add_compile_options (-Wall -Wextra -pedantic)
endif()

##################################################    Options     ##################################################
option(BUILD_SHARED_LIBS "Build shared (dynamic) libraries." ON)
option(BUILD_TESTS "Build tests." OFF)

##################################################    Sources     ##################################################
file(GLOB_RECURSE PROJECT_HEADERS include/*.h include/*.hpp include/*.ipp)
file(GLOB_RECURSE PROJECT_SOURCES source/*.c source/*.cpp source/*.cu)
file(GLOB_RECURSE PROJECT_CMAKE_UTILS cmake/*.cmake)
file(GLOB_RECURSE PROJECT_MISC *.bat *.gitignore *.md *.py *.sh *.txt)
set (PROJECT_EXPORT_HPP include/${PROJECT_NAME}/export.hpp)
set (PROJECT_FILES 
  ${PROJECT_HEADERS} 
  ${PROJECT_SOURCES} 
  ${PROJECT_CMAKE_UTILS} 
  ${PROJECT_MISC} 
  ${PROJECT_EXPORT_HPP})

include            (assign_source_group)
assign_source_group(${PROJECT_FILES})

##################################################  Dependencies  ##################################################
include(import_library)

# ADD LIBRARIES HERE.
# Examples:
# - Header Only:
#   find_package  (GLM REQUIRED)
#   import_library(GLM_INCLUDE_DIRS)
# - Identical Debug and Release:
#   find_package  (OpenGL REQUIRED)
#   import_library(OPENGL_INCLUDE_DIR OPENGL_LIBRARIES)
# - Separate Debug and Release:
#   find_package  (Boost REQUIRED iostreams)
#   import_library(Boost_INCLUDE_DIRS Boost_IOSTREAMS_LIBRARY_DEBUG Boost_IOSTREAMS_LIBRARY_RELEASE)
# - You may also set the PROJECT_INCLUDE_DIRS and PROJECT_LIBRARIES instead of using import_library.

##################################################    Targets     ##################################################
add_library(${PROJECT_NAME} ${PROJECT_FILES})
target_include_directories(${PROJECT_NAME} PUBLIC 
  $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
  $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}>
  $<INSTALL_INTERFACE:include> PRIVATE source)
target_include_directories(${PROJECT_NAME} PUBLIC ${PROJECT_INCLUDE_DIRS})
target_link_libraries     (${PROJECT_NAME} PUBLIC ${PROJECT_LIBRARIES})
target_compile_definitions(${PROJECT_NAME} PUBLIC ${PROJECT_COMPILE_DEFINITIONS})
target_compile_options    (${PROJECT_NAME} PUBLIC ${PROJECT_COMPILE_OPTIONS})
set_target_properties     (${PROJECT_NAME} PROPERTIES LINKER_LANGUAGE CXX)

if(NOT BUILD_SHARED_LIBS)
  string               (TOUPPER ${PROJECT_NAME} PROJECT_NAME_UPPER)
  set_target_properties(${PROJECT_NAME} PROPERTIES COMPILE_FLAGS -D${PROJECT_NAME_UPPER}_STATIC)
endif()

##################################################    Postbuild   ##################################################
include               (GenerateExportHeader)
string                (TOUPPER ${PROJECT_NAME} PROJECT_NAME_UPPER)
generate_export_header(${PROJECT_NAME} 
  EXPORT_FILE_NAME     ${PROJECT_SOURCE_DIR}/include/${PROJECT_NAME}/export.hpp
  EXPORT_MACRO_NAME    ${PROJECT_NAME_UPPER}_EXPORT
  STATIC_DEFINE        ${PROJECT_NAME_UPPER}_STATIC
)

##################################################    Testing     ##################################################
if(BUILD_TESTS)
  enable_testing     ()
  set                (TEST_MAIN_NAME test_main)
  set                (TEST_MAIN_SOURCES tests/internal/main.cpp)
  add_library        (${TEST_MAIN_NAME} OBJECT ${TEST_MAIN_SOURCES})
  set_property       (TARGET ${TEST_MAIN_NAME} PROPERTY FOLDER tests)
  assign_source_group(${TEST_MAIN_SOURCES})

  file(GLOB PROJECT_TEST_CPPS tests/*.c tests/*.cpp tests/*.cu)
  foreach(_SOURCE ${PROJECT_TEST_CPPS})
    get_filename_component(_NAME ${_SOURCE} NAME_WE)
    add_executable        (${_NAME} ${_SOURCE} $<TARGET_OBJECTS:${TEST_MAIN_NAME}>)
    target_link_libraries (${_NAME} ${PROJECT_NAME} ${PROJECT_LIBRARIES})
    add_test              (${_NAME} ${_NAME})
    set_property          (TARGET ${_NAME} PROPERTY FOLDER tests)
    assign_source_group   (${_SOURCE})
  endforeach()
endif()

##################################################  Installation  ##################################################
install(TARGETS ${PROJECT_NAME} EXPORT ${PROJECT_NAME}-config
  ARCHIVE DESTINATION lib
  LIBRARY DESTINATION lib
  RUNTIME DESTINATION bin)
install(DIRECTORY include/ DESTINATION include)
install(EXPORT  ${PROJECT_NAME}-config DESTINATION cmake)
export (TARGETS ${PROJECT_NAME}        FILE        ${PROJECT_NAME}-config.cmake)
