##########################################    Project     ##########################################
cmake_minimum_required    (VERSION 3.31)
project                   (PROJECT_NAME_HERE VERSION 0.0.0 LANGUAGES CXX)
list                      (APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")
include                   (extensions)

##########################################     Target     ##########################################
add_executable            (${PROJECT_NAME})
set_target_properties     (${PROJECT_NAME} PROPERTIES
  CXX_STANDARD          23
  CXX_STANDARD_REQUIRED ON
  CXX_EXTENSIONS        OFF)

##########################################    Sources     ##########################################
file(GLOB_RECURSE PROJECT_CMAKE_UTILS CONFIGURE_DEPENDS
  "${CMAKE_CURRENT_SOURCE_DIR}/cmake/*")
file(GLOB_RECURSE PROJECT_INCLUDES    CONFIGURE_DEPENDS
  "${CMAKE_CURRENT_SOURCE_DIR}/include/*")
file(GLOB_RECURSE PROJECT_SOURCES     CONFIGURE_DEPENDS
  "${CMAKE_CURRENT_SOURCE_DIR}/source/*")
file(GLOB         PROJECT_MISC        CONFIGURE_DEPENDS LIST_DIRECTORIES false
  "${CMAKE_CURRENT_SOURCE_DIR}/*")

target_sources(${PROJECT_NAME}
  PRIVATE
    FILE_SET  HEADERS
    BASE_DIRS "${CMAKE_CURRENT_SOURCE_DIR}/include"
    FILES     ${PROJECT_INCLUDES}
  PRIVATE     ${PROJECT_CMAKE_UTILS} ${PROJECT_SOURCES} ${PROJECT_MISC})
source_group  (TREE "${CMAKE_CURRENT_SOURCE_DIR}" FILES 
  ${PROJECT_CMAKE_UTILS} ${PROJECT_INCLUDES} ${PROJECT_SOURCES} ${PROJECT_MISC})

##########################################  Dependencies  ##########################################
make_warnings_target (TARGET_NAME ${PROJECT_NAME}::warnings)
target_link_libraries(${PROJECT_NAME} PRIVATE ${PROJECT_NAME}::warnings)

option(${PROJECT_NAME}_USE_CPM "Use CPM: The unofficial CMake package manager." ON)
if    (${PROJECT_NAME}_USE_CPM)
  get_cpm(
    DESTINATION "${CMAKE_CURRENT_BINARY_DIR}/cmake"
    VERSION     "0.42.3"
    HASH        "a609e875fd532b067174250f6abbc3dac22fe2d64869783fb1e80bda1625c844")
endif ()

##########################################  Installation  ##########################################
install(TARGETS ${PROJECT_NAME})

##########################################   Packaging    ##########################################
set    (CPACK_SOURCE_IGNORE_FILES ".git/;/build/;CMakeUserPresets.json")
include(CPack)
