##################################################    Project     ##################################################
cmake_minimum_required(VERSION 3.28...4.3 FATAL_ERROR)
project               (PROJECT_NAME_HERE VERSION 1.0 LANGUAGES CXX)
list                  (APPEND CMAKE_MODULE_PATH "${PROJECT_SOURCE_DIR}/cmake")
set_property          (GLOBAL PROPERTY USE_FOLDERS ON)

##################################################    Options     ##################################################
option(BUILD_SHARED_LIBS "Build shared (dynamic) libraries." ON)
option(BUILD_TESTS "Build tests." OFF)
option(ENABLE_IPO "Enable interprocedural optimization." OFF)
option(ENABLE_UNITY_BUILD "Enable unity builds." OFF)

if(ENABLE_IPO)
  include            (CheckIPOSupported)
  check_ipo_supported(RESULT PROJECT_IPO_SUPPORTED OUTPUT PROJECT_IPO_ERROR)
  if(NOT PROJECT_IPO_SUPPORTED)
    message(FATAL_ERROR "IPO is not supported: ${PROJECT_IPO_ERROR}")
  endif()
endif()

##################################################    Sources     ##################################################
file(GLOB_RECURSE PROJECT_HEADERS include/*.h include/*.hpp include/*.ipp)
file(GLOB_RECURSE PROJECT_SOURCES source/*.c source/*.cpp source/*.cu)
file(GLOB_RECURSE PROJECT_CMAKE_UTILS cmake/*.cmake cmake/*.in)
file(GLOB PROJECT_MISC *.bat *.gitignore *.json *.md *.py *.sh *.txt)
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

if   (BUILD_TESTS)
  find_package(doctest CONFIG REQUIRED)
  list        (APPEND PROJECT_LIBRARIES doctest::doctest)
endif()

# ADD LIBRARIES HERE. Vcpkg toolchain file will automatically locate them.
# Examples:
# - Prefer imported targets when available:
#   find_package(GLM REQUIRED)
#   list(APPEND PROJECT_LIBRARIES GLM::GLM)
# - Use import_library as a fallback for packages without imported targets:
#   find_package  (OpenGL REQUIRED)
#   import_library(OPENGL_INCLUDE_DIR OPENGL_LIBRARIES)
# - Or for separate debug and release libraries:
#   find_package  (Boost REQUIRED iostreams)
#   import_library(Boost_INCLUDE_DIRS Boost_IOSTREAMS_LIBRARY_DEBUG Boost_IOSTREAMS_LIBRARY_RELEASE)
# - You may also set PROJECT_INCLUDE_DIRS and PROJECT_LIBRARIES directly.

add_library(${PROJECT_NAME}_project_warnings INTERFACE)
if  (MSVC)
  target_compile_options(${PROJECT_NAME}_project_warnings INTERFACE /W4)
else()
  target_compile_options(${PROJECT_NAME}_project_warnings INTERFACE -Wall -Wextra -pedantic)
endif()

##################################################    Targets     ##################################################
add_library(${PROJECT_NAME} ${PROJECT_FILES})
target_compile_features(${PROJECT_NAME} PUBLIC cxx_std_20)
target_include_directories(${PROJECT_NAME} PUBLIC 
  $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
  $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}>
  $<INSTALL_INTERFACE:include> PRIVATE source)
target_include_directories(${PROJECT_NAME} PUBLIC ${PROJECT_INCLUDE_DIRS})
target_link_libraries     (${PROJECT_NAME} PUBLIC ${PROJECT_LIBRARIES})
target_link_libraries     (${PROJECT_NAME} PRIVATE ${PROJECT_NAME}_project_warnings)
target_compile_definitions(${PROJECT_NAME} PUBLIC ${PROJECT_COMPILE_DEFINITIONS})
target_compile_options    (${PROJECT_NAME} PUBLIC ${PROJECT_COMPILE_OPTIONS})
set_target_properties     (${PROJECT_NAME} PROPERTIES
  CXX_EXTENSIONS            OFF
  CXX_VISIBILITY_PRESET     hidden
  INTERPROCEDURAL_OPTIMIZATION ${ENABLE_IPO}
  LINKER_LANGUAGE           CXX
  UNITY_BUILD               ${ENABLE_UNITY_BUILD}
  VISIBILITY_INLINES_HIDDEN 1)

if(NOT BUILD_SHARED_LIBS)
  string               (TOUPPER ${PROJECT_NAME} PROJECT_NAME_UPPER)
  target_compile_definitions(${PROJECT_NAME} PUBLIC ${PROJECT_NAME_UPPER}_STATIC)
endif()

##################################################    Postbuild   ##################################################
include               (GenerateExportHeader)
string                (TOUPPER ${PROJECT_NAME} PROJECT_NAME_UPPER)
generate_export_header(${PROJECT_NAME} 
  EXPORT_FILE_NAME     "${PROJECT_SOURCE_DIR}/include/${PROJECT_NAME}/export.hpp"
  EXPORT_MACRO_NAME    ${PROJECT_NAME_UPPER}_EXPORT
  STATIC_DEFINE        ${PROJECT_NAME_UPPER}_STATIC
)

##################################################   Packaging    ##################################################
include(CMakePackageConfigHelpers)

set(PROJECT_CONFIG_INSTALL_DIR "lib/cmake/${PROJECT_NAME}")

configure_package_config_file(
  "${CMAKE_CURRENT_SOURCE_DIR}/cmake/config.cmake.in"
  "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}Config.cmake"
  INSTALL_DESTINATION "${PROJECT_CONFIG_INSTALL_DIR}")

write_basic_package_version_file(
  "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}ConfigVersion.cmake"
  VERSION ${PROJECT_VERSION}
  COMPATIBILITY SameMajorVersion)

##################################################    Testing     ##################################################
if(BUILD_TESTS)
  enable_testing       ()
  set                  (TEST_MAIN_NAME test_main)
  set                  (TEST_MAIN_SOURCES tests/internal/main.cpp)
  add_library          (${TEST_MAIN_NAME} OBJECT ${TEST_MAIN_SOURCES})
  target_compile_features(${TEST_MAIN_NAME} PRIVATE cxx_std_20)
  target_link_libraries(${TEST_MAIN_NAME} PRIVATE doctest::doctest ${PROJECT_NAME}_project_warnings)
  set_property         (TARGET ${TEST_MAIN_NAME} PROPERTY FOLDER tests)
  set_target_properties(${TEST_MAIN_NAME} PROPERTIES CXX_EXTENSIONS OFF)
  assign_source_group  (${TEST_MAIN_SOURCES})

  file(GLOB PROJECT_TEST_CPPS tests/*.c tests/*.cpp tests/*.cu)
  foreach(_SOURCE ${PROJECT_TEST_CPPS})
    get_filename_component(_NAME ${_SOURCE} NAME_WE)
    add_executable        (${_NAME} ${_SOURCE} $<TARGET_OBJECTS:${TEST_MAIN_NAME}>)
    target_link_libraries (${_NAME} PRIVATE ${PROJECT_NAME} ${PROJECT_LIBRARIES} ${PROJECT_NAME}_project_warnings)
    set_target_properties (${_NAME} PROPERTIES
      CXX_EXTENSIONS OFF
      INTERPROCEDURAL_OPTIMIZATION ${ENABLE_IPO}
      UNITY_BUILD ${ENABLE_UNITY_BUILD})
    add_test              (${_NAME} ${_NAME})
    set_property          (TARGET ${_NAME} PROPERTY FOLDER tests)
    assign_source_group   (${_SOURCE})
  endforeach()
endif()

##################################################  Installation  ##################################################
install(TARGETS ${PROJECT_NAME} EXPORT ${PROJECT_NAME}-config
  ARCHIVE DESTINATION lib
  LIBRARY DESTINATION lib
  RUNTIME DESTINATION bin
  INCLUDES DESTINATION include)
install(DIRECTORY include/ DESTINATION include)
install(EXPORT ${PROJECT_NAME}-config
  DESTINATION "${PROJECT_CONFIG_INSTALL_DIR}"
  FILE "${PROJECT_NAME}Targets.cmake"
  NAMESPACE "${PROJECT_NAME}::")
install(FILES
  "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}Config.cmake"
  "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}ConfigVersion.cmake"
  DESTINATION "${PROJECT_CONFIG_INSTALL_DIR}")
export(EXPORT ${PROJECT_NAME}-config
  FILE "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}Targets.cmake"
  NAMESPACE "${PROJECT_NAME}::")
