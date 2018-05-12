from   conans       import ConanFile, CMake, tools
from   conans.tools import download, unzip
import os

class Project(ConanFile):
    name            = "PROJECT_NAME_HERE"
    description     = "Conan package for PROJECT_NAME_HERE."
    version         = "1.0.0"                
    url             = "PROJECT_URL_HERE"
    settings        = "arch", "build_type", "compiler", "os"
    generators      = "cmake"
    requires        = (("catch2/2.2.0@bincrafters/stable"))

    def imports(self):
       self.copy("*.dylib*", dst="", src="lib")
       self.copy("*.dll"   , dst="", src="bin")

    def source(self):
        zip_name = "v%s.zip" % self.version
        download ("%s/archive/%s" % (self.url, zip_name), zip_name, verify=False)
        unzip    (zip_name)
        os.unlink(zip_name)

    def build(self):
        cmake = CMake(self)
        self.run("cmake %s-%s %s" % (self.name, self.version, cmake.command_line))
        self.run("cmake --build . %s" % cmake.build_config)

    def package(self):
        self.copy("*.exe", dst="bin", keep_path=False)
