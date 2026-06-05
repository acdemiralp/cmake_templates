##########################################    Project     ##########################################
cmake_minimum_required (VERSION 3.31)
project                (header_only_library VERSION 0.0.0 LANGUAGES CXX)
list                   (APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")
include                (extensions)
include                (GNUInstallDirs)

##########################################     Target     ##########################################
add_library            (${PROJECT_NAME} INTERFACE)
target_compile_features(${PROJECT_NAME} INTERFACE cxx_std_23)

##########################################    Sources     ##########################################
file(GLOB_RECURSE PROJECT_CMAKE_UTILS CONFIGURE_DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/cmake/*"  )
file(GLOB_RECURSE PROJECT_INCLUDES    CONFIGURE_DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/include/*")
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

option(${PROJECT_NAME}_USE_CPM "Use CPM: The unofficial CMake package manager." ON)
if    (${PROJECT_NAME}_USE_CPM)
  get_cpm(
    DESTINATION "${CMAKE_CURRENT_BINARY_DIR}/cmake"
    VERSION     "0.42.3"
    HASH        "a609e875fd532b067174250f6abbc3dac22fe2d64869783fb1e80bda1625c844")
endif ()

##########################################    Testing     ##########################################
if   (PROJECT_IS_TOP_LEVEL)
  option(BUILD_TESTING "Build testing." ON)
  if    (BUILD_TESTING)
    enable_testing()
  endif ()
endif()

if   (BUILD_TESTING)
  if   (COMMAND CPMAddPackage)
    CPMAddPackage(
      NAME              doctest
      GITHUB_REPOSITORY doctest/doctest
      VERSION           2.5.2
      OPTIONS           "DOCTEST_WITH_TESTS OFF")
    include      (${DOCTEST_CMAKE_HELPER})
    set_property (TARGET doctest_with_main PROPERTY FOLDER "tests")
  else ()
    find_package (doctest CONFIG REQUIRED)
    include      (doctest)
  endif()

  file      (GLOB_RECURSE PROJECT_TESTS CONFIGURE_DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/tests/*")
  foreach   (TEST_PATH IN LISTS PROJECT_TESTS)
    cmake_path(GET TEST_PATH STEM        TEST_STEM       )
    cmake_path(GET TEST_PATH PARENT_PATH TEST_PARENT_PATH)
    cmake_path(RELATIVE_PATH TEST_PARENT_PATH OUTPUT_VARIABLE TEST_PARENT_RELATIVE_PATH)

    string                    (MAKE_C_IDENTIFIER
      "${PROJECT_NAME}_${TEST_PARENT_RELATIVE_PATH}_${TEST_STEM}" TEST_NAME)
    add_executable            (${TEST_NAME} ${TEST_PATH})
    set_target_properties     (${TEST_NAME} PROPERTIES
      CXX_STANDARD          23
      CXX_STANDARD_REQUIRED ON
      CXX_EXTENSIONS        OFF)
    target_compile_definitions(${TEST_NAME} PRIVATE DOCTEST_CONFIG_IMPLEMENT_WITH_MAIN)
    target_link_libraries     (${TEST_NAME} PRIVATE
      ${PROJECT_NAME} ${PROJECT_NAME}::warnings doctest::doctest)
    doctest_discover_tests    (${TEST_NAME} TEST_PREFIX "${PROJECT_NAME}.")
    set_property              (TARGET ${TEST_NAME} PROPERTY FOLDER "${TEST_PARENT_RELATIVE_PATH}")
  endforeach()
endif()

##########################################  Installation  ##########################################
include(CMakePackageConfigHelpers)
set    (PROJECT_CONFIG_INSTALL_DIR  "${CMAKE_INSTALL_LIBDIR}/cmake/${PROJECT_NAME}")
set    (PROJECT_PACKAGE_FILE_PREFIX "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}"  )

install(
  TARGETS     ${PROJECT_NAME}
  EXPORT      ${PROJECT_NAME}-targets
  FILE_SET    HEADERS)
install(
  EXPORT      ${PROJECT_NAME}-targets
  DESTINATION "${PROJECT_CONFIG_INSTALL_DIR}"
  FILE        "${PROJECT_NAME}Targets.cmake"
  NAMESPACE   "${PROJECT_NAME}::")
export(
  EXPORT      ${PROJECT_NAME}-targets
  FILE        "${PROJECT_PACKAGE_FILE_PREFIX}Targets.cmake"
  NAMESPACE   "${PROJECT_NAME}::")

configure_package_config_file(
  "${CMAKE_CURRENT_SOURCE_DIR}/cmake/config.cmake.in"
  "${PROJECT_PACKAGE_FILE_PREFIX}Config.cmake"
  INSTALL_DESTINATION  "${PROJECT_CONFIG_INSTALL_DIR}")
write_basic_package_version_file(
  "${PROJECT_PACKAGE_FILE_PREFIX}ConfigVersion.cmake"
  COMPATIBILITY        SameMajorVersion)
install(FILES
  "${PROJECT_PACKAGE_FILE_PREFIX}Config.cmake"
  "${PROJECT_PACKAGE_FILE_PREFIX}ConfigVersion.cmake"
  DESTINATION          "${PROJECT_CONFIG_INSTALL_DIR}")

##########################################   Packaging    ##########################################
set    (CPACK_SOURCE_IGNORE_FILES
  ".git/;/.idea/;/.qt.*/;/.vs.*/;/build/;/out/;/cmake-build-.*/;CMakeUserPresets.json")
include(CPack)
