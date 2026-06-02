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
"%VCPKG%" fetch cmake --vcpkg-root="%VCPKG_DIR%"

for /f "delims=" %%i in ('where /r "%VCPKG_DIR%\downloads\tools" cmake.exe') do set "CMAKE=%%~fi"
cd /d "%SCRIPT_DIR%"
"%CMAKE%" --preset ninja-multi
"%CMAKE%" --build --preset debug
"%CMAKE%" --build --preset release

endlocal
