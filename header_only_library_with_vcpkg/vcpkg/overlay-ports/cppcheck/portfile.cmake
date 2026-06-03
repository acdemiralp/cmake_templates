vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO            danmar/cppcheck
  REF             2.17.1
  SHA512          ffd1caeba22493e45ad24c61af19c71adc25ba8eb2c3070152d150921024d68b4892d4e01575c9960e0b0aa1df9deae3514612b184afcf48e377022ca3bb0d85
  HEAD_REF        main)

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
  OPTIONS
    -D BUILD_GUI:BOOL=OFF
    -D BUILD_TESTS:BOOL=OFF
    -D BUILD_MANPAGE:BOOL=OFF)

vcpkg_cmake_install()
vcpkg_copy_tools(TOOL_NAMES cppcheck AUTO_CLEAN)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
file(INSTALL "${SOURCE_PATH}/cfg"       DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
file(INSTALL "${SOURCE_PATH}/addons"    DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
file(INSTALL "${SOURCE_PATH}/platforms" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
