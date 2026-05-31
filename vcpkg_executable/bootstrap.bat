
@echo off
if not exist build mkdir build
cd build
if not exist vcpkg git clone https://github.com/Microsoft/vcpkg.git
cd vcpkg
if not exist vcpkg.exe call bootstrap-vcpkg.bat
vcpkg install
for /f "usebackq delims=" %%i in (`vcpkg fetch cmake`) do set CMAKE=%%i
cd ..\..
"%CMAKE%" --preset ninja-multi
"%CMAKE%" --build --preset ninja-multi --parallel
