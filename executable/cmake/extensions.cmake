include_guard(DIRECTORY)

function     (make_external_target)
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
