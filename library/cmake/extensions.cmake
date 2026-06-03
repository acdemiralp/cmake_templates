include_guard(DIRECTORY)

function     (get_cpm)
  cmake_parse_arguments (PARSE_ARGV 0 "ARG" "" "DESTINATION;VERSION;HASH" "")
  if   (NOT "${ARG_UNPARSED_ARGUMENTS}" STREQUAL "")
    message(FATAL_ERROR "The ${CMAKE_CURRENT_FUNCTION} was passed unexpected arguments: ${ARG_UNPARSED_ARGUMENTS}")
  endif()
  if   (NOT DEFINED "ARG_DESTINATION" OR "${ARG_DESTINATION}" STREQUAL "")
    message(FATAL_ERROR "The ${CMAKE_CURRENT_FUNCTION} requires a DESTINATION argument.")
  endif()
  if   (NOT DEFINED "ARG_VERSION" OR "${ARG_VERSION}" STREQUAL "")
    message(FATAL_ERROR "The ${CMAKE_CURRENT_FUNCTION} requires a VERSION argument.")
  endif()
  if   (NOT DEFINED "ARG_HASH" OR "${ARG_HASH}" STREQUAL "")
    message(FATAL_ERROR "The ${CMAKE_CURRENT_FUNCTION} requires a HASH argument.")
  endif()

  get_filename_component(CPM_DIRECTORY "${ARG_DESTINATION}" ABSOLUTE)
  set                   (CPM_FILE      "${CPM_DIRECTORY}/CPM_${ARG_VERSION}.cmake")
  if   (NOT EXISTS "${CPM_FILE}")
    file (MAKE_DIRECTORY "${CPM_DIRECTORY}")
    file (DOWNLOAD       "https://github.com/cpm-cmake/CPM.cmake/releases/download/v${ARG_VERSION}/CPM.cmake"
      "${CPM_FILE}" EXPECTED_HASH "SHA256=${ARG_HASH}")
  endif()
  include("${CPM_FILE}")
endfunction  ()

function     (make_imported_target)
  cmake_parse_arguments (PARSE_ARGV 0 "ARG" "" "TARGET_NAME" "INCLUDE_DIRS;LIBRARIES;DEBUG_LIBRARIES")
  if   (NOT "${ARG_UNPARSED_ARGUMENTS}" STREQUAL "")
    message(FATAL_ERROR "The ${CMAKE_CURRENT_FUNCTION} was passed unexpected arguments: ${ARG_UNPARSED_ARGUMENTS}")
  endif()
  if   (NOT DEFINED "ARG_TARGET_NAME" OR "${ARG_TARGET_NAME}" STREQUAL "")
    message(FATAL_ERROR "The ${CMAKE_CURRENT_FUNCTION} requires a TARGET_NAME argument.")
  endif()
  if   (DEFINED "ARG_DEBUG_LIBRARIES" AND NOT DEFINED "ARG_LIBRARIES")
    message(FATAL_ERROR "The ${CMAKE_CURRENT_FUNCTION} requires a LIBRARIES argument when DEBUG_LIBRARIES is specified.")
  endif()

  add_library               ("${ARG_TARGET_NAME}" INTERFACE IMPORTED)
  target_include_directories("${ARG_TARGET_NAME}" INTERFACE ${ARG_INCLUDE_DIRS})
  if   (NOT DEFINED "ARG_DEBUG_LIBRARIES")
    target_link_libraries   ("${ARG_TARGET_NAME}" INTERFACE ${ARG_LIBRARIES})
  else ()
    target_link_libraries   ("${ARG_TARGET_NAME}" INTERFACE
      "$<$<CONFIG:Debug>:${ARG_DEBUG_LIBRARIES}>"
      "$<$<NOT:$<CONFIG:Debug>>:${ARG_LIBRARIES}>")
  endif()
endfunction  ()

function     (make_warnings_target)
  cmake_parse_arguments (PARSE_ARGV 0 "ARG" "" "TARGET_NAME" "")
  if   (NOT "${ARG_UNPARSED_ARGUMENTS}" STREQUAL "")
    message(FATAL_ERROR "The ${CMAKE_CURRENT_FUNCTION} was passed unexpected arguments: ${ARG_UNPARSED_ARGUMENTS}")
  endif()
  if   (NOT DEFINED "ARG_TARGET_NAME" OR "${ARG_TARGET_NAME}" STREQUAL "")
    message(FATAL_ERROR "The ${CMAKE_CURRENT_FUNCTION} requires a TARGET_NAME argument.")
  endif()

  string                (MD5 TARGET_HASH "${ARG_TARGET_NAME}")
  set                   (INTERNAL_TARGET_NAME "warnings_${TARGET_HASH}")
  add_library           ("${INTERNAL_TARGET_NAME}" INTERFACE)
  target_compile_options("${INTERNAL_TARGET_NAME}" INTERFACE
    "$<$<COMPILE_LANGUAGE:CXX>:$<$<OR:$<CXX_COMPILER_ID:MSVC>,$<STREQUAL:${CMAKE_CXX_SIMULATE_ID},MSVC>>:/permissive-;/W4>>"
    "$<$<COMPILE_LANGUAGE:CXX>:$<$<NOT:$<OR:$<CXX_COMPILER_ID:MSVC>,$<STREQUAL:${CMAKE_CXX_SIMULATE_ID},MSVC>>>:-Wall;-Wextra;-Wpedantic>>")
  add_library           ("${ARG_TARGET_NAME}" ALIAS "${INTERNAL_TARGET_NAME}")
endfunction  ()

function     (enable_cppcheck)
  cmake_parse_arguments(PARSE_ARGV 0 "ARG" "" "TARGET_NAME;DESTINATION;VERSION;HASH" "")
  if   (NOT "${ARG_UNPARSED_ARGUMENTS}" STREQUAL "")
    message(FATAL_ERROR "The ${CMAKE_CURRENT_FUNCTION} was passed unexpected arguments: ${ARG_UNPARSED_ARGUMENTS}")
  endif()
  if   (NOT DEFINED "ARG_TARGET_NAME" OR "${ARG_TARGET_NAME}" STREQUAL "")
    message(FATAL_ERROR "The ${CMAKE_CURRENT_FUNCTION} requires a TARGET_NAME argument.")
  endif()
  if   (NOT DEFINED "ARG_DESTINATION" OR "${ARG_DESTINATION}" STREQUAL "")
    message(FATAL_ERROR "The ${CMAKE_CURRENT_FUNCTION} requires a DESTINATION argument.")
  endif()
  if   (NOT DEFINED "ARG_VERSION" OR "${ARG_VERSION}" STREQUAL "")
    message(FATAL_ERROR "The ${CMAKE_CURRENT_FUNCTION} requires a VERSION argument.")
  endif()
  if   (NOT DEFINED "ARG_HASH" OR "${ARG_HASH}" STREQUAL "")
    message(FATAL_ERROR "The ${CMAKE_CURRENT_FUNCTION} requires a HASH argument.")
  endif()

  include(FetchContent)

  get_filename_component(CPPCHECK_DESTINATION "${ARG_DESTINATION}" ABSOLUTE)
  FetchContent_Declare(cppcheck
    URL                        "https://github.com/danmar/cppcheck/archive/refs/tags/${ARG_VERSION}.tar.gz"
    URL_HASH                   "SHA256=${ARG_HASH}"
    SOURCE_DIR                 "${CPPCHECK_DESTINATION}/cppcheck-${ARG_VERSION}"
    DOWNLOAD_EXTRACT_TIMESTAMP ON)

  FetchContent_GetProperties(cppcheck)
  if   (NOT cppcheck_POPULATED)
    cmake_policy(PUSH)
    cmake_policy(SET CMP0169 OLD)
    FetchContent_Populate(cppcheck)
    cmake_policy(POP)
  endif()

  set(CPPCHECK_BINARY_DIR "${CPPCHECK_DESTINATION}/cppcheck-${ARG_VERSION}-build")
  if   (NOT EXISTS "${CPPCHECK_BINARY_DIR}/CMakeCache.txt")
    execute_process(
      COMMAND "${CMAKE_COMMAND}"
        -S "${cppcheck_SOURCE_DIR}"
        -B "${CPPCHECK_BINARY_DIR}"
        -G "${CMAKE_GENERATOR}"
        -D BUILD_GUI:BOOL=OFF
        -D BUILD_TESTS:BOOL=OFF
      RESULT_VARIABLE CPPCHECK_CONFIGURE_RESULT)
    if   (NOT CPPCHECK_CONFIGURE_RESULT EQUAL 0)
      message(FATAL_ERROR "Failed to configure cppcheck.")
    endif()
  endif()

  if   (CMAKE_CONFIGURATION_TYPES)
    set(CPPCHECK_EXECUTABLE "${CPPCHECK_BINARY_DIR}/bin/Release/cppcheck${CMAKE_EXECUTABLE_SUFFIX}")
    set(CPPCHECK_BUILD_CONFIG --config Release)
  else ()
    set(CPPCHECK_EXECUTABLE "${CPPCHECK_BINARY_DIR}/bin/cppcheck${CMAKE_EXECUTABLE_SUFFIX}")
    set(CPPCHECK_BUILD_CONFIG)
  endif()
  if   (NOT EXISTS "${CPPCHECK_EXECUTABLE}")
    execute_process(
      COMMAND "${CMAKE_COMMAND}" --build "${CPPCHECK_BINARY_DIR}" ${CPPCHECK_BUILD_CONFIG}
      RESULT_VARIABLE CPPCHECK_BUILD_RESULT)
    if   (NOT CPPCHECK_BUILD_RESULT EQUAL 0)
      message(FATAL_ERROR "Failed to build cppcheck.")
    endif()
  endif()

  set(CPPCHECK_COMMAND "${CPPCHECK_EXECUTABLE};--enable=all")
  set(CMAKE_CXX_CPPCHECK "${CPPCHECK_COMMAND}" PARENT_SCOPE)
  set_property(TARGET "${ARG_TARGET_NAME}" PROPERTY CXX_CPPCHECK "${CPPCHECK_COMMAND}")
endfunction  ()
