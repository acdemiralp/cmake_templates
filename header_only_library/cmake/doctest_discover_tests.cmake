# Called at build time by doctest_discover_tests() to populate per-test-case CTest entries.
# Runs the test binary with --list-test-cases and writes a CTest include file.

execute_process(
  COMMAND "${TEST_EXECUTABLE}" --list-test-cases --no-intro=1
  WORKING_DIRECTORY "${TEST_WORKING_DIR}"
  OUTPUT_VARIABLE _output
  RESULT_VARIABLE _result
)

if(NOT _result EQUAL 0)
  message(WARNING "doctest_discover_tests: discovery failed for ${TEST_EXECUTABLE} (exit code ${_result})")
  file(WRITE "${CTEST_FILE}" "")
  return()
endif()

string(REPLACE "\r\n" "\n" _output "${_output}")
string(REPLACE "\r"   "\n" _output "${_output}")

set(_content "")
string(REPLACE "\n" ";" _lines "${_output}")
foreach(_line ${_lines})
  string(STRIP "${_line}" _line)
  if(NOT _line)
    continue()
  endif()
  string(REPLACE "\\" "\\\\" _name "${_line}")
  string(REPLACE "\"" "\\\"" _name "${_name}")
  string(APPEND _content
    "add_test(\n"
    "  NAME \"${TEST_PREFIX}${_name}${TEST_SUFFIX}\"\n"
    "  COMMAND \"${TEST_EXECUTABLE}\" \"--test-case=${_name}\" ${TEST_EXTRA_ARGS}\n"
    ")\n"
  )
  if(TEST_PROPERTIES)
    string(APPEND _content
      "set_tests_properties(\"${TEST_PREFIX}${_name}${TEST_SUFFIX}\" PROPERTIES ${TEST_PROPERTIES})\n"
    )
  endif()
endforeach()

file(WRITE "${CTEST_FILE}" "${_content}")
