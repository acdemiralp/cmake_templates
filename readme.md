# cmake_templates
Concise cmake templates for creating C++ libraries and executables.

## Creating a normal cmake project
- Copy the chosen project template somewhere.
- Rename the folder include/PROJECT_NAME_HERE/.
- Open CMakeLists.txt and change `PROJECT_NAME_HERE`.
```cmake
#################################################    Project     #################################################
cmake_minimum_required(VERSION 3.12 FATAL_ERROR)
project               (PROJECT_NAME_HERE VERSION 1.0 LANGUAGES CXX)
list                  (APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake")
...
```
- Add your third party libraries via the `import_library` function which creates a cmake library target for the 
given include directories and libraries. You may also set the `PROJECT_INCLUDE_DIRS` and `PROJECT_LIBRARIES` 
variables manually instead of using import_library.
```cmake
...
#################################################  Dependencies  #################################################
include(import_library)

# ADD LIBRARIES HERE. EXAMPLES:
# Header Only:
find_package  (GLM REQUIRED)
import_library(GLM_INCLUDE_DIRS)
# Identical Debug and Release:
find_package  (OpenGL REQUIRED)
import_library(OPENGL_INCLUDE_DIR OPENGL_LIBRARIES)
# Separate Debug and Release:
find_package  (Boost REQUIRED iostreams)
import_library(Boost_INCLUDE_DIRS Boost_IOSTREAMS_LIBRARY_DEBUG Boost_IOSTREAMS_LIBRARY_RELEASE)
...
```

## Creating a conan cmake project
- Copy the chosen project template somewhere.
- Rename the folder include/PROJECT_NAME_HERE/.
- Open CMakeLists.txt and change `PROJECT_NAME_HERE`.
```cmake
#################################################    Project     #################################################
cmake_minimum_required(VERSION 3.12 FATAL_ERROR)
project               (PROJECT_NAME_HERE VERSION 1.0 LANGUAGES CXX)
list                  (APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake")
...
```
- Open conanfile.py, change `PROJECT_NAME_HERE` as well as `PROJECT_URL_HERE` (if available) and add your 
third party libraries to the `requires`.
```python
...
class Project(ConanFile):
    name            = "PROJECT_NAME_HERE"
    description     = "Conan package for PROJECT_NAME_HERE."
    version         = "1.0.0"                
    url             = "PROJECT_URL_HERE"
    settings        = "arch", "build_type", "compiler", "os"
    generators      = "cmake"
    requires        = (("doctest/2.3.4@bincrafters/stable")) 
    ...
```

## Creating a vcpkg cmake project
- Copy the chosen project template somewhere.
- Rename the folder include/PROJECT_NAME_HERE/.
- Open CMakeLists.txt and change `PROJECT_NAME_HERE`.
```cmake
#################################################    Project     #################################################
cmake_minimum_required(VERSION 3.12 FATAL_ERROR)
project               (PROJECT_NAME_HERE VERSION 1.0 LANGUAGES CXX)
list                  (APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake")
...
```
- Add your third party libraries via the `import_library` function which creates a cmake library target for the 
given include directories and libraries. You may also set the `PROJECT_INCLUDE_DIRS` and `PROJECT_LIBRARIES` 
variables manually instead of using import_library.
```cmake
...
#################################################  Dependencies  #################################################
include(import_library)

# ADD LIBRARIES HERE. EXAMPLES:
# Header Only:
find_package  (GLM REQUIRED)
import_library(GLM_INCLUDE_DIRS)
# Identical Debug and Release:
find_package  (OpenGL REQUIRED)
import_library(OPENGL_INCLUDE_DIR OPENGL_LIBRARIES)
# Separate Debug and Release:
find_package  (Boost REQUIRED iostreams)
import_library(Boost_INCLUDE_DIRS Boost_IOSTREAMS_LIBRARY_DEBUG Boost_IOSTREAMS_LIBRARY_RELEASE)
...
```
- Open bootstrap.bat and bootstrap.sh, and add your third party library ports.
```batch
...
rem Add your library ports here.
%VCPKG_COMMAND% doctest
...
```
```shell
...
# Add your library ports here. 
$VCPKG_COMMAND doctest
...
```