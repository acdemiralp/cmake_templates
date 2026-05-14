

if not exist "build" mkdir build
cd build
if not exist "vcpkg" git clone https://github.com/Microsoft/vcpkg.git
cd vcpkg
if not exist "vcpkg.exe" call bootstrap-vcpkg.bat

set VCPKG_DEFAULT_TRIPLET=x64-windows
rem Add your library ports here.
vcpkg install --recurse 
cd ..

cd ..
cmake --preset release
cmake --build --preset release --parallel 8
