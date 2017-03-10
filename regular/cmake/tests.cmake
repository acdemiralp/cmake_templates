enable_testing()

set(PROJECT_TEST_SOURCES
  tests/temp.cpp
  # Add tests here.
)

# Create an executable for each test.
foreach(_SOURCE ${PROJECT_TEST_SOURCES})
  get_filename_component(_NAME ${_SOURCE} NAME_WE)
  set                   (_SOURCES tests/catch.hpp tests/main.cpp ${_SOURCE})
  add_executable        (${_NAME} ${_SOURCES})
  target_link_libraries (${_NAME} ${PROJECT_NAME})
  add_test              (${_NAME} ${_NAME})
  set_property          (TARGET ${_NAME} PROPERTY FOLDER "Tests")
  source_group          ("source" FILES ${_SOURCES})
endforeach()