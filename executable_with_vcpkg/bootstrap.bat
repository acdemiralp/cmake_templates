@echo off

setlocal

set "SCRIPT_DIR=%~dp0"

if not exist "%SCRIPT_DIR%build"                 mkdir "%SCRIPT_DIR%build"
if not exist "%SCRIPT_DIR%build\vcpkg"           git clone https://github.com/Microsoft/vcpkg.git "%SCRIPT_DIR%build\vcpkg"
if not exist "%SCRIPT_DIR%build\vcpkg\vcpkg.exe" call "%SCRIPT_DIR%build\vcpkg\bootstrap-vcpkg.bat"

"%SCRIPT_DIR%build\vcpkg\vcpkg.exe" install --x-manifest-root="%SCRIPT_DIR%" --x-install-root="%SCRIPT_DIR%build\vcpkg_installed"

for /f "usebackq delims=" %%i in (`"%SCRIPT_DIR%build\vcpkg\vcpkg.exe" fetch cmake`) do set "CMAKE=%%i"
"%CMAKE%" -S "%SCRIPT_DIR%" --preset ninja-multi
"%CMAKE%" --build "%SCRIPT_DIR%build\ninja-multi" --preset release --parallel

endlocal
