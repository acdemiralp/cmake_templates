# Replace GITHUB_USER/PROJECT_NAME_HERE with the actual GitHub repository path.
# After tagging a release, replace SHA512 0 with the correct hash:
#   vcpkg install PROJECT_NAME_HERE --overlay-ports=./ports
# vcpkg will print the expected SHA512 on the first run if 0 is used.

set(VCPKG_BUILD_TYPE release)  # Header-only: no debug binaries needed.

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO            GITHUB_USER/PROJECT_NAME_HERE
    REF             "v${VERSION}"
    SHA512          0
    HEAD_REF        main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTS=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME "PROJECT_NAME_HERE")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/license.md")
file(COPY "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
