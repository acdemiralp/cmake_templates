include               (GenerateExportHeader)
string                (TOUPPER ${PROJECT_NAME} PROJECT_NAME_UPPER)
generate_export_header(${PROJECT_NAME} 
  EXPORT_FILE_NAME      api.hpp
  EXPORT_MACRO_NAME     ${PROJECT_NAME_UPPER}_API
  STATIC_DEFINE         ${PROJECT_NAME_UPPER}_STATIC
)
