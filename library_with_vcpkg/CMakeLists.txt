##########################################    Project     ##########################################
cmake_minimum_required    (VERSION 3.31)
project                   (PROJECT_NAME_HERE VERSION 0.0.0 LANGUAGES CXX)
list                      (APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")
include                   (extensions)
include                   (GNUInstallDirs)

##########################################     Target     ##########################################
option                    (BUILD_SHARED_LIBS "Build shared (dynamic) libraries." ON)
add_library               (${PROJECT_NAME})
set_target_properties     (${PROJECT_NAME} PROPERTIES
  CXX_EXTENSIONS            OFF
  CXX_VISIBILITY_PRESET     hidden
  VISIBILITY_INLINES_HIDDEN ON)
target_compile_features   (${PROJECT_NAME} PUBLIC cxx_std_23)

string                    (TOUPPER ${PROJECT_NAME} PROJECT_NAME_UPPER)
set                       (PROJECT_STATIC_DEFINE ${PROJECT_NAME_UPPER}_STATIC)
get_target_property       (PROJECT_TARGET_TYPE ${PROJECT_NAME} TYPE)
if   ("${PROJECT_TARGET_TYPE}" STREQUAL "STATIC_LIBRARY")
  target_compile_definitions(${PROJECT_NAME} PUBLIC ${PROJECT_STATIC_DEFINE})
endif()

##########################################    Sources     ##########################################
file(GLOB_RECURSE PROJECT_CMAKE_UTILS CONFIGURE_DEPENDS
  "${CMAKE_CURRENT_SOURCE_DIR}/cmake/*")
file(GLOB_RECURSE PROJECT_INCLUDES    CONFIGURE_DEPENDS
  "${CMAKE_CURRENT_SOURCE_DIR}/include/*")
file(GLOB_RECURSE PROJECT_SOURCES     CONFIGURE_DEPENDS
  "${CMAKE_CURRENT_SOURCE_DIR}/source/*")
file(GLOB         PROJECT_MISC        CONFIGURE_DEPENDS LIST_DIRECTORIES false
  "${CMAKE_CURRENT_SOURCE_DIR}/*")

include               (GenerateExportHeader)
set                   (PROJECT_EXPORT_PATH
  "${CMAKE_CURRENT_BINARY_DIR}/include/${PROJECT_NAME}/export.h")
generate_export_header(${PROJECT_NAME}
  EXPORT_FILE_NAME "${PROJECT_EXPORT_PATH}"
  STATIC_DEFINE    "${PROJECT_STATIC_DEFINE}")

target_sources(${PROJECT_NAME}
  PUBLIC
    FILE_SET HEADERS
    BASE_DIRS
      "${CMAKE_CURRENT_SOURCE_DIR}/include"
      "${CMAKE_CURRENT_BINARY_DIR}/include"
    FILES
      ${PROJECT_INCLUDES}
      "${PROJECT_EXPORT_PATH}"
  PRIVATE     ${PROJECT_CMAKE_UTILS} ${PROJECT_SOURCES} ${PROJECT_MISC})
source_group  (TREE "${CMAKE_CURRENT_SOURCE_DIR}" FILES
  ${PROJECT_CMAKE_UTILS} ${PROJECT_INCLUDES} ${PROJECT_SOURCES} ${PROJECT_MISC})
source_group  (TREE "${CMAKE_CURRENT_BINARY_DIR}" FILES
  "${PROJECT_EXPORT_PATH}")

##########################################  Dependencies  ##########################################
make_warnings_target (TARGET_NAME ${PROJECT_NAME}::warnings)
target_link_libraries(${PROJECT_NAME} PRIVATE ${PROJECT_NAME}::warnings)

##########################################    Testing     ##########################################
if   (PROJECT_IS_TOP_LEVEL)
  include(CTest)
endif()

if   (BUILD_TESTING)
  find_package(doctest CONFIG REQUIRED)
  include     (doctest)

  file(GLOB_RECURSE PROJECT_TESTS CONFIGURE_DEPENDS
    "${CMAKE_CURRENT_SOURCE_DIR}/tests/*")

  foreach(TEST_PATH IN LISTS PROJECT_TESTS)
    cmake_path            (GET TEST_PATH STEM        TEST_NAME       )
    cmake_path            (GET TEST_PATH PARENT_PATH TEST_PARENT_PATH)
    cmake_path            (
      RELATIVE_PATH   TEST_PARENT_PATH
      OUTPUT_VARIABLE TEST_PARENT_RELATIVE_PATH)

    add_executable        (${TEST_NAME} ${TEST_PATH})
    set_target_properties (${TEST_NAME} PROPERTIES
      CXX_STANDARD          23
      CXX_STANDARD_REQUIRED ON
      CXX_EXTENSIONS        OFF)
    target_compile_definitions(${TEST_NAME} PRIVATE DOCTEST_CONFIG_IMPLEMENT_WITH_MAIN)
    target_link_libraries (${TEST_NAME} PRIVATE
      ${PROJECT_NAME} ${PROJECT_NAME}::warnings doctest::doctest)
    doctest_discover_tests(${TEST_NAME})
    set_property          (TARGET ${TEST_NAME} PROPERTY FOLDER "${TEST_PARENT_RELATIVE_PATH}")
  endforeach()
endif()

##########################################  Installation  ##########################################
include(CMakePackageConfigHelpers)
set    (PROJECT_CONFIG_INSTALL_DIR  "${CMAKE_INSTALL_LIBDIR}/cmake/${PROJECT_NAME}")
set    (PROJECT_PACKAGE_FILE_PREFIX "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}")

install(
  TARGETS              ${PROJECT_NAME}
  EXPORT               ${PROJECT_NAME}-targets
  FILE_SET             HEADERS)
install(
  EXPORT               ${PROJECT_NAME}-targets
  DESTINATION          "${PROJECT_CONFIG_INSTALL_DIR}"
  FILE                 "${PROJECT_NAME}Targets.cmake"
  NAMESPACE            "${PROJECT_NAME}::")
export(
  EXPORT               ${PROJECT_NAME}-targets
  FILE                 "${PROJECT_PACKAGE_FILE_PREFIX}Targets.cmake"
  NAMESPACE            "${PROJECT_NAME}::")

configure_package_config_file(
  "${CMAKE_CURRENT_SOURCE_DIR}/cmake/config.cmake.in"
  "${PROJECT_PACKAGE_FILE_PREFIX}Config.cmake"
  INSTALL_DESTINATION  "${PROJECT_CONFIG_INSTALL_DIR}")
write_basic_package_version_file(
  "${PROJECT_PACKAGE_FILE_PREFIX}ConfigVersion.cmake"
  COMPATIBILITY SameMajorVersion)
install(FILES
  "${PROJECT_PACKAGE_FILE_PREFIX}Config.cmake"
  "${PROJECT_PACKAGE_FILE_PREFIX}ConfigVersion.cmake"
  DESTINATION          "${PROJECT_CONFIG_INSTALL_DIR}")

##########################################   Packaging    ##########################################
set    (CPACK_SOURCE_IGNORE_FILES ".git/;/build/;CMakeUserPresets.json")
include(CPack)
