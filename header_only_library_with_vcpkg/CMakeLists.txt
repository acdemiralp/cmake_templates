##########################################    Project     ##########################################
cmake_minimum_required    (VERSION 3.31)
project                   (PROJECT_NAME_HERE VERSION 0.0.0 LANGUAGES CXX)
list                      (APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")
include                   (extensions)
include                   (GNUInstallDirs)

##########################################     Target     ##########################################
add_library               (${PROJECT_NAME} INTERFACE)
target_compile_features   (${PROJECT_NAME} INTERFACE cxx_std_23)

##########################################    Sources     ##########################################
file(GLOB_RECURSE PROJECT_CMAKE_UTILS CONFIGURE_DEPENDS LIST_DIRECTORIES false
  "${CMAKE_CURRENT_SOURCE_DIR}/cmake/*")
file(GLOB_RECURSE PROJECT_INCLUDES    CONFIGURE_DEPENDS LIST_DIRECTORIES false
  "${CMAKE_CURRENT_SOURCE_DIR}/include/*")
file(GLOB         PROJECT_MISC        CONFIGURE_DEPENDS LIST_DIRECTORIES false
  "${CMAKE_CURRENT_SOURCE_DIR}/*")

target_sources(${PROJECT_NAME}
  INTERFACE
    FILE_SET  HEADERS
    BASE_DIRS "${CMAKE_CURRENT_SOURCE_DIR}/include"
    FILES     ${PROJECT_INCLUDES}
  PRIVATE     ${PROJECT_CMAKE_UTILS} ${PROJECT_MISC})
source_group  (TREE "${CMAKE_CURRENT_SOURCE_DIR}" FILES 
  ${PROJECT_CMAKE_UTILS} ${PROJECT_INCLUDES} ${PROJECT_MISC})

##########################################  Dependencies  ##########################################
make_warnings_target(TARGET_NAME ${PROJECT_NAME}::warnings)

##########################################    Testing     ##########################################
if   (PROJECT_IS_TOP_LEVEL)
  include(CTest)
endif()

if   (BUILD_TESTING)
  find_package(doctest CONFIG REQUIRED)
  include     (doctest)

  file(GLOB_RECURSE PROJECT_TESTS CONFIGURE_DEPENDS LIST_DIRECTORIES false
    "${CMAKE_CURRENT_SOURCE_DIR}/tests/*")

  foreach(TEST_PATH IN LISTS PROJECT_TESTS)
    cmake_path            (GET TEST_PATH STEM        TEST_NAME       )
    cmake_path            (GET TEST_PATH PARENT_PATH TEST_PARENT_PATH)
    cmake_path            (
      RELATIVE_PATH   TEST_PARENT_PATH
      BASE_DIRECTORY  "${CMAKE_CURRENT_SOURCE_DIR}"
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

configure_package_config_file(
  "${CMAKE_CURRENT_SOURCE_DIR}/cmake/config.cmake.in"
  "${PROJECT_PACKAGE_FILE_PREFIX}Config.cmake"
  INSTALL_DESTINATION  "${PROJECT_CONFIG_INSTALL_DIR}")
write_basic_package_version_file(
  "${PROJECT_PACKAGE_FILE_PREFIX}ConfigVersion.cmake"
  VERSION              ${PROJECT_VERSION}
  COMPATIBILITY        SameMajorVersion)
install(FILES
  "${PROJECT_PACKAGE_FILE_PREFIX}Config.cmake"
  "${PROJECT_PACKAGE_FILE_PREFIX}ConfigVersion.cmake"
  DESTINATION          "${PROJECT_CONFIG_INSTALL_DIR}")

##########################################   Packaging    ##########################################
set    (CPACK_SOURCE_IGNORE_FILES ".git/;/build/;CMakeUserPresets.json")
include(CPack)
