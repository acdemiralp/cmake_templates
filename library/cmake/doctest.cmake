# Provides doctest_discover_tests() which discovers individual TEST_CASEs and
# registers each one as a separate CTest test via a post-build step.
# Based on https://github.com/doctest/doctest (MIT License).

function(doctest_discover_tests TARGET)
  cmake_parse_arguments(PARSE_ARGV 1 "_" "" "WORKING_DIRECTORY;TEST_PREFIX;TEST_SUFFIX" "PROPERTIES;EXTRA_ARGS")

  if(NOT __WORKING_DIRECTORY)
    set(__WORKING_DIRECTORY "$<TARGET_FILE_DIR:${TARGET}>")
  endif()

  set(_ctest_file "${CMAKE_CURRENT_BINARY_DIR}/${TARGET}_tests.cmake")
  set(_script     "${CMAKE_CURRENT_FUNCTION_LIST_DIR}/doctest_discover_tests.cmake")

  add_custom_command(
    TARGET ${TARGET}
    POST_BUILD
    BYPRODUCTS "${_ctest_file}"
    COMMAND "${CMAKE_COMMAND}"
      "-DTEST_EXECUTABLE=$<TARGET_FILE:${TARGET}>"
      "-DTEST_WORKING_DIR=${__WORKING_DIRECTORY}"
      "-DTEST_PREFIX=${__TEST_PREFIX}"
      "-DTEST_SUFFIX=${__TEST_SUFFIX}"
      "-DTEST_PROPERTIES=${__PROPERTIES}"
      "-DTEST_EXTRA_ARGS=${__EXTRA_ARGS}"
      "-DCTEST_FILE=${_ctest_file}"
      -P "${_script}"
    VERBATIM
  )

  set_property(DIRECTORY APPEND PROPERTY TEST_INCLUDE_FILES "${_ctest_file}")
endfunction()
