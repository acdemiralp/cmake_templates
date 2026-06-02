rmdir /s /q executable\build
rmdir /s /q executable_with_vcpkg\build
rmdir /s /q header_only_library\build
rmdir /s /q header_only_library_with_vcpkg\build
rmdir /s /q library\build
rmdir /s /q library_with_vcpkg\build

call executable_with_vcpkg\bootstrap.bat          || exit /b 1
call header_only_library_with_vcpkg\bootstrap.bat || exit /b 1
call library_with_vcpkg\bootstrap.bat             || exit /b 1

pushd executable
cmake --workflow --preset package                 || exit /b 1
popd

pushd executable_with_vcpkg
cmake --workflow --preset package                 || exit /b 1
popd

pushd header_only_library
cmake --workflow --preset test                    || exit /b 1
cmake --workflow --preset package                 || exit /b 1
popd

pushd header_only_library_with_vcpkg
cmake --workflow --preset test                    || exit /b 1
cmake --workflow --preset package                 || exit /b 1
popd

pushd library
cmake --workflow --preset test                    || exit /b 1
cmake --workflow --preset package                 || exit /b 1
popd

pushd library_with_vcpkg
cmake --workflow --preset test                    || exit /b 1
cmake --workflow --preset package                 || exit /b 1
popd
