##################################################    Project     ##################################################
cmake_minimum_required(VERSION 3.28...4.3 FATAL_ERROR)
project               (PROJECT_NAME_HERE VERSION 1.0 LANGUAGES CXX)
set_property          (GLOBAL PROPERTY USE_FOLDERS ON)
list                  (APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")

include               (extensions)

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
source_group(TREE ${CMAKE_CURRENT_SOURCE_DIR} FILES ${PROJECT_FILES})

##################################################  Dependencies  ##################################################
make_warnings_target(TARGET_NAME ${PROJECT_NAME}_project_warnings)

##################################################    Targets     ##################################################
add_executable(${PROJECT_NAME} ${PROJECT_FILES})
target_compile_features(${PROJECT_NAME} PRIVATE cxx_std_20)
target_include_directories(${PROJECT_NAME} PRIVATE
  "${CMAKE_CURRENT_SOURCE_DIR}/include"
  "${CMAKE_CURRENT_BINARY_DIR}"
  "${CMAKE_CURRENT_SOURCE_DIR}/source")
target_link_libraries     (${PROJECT_NAME} PRIVATE ${PROJECT_NAME}_project_warnings)
if                     (DEFINED PROJECT_INCLUDE_DIRS AND NOT "${PROJECT_INCLUDE_DIRS}" STREQUAL "")
  target_include_directories(${PROJECT_NAME} PRIVATE ${PROJECT_INCLUDE_DIRS})
endif()
if                     (DEFINED PROJECT_LIBRARIES AND NOT "${PROJECT_LIBRARIES}" STREQUAL "")
  target_link_libraries     (${PROJECT_NAME} PRIVATE ${PROJECT_LIBRARIES})
endif()
if                     (DEFINED PROJECT_COMPILE_DEFINITIONS AND NOT "${PROJECT_COMPILE_DEFINITIONS}" STREQUAL "")
  target_compile_definitions(${PROJECT_NAME} PRIVATE ${PROJECT_COMPILE_DEFINITIONS})
endif()
if                     (DEFINED PROJECT_COMPILE_OPTIONS AND NOT "${PROJECT_COMPILE_OPTIONS}" STREQUAL "")
  target_compile_options    (${PROJECT_NAME} PRIVATE ${PROJECT_COMPILE_OPTIONS})
endif()
set_target_properties     (${PROJECT_NAME} PROPERTIES
  CXX_EXTENSIONS OFF
  INTERPROCEDURAL_OPTIMIZATION ${ENABLE_IPO}
  LINKER_LANGUAGE CXX
  UNITY_BUILD ${ENABLE_UNITY_BUILD})

##################################################  Installation  ##################################################
include               (GNUInstallDirs)
set                   (PROJECT_INSTALL_CMAKEDIR "${CMAKE_INSTALL_LIBDIR}/cmake/${PROJECT_NAME}")
file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}Config.cmake"
  "include(\"\\${CMAKE_CURRENT_LIST_DIR}/${PROJECT_NAME}Targets.cmake\")\n")

install(TARGETS ${PROJECT_NAME}
  EXPORT ${PROJECT_NAME}Targets
  RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR})

install(EXPORT ${PROJECT_NAME}Targets
  FILE ${PROJECT_NAME}Targets.cmake
  NAMESPACE ${PROJECT_NAME}::
  DESTINATION ${PROJECT_INSTALL_CMAKEDIR})

install(FILES "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}Config.cmake"
  DESTINATION ${PROJECT_INSTALL_CMAKEDIR})

##################################################     CPack      ##################################################
if(ENABLE_CPACK)
  set(CPACK_PACKAGE_NAME              ${PROJECT_NAME})
  set(CPACK_PACKAGE_VERSION           ${PROJECT_VERSION})
  set(CPACK_PACKAGE_VENDOR            "")
  set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "")
  include(CPack)
endif()
