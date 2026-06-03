@echo off

setlocal

for %%I in ("%~dp0\.") do set "SCRIPT_DIR=%%~fI"

set "BUILD_DIR=%SCRIPT_DIR%\build"
set "VCPKG_DIR=%BUILD_DIR%\vcpkg"
set "VCPKG=%VCPKG_DIR%\vcpkg.exe"

if not exist "%BUILD_DIR%" mkdir "%BUILD_DIR%"
if not exist "%VCPKG_DIR%" git clone --depth 1 https://github.com/Microsoft/vcpkg.git "%VCPKG_DIR%"
if not exist "%VCPKG%"     call "%VCPKG_DIR%\bootstrap-vcpkg.bat" -disableMetrics

"%VCPKG%" install --vcpkg-root="%VCPKG_DIR%" --x-manifest-root="%SCRIPT_DIR%" --x-install-root="%BUILD_DIR%\vcpkg_installed"

cd /d "%SCRIPT_DIR%"
cmake --preset ninja-multi
cmake --build --preset debug
cmake --build --preset release

endlocal
