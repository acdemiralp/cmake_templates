@echo off

if not exist "build" mkdir build
cd build
if not exist "vcpkg" git clone https://github.com/Microsoft/vcpkg.git
cd vcpkg
if not exist "vcpkg.exe" call bootstrap-vcpkg.bat

set VCPKG_DEFAULT_TRIPLET=x64-windows
rem Add your library ports to vcpkg.json, then install all declared dependencies:
vcpkg install

rem Use vcpkg's own bundled cmake -- no system cmake required.
set CMAKE=
for /f "usebackq delims=" %%i in (`vcpkg fetch cmake`) do set CMAKE=%%i
cd ..\..

"%CMAKE%" --preset default
"%CMAKE%" --build --preset default --parallel
