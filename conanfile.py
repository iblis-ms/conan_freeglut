# Author: Marcin Serwach
# https://github.com/iblis-ms/conan_freeglut


from conans import ConanFile, CMake, tools
import os
import sys
import shutil

class FreeGlutConan(ConanFile):
    name = 'FreeGlut'
    version = '3.0.0'
    license = 'MIT Licence'
    url = 'https://github.com/iblis-ms/conan_freeglut'
    description = 'Conan.io support for FreeGlut'
    settings = ['os', 'compiler', 'build_type', 'arch']
    options = {
        'FREEGLUT_BUILD_DEMOS':            [True, False],
        'FREEGLUT_STATIC':                 [True, False],
        'FREEGLUT_GLES':                   [True, False],
        'FREEGLUT_PRINT_ERRORS':           [True, False],
        'FREEGLUT_PRINT_WARNINGS':         [True, False],
        'FREEGLUT_REPLACE_GLUT':           [True, False],
        'INSTALL_PDB':                     [True, False],
    }
    default_options = (
                       'FREEGLUT_BUILD_DEMOS=False',
                       'FREEGLUT_STATIC=True',
                       'FREEGLUT_GLES=False',
                       'FREEGLUT_PRINT_ERRORS=False',
                       'FREEGLUT_PRINT_WARNINGS=False',
                       'FREEGLUT_REPLACE_GLUT=False',
                       'INSTALL_PDB=False',
                      )
    generators = 'cmake'
    source_root = 'FreeGLUT-FG_%s' % (version.replace('.', '_')) #'benchmark-%s' % version
    exports = 'CMakeLists.txt'
    buildFolder = '_build'

    def source(self):
        zipFileName = "FG_%s.zip" % (self.version.replace('.', '_'))
        tools.download("https://github.com/dcnieho/FreeGLUT/archive/%s" % zipFileName, zipFileName)
        tools.unzip(zipFileName)
        # CMake 'LIBS' variable contains static/shared libs linked to freeglut. 
        # Save them to file externalLibsToLink.txt. It will be read in package_info.
        cmakeListsPath = os.path.join(self.source_root, 'CMakeLists.txt')
        with open(cmakeListsPath, "a") as cmakeFile:
            cmakeFile.write('file(WRITE "${CMAKE_BINARY_DIR}/externalLibsToLink.txt" "${LIBS}")')

    def build(self):
        cmake = CMake(self)

        for (opt, val) in self.options.items():
            #sys.stdout.write("OPT: %s=%s\n" % (str(opt), str(val)))
            if str(opt) == 'FREEGLUT_STATIC':
                self.static = (str(val) != "False")
                static = 'ON' if self.static else 'OFF'
                shared = 'OFF' if self.static else 'ON'
                #sys.stdout.write("!!!OPT val=%s static=%s shared=%s\n" % (str(val), static, shared))
                cmake.definitions['FREEGLUT_BUILD_STATIC_LIBS'] = static
                cmake.definitions['FREEGLUT_BUILD_SHARED_LIBS'] = shared
            elif val is not None:
                cmake.definitions[opt] = 'ON' if str(val) == "True" else 'OFF'
                if str(opt) == "FREEGLUT_GLES" and str(val) == "True":
                    self.gles = True
        
        sys.stdout.write("cmake " + str(cmake.command_line) + " " + str(self.build_folder) + "\n")
        self.buildFolder = str(self.build_folder)

        cmake.configure(source_dir=self.build_folder, build_dir=self.buildFolder)
        
        cmake.build()

    def package(self):
        self.copy(pattern='*.h', dst='include', src=os.path.join(self.source_root, 'include'), keep_path=True)
        self.copy(pattern='*.lib', dst='lib', src=os.path.join(self.buildFolder,'lib'), keep_path=False)
        self.copy(pattern='*.a', dst='lib', src=os.path.join(self.buildFolder,'lib'), keep_path=False)
        self.copy(pattern='*.so', dst='lib', src=os.path.join(self.buildFolder,'lib'), keep_path=False)
        self.copy(pattern='*.so.*', dst='lib', src=os.path.join(self.buildFolder,'lib'), keep_path=False)
        self.copy(pattern='*.dll', dst='lib', src=os.path.join(self.buildFolder,'lib'), keep_path=False)
        self.copy(pattern='*.dylib', dst='lib', src=os.path.join(self.buildFolder,'lib'), keep_path=False)

        self.copy(pattern='*', dst=os.path.join('doc', 'doc'), src=os.path.join(self.source_root, 'doc'), keep_path=False)

        for docPatter in ['AUTHORS', 'ChangeLog', 'COPYING', 'README*']:
            self.copy(pattern=docPatter, dst='doc', src=self.source_root, keep_path=False)

    def package_info(self):  
        self.cpp_info.libs = ['freeglut']
        filePath = os.path.join(str(self.buildFolder), 'externalLibsToLink.txt')
        with open(filePath) as f:
            content = f.readlines()[0]
        splitLibs = str(content).split(';')
        self.cpp_info.libs.extend(splitLibs)

        

