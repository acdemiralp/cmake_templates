##########################################    Project     ##########################################
cmake_minimum_required    (VERSION 3.31)
project                   (PROJECT_NAME_HERE VERSION 0.0.0 LANGUAGES CXX)
list                      (APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")
include                   (extensions)
include                   (GNUInstallDirs)

##########################################     Target     ##########################################
add_executable            (${PROJECT_NAME})
set_target_properties     (${PROJECT_NAME} PROPERTIES
  CXX_STANDARD          23
  CXX_STANDARD_REQUIRED ON
  CXX_EXTENSIONS        OFF)
target_include_directories(${PROJECT_NAME} PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}/include")

##########################################    Sources     ##########################################
file(GLOB_RECURSE PROJECT_CMAKE_UTILS CONFIGURE_DEPENDS LIST_DIRECTORIES false
  "${CMAKE_CURRENT_SOURCE_DIR}/cmake/*")
file(GLOB_RECURSE PROJECT_INCLUDES CONFIGURE_DEPENDS LIST_DIRECTORIES false
  "${CMAKE_CURRENT_SOURCE_DIR}/include/*")
file(GLOB_RECURSE PROJECT_SOURCES  CONFIGURE_DEPENDS LIST_DIRECTORIES false
  "${CMAKE_CURRENT_SOURCE_DIR}/source/*")
file(GLOB         PROJECT_MISC     CONFIGURE_DEPENDS LIST_DIRECTORIES false
  "${CMAKE_CURRENT_SOURCE_DIR}/*")

set(PROJECT_FILES ${PROJECT_CMAKE_UTILS} ${PROJECT_INCLUDES} ${PROJECT_SOURCES} ${PROJECT_MISC})

target_sources(${PROJECT_NAME} PRIVATE ${PROJECT_FILES})
source_group  (TREE "${CMAKE_CURRENT_SOURCE_DIR}" FILES ${PROJECT_FILES})

##########################################  Dependencies  ##########################################
make_warnings_target (TARGET_NAME ${PROJECT_NAME}::warnings)
target_link_libraries(${PROJECT_NAME} PRIVATE ${PROJECT_NAME}::warnings)

##########################################  Installation  ##########################################
install(TARGETS ${PROJECT_NAME} RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}")

##########################################   Packaging    ##########################################
set    (CPACK_SOURCE_IGNORE_FILES "\\.git/;/build/;CMakeUserPresets.json")
include(CPack)
