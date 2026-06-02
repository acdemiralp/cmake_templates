cd executable
rmdir /s /q build
cmake --workflow --preset package

cd ../header_only_library
rmdir /s /q build
cmake --workflow --preset test
cmake --workflow --preset package

cd ../library
rmdir /s /q build
cmake --workflow --preset test
cmake --workflow --preset package



cd ../executable_with_vcpkg
rmdir /s /q build
bootstrap.bat
cmake --workflow --preset package

cd ../header_only_library_with_vcpkg
rmdir /s /q build
bootstrap.bat
cmake --workflow --preset test
cmake --workflow --preset package

cd ../library_with_vcpkg
rmdir /s /q build
bootstrap.bat
cmake --workflow --preset test
cmake --workflow --preset package
