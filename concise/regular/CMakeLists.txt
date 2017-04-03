# Concise library / executable cmake template. Configuring this template into an actual project:
# - Change PROJECT_NAME_HERE to your project name.
# - Add your source files to the sources list.
# - Change add_library to add_executable if building an executable.
# - Add your third party libraries via the import_library function.
# - Add your test source files to the test sources list.
# - Rename folder include/PROJECT_NAME_HERE/ to your project name.

##################################################    Project     ##################################################
cmake_minimum_required(VERSION 3.2 FATAL_ERROR)
project               (PROJECT_NAME_HERE VERSION 1.0 LANGUAGES CXX)
list                  (APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake")
set_property          (GLOBAL PROPERTY USE_FOLDERS ON)
set                   (CMAKE_CXX_VISIBILITY_PRESET hidden)
set                   (CMAKE_VISIBILITY_INLINES_HIDDEN 1)

##################################################    Options     ##################################################
option(BUILD_SHARED_LIBS "Build shared (dynamic) libraries." ON)

##################################################    Sources     ##################################################
set(PROJECT_SOURCES
  CMakeLists.txt
  cmake/assign_source_group.cmake
  cmake/import_library.cmake
  
  # ADD HEADERS AND SOURCES HERE.
)
include(assign_source_group)
assign_source_group(${PROJECT_SOURCES})

set         (EXPORT_HEADER "${PROJECT_BINARY_DIR}/api.hpp")
list        (APPEND PROJECT_SOURCES ${EXPORT_HEADER})
source_group("include\\${PROJECT_NAME}" FILES ${EXPORT_HEADER})

##################################################    Targets     ##################################################
add_library(${PROJECT_NAME} ${PROJECT_SOURCES}) # CHANGE TO ADD_EXECUTABLE IF BUILDING AN EXECUTABLE.
target_include_directories(${PROJECT_NAME} PUBLIC 
  $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
  $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}>
  $<INSTALL_INTERFACE:include> PRIVATE source)
target_link_libraries     (${PROJECT_NAME} PUBLIC ${PROJECT_LIBRARIES})
if(NOT BUILD_SHARED_LIBS)
  string                  (TOUPPER ${PROJECT_NAME} PROJECT_NAME_UPPER)
  set_target_properties   (${PROJECT_NAME} PROPERTIES COMPILE_FLAGS -D${PROJECT_NAME_UPPER}_STATIC)
endif()

##################################################  Dependencies  ##################################################
include(import_library)
# ADD LIBRARIES HERE.
# Examples:
# - Header Only:
#   find_package  (GLM REQUIRED)
#   import_library(glm GLM_INCLUDE_DIRS)
# - Identical Debug and Release:
#   find_package  (OpenGL REQUIRED)
#   import_library(opengl OPENGL_INCLUDE_DIR OPENGL_LIBRARIES)
# - Separate Debug and Release:
#   find_package  (Boost REQUIRED iostreams)
#   import_library(iostreams Boost_INCLUDE_DIRS Boost_IOSTREAMS_LIBRARY_DEBUG Boost_IOSTREAMS_LIBRARY_RELEASE)

##################################################    Postbuild   ##################################################
include               (GenerateExportHeader)
string                (TOUPPER ${PROJECT_NAME} PROJECT_NAME_UPPER)
generate_export_header(${PROJECT_NAME} 
  EXPORT_FILE_NAME     api.hpp
  EXPORT_MACRO_NAME    ${PROJECT_NAME_UPPER}_API
  STATIC_DEFINE        ${PROJECT_NAME_UPPER}_STATIC
)

##################################################    Testing     ##################################################
enable_testing()

set(PROJECT_TEST_SOURCES
  # ADD TESTS HERE.
)

foreach(_SOURCE ${PROJECT_TEST_SOURCES})
  get_filename_component(_NAME ${_SOURCE} NAME_WE)
  set                   (_SOURCES tests/catch.hpp tests/main.cpp ${_SOURCE})
  add_executable        (${_NAME} ${_SOURCES})
  target_link_libraries (${_NAME} ${PROJECT_NAME})
  add_test              (${_NAME} ${_NAME})
  set_property          (TARGET ${_NAME} PROPERTY FOLDER "Tests")
  source_group          ("source" FILES ${_SOURCES})
endforeach()

##################################################  Installation  ##################################################
install(TARGETS ${PROJECT_NAME} EXPORT "${PROJECT_NAME}-config"
  ARCHIVE DESTINATION lib
  LIBRARY DESTINATION lib
  RUNTIME DESTINATION bin)
install(DIRECTORY include/ DESTINATION include)
install(FILES   "${PROJECT_BINARY_DIR}/api.hpp" DESTINATION "include/${PROJECT_NAME}")
install(EXPORT  "${PROJECT_NAME}-config"        DESTINATION "cmake")
export (TARGETS "${PROJECT_NAME}"               FILE        "${PROJECT_NAME}-config.cmake")
