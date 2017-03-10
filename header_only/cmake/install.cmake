install(TARGETS ${PROJECT_NAME} EXPORT "${PROJECT_NAME}-config"
  ARCHIVE DESTINATION lib
  LIBRARY DESTINATION lib
  RUNTIME DESTINATION bin)
install(DIRECTORY include/ DESTINATION include)
install(FILES   "${PROJECT_BINARY_DIR}/api.hpp" DESTINATION "include/${PROJECT_NAME}")
install(EXPORT  "${PROJECT_NAME}-config"        DESTINATION "cmake")
export (TARGETS "${PROJECT_NAME}"               FILE        "${PROJECT_NAME}-config.cmake")
