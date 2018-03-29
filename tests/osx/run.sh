#!/bin/bash

set -e

compiler="$1"
stdlib="$2"

FREEGLUT_BUILD_DEMOS=$3
FREEGLUT_STATIC=$4
FREEGLUT_GLES=$5
FREEGLUT_PRINT_ERRORS=$6
FREEGLUT_PRINT_WARNINGS=$7


name=output_${compiler}_${stdlib}_demos_${FREEGLUT_BUILD_DEMOS}_static_${FREEGLUT_STATIC}_gles_${FREEGLUT_GLES}_print_errors_${FREEGLUT_PRINT_ERRORS}_print_warnings_${FREEGLUT_PRINT_WARNINGS}

variableName="${compiler}Version"
compilerVersion="${!variableName}"

echo "------------------ test program: $compiler $compilerVersion $stdlib ------------------"

currentDir=`pwd`
runDir="$currentDir/.."
outputDir="$runDir/$name"
appDir="$runDir/app"

variableName="${compiler}CppBin"
export CXX="${!variableName}"
variableName="${compiler}CcBin"
export CC="${!variableName}"
variableName="${compiler}Name"
compilerName="${!variableName}"

if [ ! -e "$CXX" ]; then
  echo "NOT EXISTS: $CXX"
  exit 1
fi
if [ ! -e "$CC" ]; then
  echo "NOT EXISTS: $CC"
  exit 1
fi


cd "$appDir"


if [ -d "$outputDir" ]
then
  rm -rf "$outputDir"
fi
mkdir "$outputDir"

cat > conanfile.txt << EOL
[requires]
FreeGlut/3.0.0@iblis_ms/stable

[options]
FreeGlut:FREEGLUT_BUILD_DEMOS=${FREEGLUT_BUILD_DEMOS}
FreeGlut:FREEGLUT_STATIC=${FREEGLUT_STATIC}
FreeGlut:FREEGLUT_GLES=${FREEGLUT_GLES}
FreeGlut:FREEGLUT_PRINT_ERRORS=${FREEGLUT_PRINT_ERRORS}
FreeGlut:FREEGLUT_PRINT_WARNINGS=${FREEGLUT_PRINT_WARNINGS}

[generators]
cmake

[imports]
bin, *.dll -> ../${name}/bin
lib, *.dylib* -> ../${name}/bin
lib, *.so -> ../${name}/bin
lib, *.a -> ../${name}/lib
lib, *.lib -> ../${name}/lib
doc, * -> ../${name}/doc
EOL

cp conanfile.txt "$outputDir/conanfile.txt"

echo "conan install . --build -s compiler=$compilerName -s compiler.version=$compilerVersion -s compiler.libcxx=$stdlib"
conan install . --build -s compiler=$compilerName -s compiler.version=$compilerVersion -s compiler.libcxx=$stdlib

cd "$outputDir"

cmake -DCMAKE_BUILD_TYPE=Release \
    -DFREEGLUT_BUILD_DEMOS=${FREEGLUT_BUILD_DEMOS} \
    -DFREEGLUT_STATIC=${FREEGLUT_STATIC} \
    -DFREEGLUT_GLES=${FREEGLUT_GLES} \
    -DFREEGLUT_PRINT_ERRORS=${FREEGLUT_PRINT_ERRORS} \
    -DFREEGLUT_PRINT_WARNINGS=${FREEGLUT_PRINT_WARNINGS} \
    "$appDir"

cmake --build .

echo "################################### <run> ###################################"
if [ -f "$outputDir/bin/FreeGlutProgram" ]; then
  echo "################################### EXE EXISTS ###################################"
else
  echo "################################### BUILD FAILED ###################################"
  exit 1
fi
echo "################################### </run> ##################################"


if [ ! -d "$outputDir/doc" ]
then
  echo "Folder doc doesn't exists under location: $outputDir/docs"
  exit 1
fi

cd "$outputDir"

if [ "$shared" == "True" ]
then
  libSubfolder='bin'
  libExt=$sharedLibExt
else
  libSubfolder='lib'
  libExt=$staticLibExt
fi
if [ ! -d "$outputDir/$libSubfolder" ]
then
  echo "Library directory doesn't exist: $outputDir/$libSubfolder"
  exit 1
fi
libResult=`find $outputDir/$libSubfolder -name *.$libExt`

if [ -z $libResult ]
then
  echo "Library *.$libExt not found at $outputDir/$libSubfolder"
  exit 1
fi


cd "$currentDir"

