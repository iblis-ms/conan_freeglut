# Author: Marcin Serwach
# https://github.com/iblis-ms/conan_freeglut

from conans import ConanFile, CMake
import os
import sys

channel = os.getenv("CONAN_CHANNEL", "stable")
username = os.getenv("CONAN_USERNAME", "iblis_ms")

class FreeGlutTestConan(ConanFile):
    settings = "os", "compiler", "build_type", "arch"
    requires = "FreeGlut/3.0.0@%s/%s" % (username, channel)
    generators = "cmake"

    def build(self):
        cmake = CMake(self)
        cmake.configure()
        cmake.build()

    def imports(self):
        self.copy("*.dll", dst="bin", src="bin")
        self.copy("*.dylib*", dst="bin", src="lib")
        self.copy("*.so", dst="bin", src="lib")

    def test(self):
        return os.path.isfile(os.path.join("bin", "example")) or os.path.isfile(os.path.join("bin", "example.exe"))
