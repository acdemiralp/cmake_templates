include_guard(DIRECTORY)

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

function(enable_vcpkg_cppcheck)
  cmake_parse_arguments(PARSE_ARGV 0 ARG "" "TARGET_NAME" "")

  if(DEFINED CMAKE_TOOLCHAIN_FILE AND NOT "${CMAKE_TOOLCHAIN_FILE}" STREQUAL "")
    get_filename_component(VCPKG_ROOT "${CMAKE_TOOLCHAIN_FILE}" DIRECTORY)
    get_filename_component(VCPKG_ROOT "${VCPKG_ROOT}" DIRECTORY)
    get_filename_component(VCPKG_ROOT "${VCPKG_ROOT}" DIRECTORY)
    set(VCPKG "${VCPKG_ROOT}/vcpkg${CMAKE_EXECUTABLE_SUFFIX}")
    if(EXISTS "${VCPKG}")
      execute_process(
        COMMAND "${VCPKG}" fetch cppcheck --vcpkg-root "${VCPKG_ROOT}"
        OUTPUT_VARIABLE CPPCHECK_OUTPUT
        RESULT_VARIABLE CPPCHECK_RESULT
        OUTPUT_STRIP_TRAILING_WHITESPACE)
      if(CPPCHECK_RESULT EQUAL 0)
        string(REGEX MATCH "[^\n\r]+$" CPPCHECK_PATH "${CPPCHECK_OUTPUT}")
      endif()
    endif()
  endif()

  if(NOT EXISTS "${CPPCHECK_PATH}")
    include(FetchContent)
    set(CPPCHECK_VERSION "2.17.1")
    set(CPPCHECK_HASH    "bfd681868248ec03855ca7c2aea7bcb1f39b8b18860d76aec805a92a967b966c")
    set(CPPCHECK_SOURCE_DIR "${CMAKE_CURRENT_BINARY_DIR}/cmake/cppcheck-${CPPCHECK_VERSION}")
    set(CPPCHECK_BINARY_DIR "${CPPCHECK_SOURCE_DIR}-build")

    FetchContent_Declare(cppcheck
      URL                        "https://github.com/danmar/cppcheck/archive/refs/tags/${CPPCHECK_VERSION}.tar.gz"
      URL_HASH                   "SHA256=${CPPCHECK_HASH}"
      SOURCE_DIR                 "${CPPCHECK_SOURCE_DIR}"
      DOWNLOAD_EXTRACT_TIMESTAMP ON)

    FetchContent_GetProperties(cppcheck)
    if(NOT cppcheck_POPULATED)
      cmake_policy(PUSH)
      cmake_policy(SET CMP0169 OLD)
      FetchContent_Populate(cppcheck)
      cmake_policy(POP)
    endif()

    if(NOT EXISTS "${CPPCHECK_BINARY_DIR}/CMakeCache.txt")
      execute_process(
        COMMAND "${CMAKE_COMMAND}" -S "${cppcheck_SOURCE_DIR}" -B "${CPPCHECK_BINARY_DIR}" -G "${CMAKE_GENERATOR}"
          -D BUILD_GUI:BOOL=OFF -D BUILD_TESTS:BOOL=OFF -D BUILD_MANPAGE:BOOL=OFF
        COMMAND_ERROR_IS_FATAL ANY)
    endif()

    if(CMAKE_CONFIGURATION_TYPES)
      set(CPPCHECK_PATH "${CPPCHECK_BINARY_DIR}/bin/Release/cppcheck${CMAKE_EXECUTABLE_SUFFIX}")
      if(NOT EXISTS "${CPPCHECK_PATH}")
        execute_process(COMMAND "${CMAKE_COMMAND}" --build "${CPPCHECK_BINARY_DIR}" --config Release COMMAND_ERROR_IS_FATAL ANY)
      endif()
    else()
      set(CPPCHECK_PATH "${CPPCHECK_BINARY_DIR}/bin/cppcheck${CMAKE_EXECUTABLE_SUFFIX}")
      if(NOT EXISTS "${CPPCHECK_PATH}")
        execute_process(COMMAND "${CMAKE_COMMAND}" --build "${CPPCHECK_BINARY_DIR}" COMMAND_ERROR_IS_FATAL ANY)
      endif()
    endif()
  endif()

  if(EXISTS "${CPPCHECK_PATH}")
    set(CMAKE_CXX_CPPCHECK "${CPPCHECK_PATH};--enable=all" PARENT_SCOPE)
    set_property(TARGET "${ARG_TARGET_NAME}" PROPERTY CXX_CPPCHECK "${CPPCHECK_PATH};--enable=all")
  endif()
endfunction()
