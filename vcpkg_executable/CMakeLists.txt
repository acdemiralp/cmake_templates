##################################################    Project     ##################################################
cmake_minimum_required(VERSION 3.28...4.3 FATAL_ERROR)
project               (PROJECT_NAME_HERE VERSION 1.0 LANGUAGES CXX)
list                  (APPEND CMAKE_MODULE_PATH "${PROJECT_SOURCE_DIR}/cmake")
set_property          (GLOBAL PROPERTY USE_FOLDERS ON)

##################################################    Options     ##################################################
option(ENABLE_IPO "Enable interprocedural optimization." OFF)
option(ENABLE_UNITY_BUILD "Enable unity builds." OFF)
option(ENABLE_CPACK "Enable package generation with CPack." OFF)

if(ENABLE_IPO)
  include            (CheckIPOSupported)
  check_ipo_supported(RESULT PROJECT_IPO_SUPPORTED OUTPUT PROJECT_IPO_ERROR)
  if(NOT PROJECT_IPO_SUPPORTED)
    message(FATAL_ERROR "IPO is not supported: ${PROJECT_IPO_ERROR}")
  endif()
endif()

##################################################    Sources     ##################################################
file(GLOB_RECURSE PROJECT_HEADERS CONFIGURE_DEPENDS include/*.h include/*.hpp include/*.ipp)
file(GLOB_RECURSE PROJECT_SOURCES CONFIGURE_DEPENDS source/*.c source/*.cpp source/*.cu)
file(GLOB_RECURSE PROJECT_CMAKE_UTILS CONFIGURE_DEPENDS cmake/*.cmake cmake/*.in)
file(GLOB PROJECT_MISC CONFIGURE_DEPENDS *.bat *.gitignore *.json *.md *.py *.sh *.txt)
set (PROJECT_FILES 
  ${PROJECT_HEADERS} 
  ${PROJECT_SOURCES} 
  ${PROJECT_CMAKE_UTILS} 
  ${PROJECT_MISC})

include            (assign_source_group)
assign_source_group(${PROJECT_FILES})

##################################################  Dependencies  ##################################################
include(import_library)

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
add_executable(${PROJECT_NAME} ${PROJECT_FILES})
target_compile_features(${PROJECT_NAME} PRIVATE cxx_std_20)
target_include_directories(${PROJECT_NAME} PRIVATE
  "${CMAKE_CURRENT_SOURCE_DIR}/include"
  "${CMAKE_CURRENT_BINARY_DIR}"
  "${CMAKE_CURRENT_SOURCE_DIR}/source")
target_include_directories(${PROJECT_NAME} PRIVATE ${PROJECT_INCLUDE_DIRS})
target_link_libraries     (${PROJECT_NAME} PRIVATE ${PROJECT_LIBRARIES})
target_link_libraries     (${PROJECT_NAME} PRIVATE ${PROJECT_NAME}_project_warnings)
target_compile_definitions(${PROJECT_NAME} PRIVATE ${PROJECT_COMPILE_DEFINITIONS})
target_compile_options    (${PROJECT_NAME} PRIVATE ${PROJECT_COMPILE_OPTIONS})
set_target_properties     (${PROJECT_NAME} PROPERTIES
  CXX_EXTENSIONS OFF
  INTERPROCEDURAL_OPTIMIZATION ${ENABLE_IPO}
  LINKER_LANGUAGE CXX
  UNITY_BUILD ${ENABLE_UNITY_BUILD})

##################################################  Installation  ##################################################
install(TARGETS ${PROJECT_NAME} RUNTIME DESTINATION bin)
install(DIRECTORY include/ DESTINATION include)

##################################################     CPack      ##################################################
if(ENABLE_CPACK)
  set(CPACK_PACKAGE_NAME              ${PROJECT_NAME})
  set(CPACK_PACKAGE_VERSION           ${PROJECT_VERSION})
  set(CPACK_PACKAGE_VENDOR            "")
  set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "")
  include(CPack)
endif()
