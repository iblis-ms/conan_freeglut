@echo OFF

setlocal EnableDelayedExpansion

FREEGLUT_BUILD_DEMOS
 runVisual.bat !demos! !static! !gles! !printErrors! !printWarnings! 
SET FREEGLUT_BUILD_DEMOS=%1
SET FREEGLUT_STATIC=%2
SET FREEGLUT_GLES=%3
SET FREEGLUT_PRINT_ERRORS=%4
SET FREEGLUT_PRINT_WARNINGS=%5
SET FREEGLUT_REPLACE_GLUT=%6
SET INSTALL_PDB=%7

SET "CC=%GCC%"
SET "CXX=%GPP%"

ECHO "------------------ test program: GCC %GCC_VERSION% ------------------"
ECHO "-------------------- stdlib: %LIB_STD%"
ECHO "-------------------- FREEGLUT_BUILD_DEMOS: %FREEGLUT_BUILD_DEMOS%"
ECHO "-------------------- FREEGLUT_STATIC: %FREEGLUT_STATIC%"
ECHO "-------------------- FREEGLUT_GLES: %FREEGLUT_GLES%"
ECHO "-------------------- FREEGLUT_PRINT_ERRORS: %FREEGLUT_PRINT_ERRORS%"
ECHO "-------------------- FREEGLUT_PRINT_WARNINGS: %FREEGLUT_PRINT_WARNINGS%"
ECHO "-------------------- FREEGLUT_REPLACE_GLUT: %FREEGLUT_REPLACE_GLUT%"
ECHO "-------------------- INSTALL_PDB: %INSTALL_PDB%"

SET "CURRENT_DIR=%~dp0"
SET "APP_DIR=%CURRENT_DIR%\..\app"


CD %APP_DIR%

SET "NAME=output_Visual_demos_!FREEGLUT_BUILD_DEMOS!_static_!FREEGLUT_STATIC!_gles_!FREEGLUT_GLES!_print_errors_!FREEGLUT_PRINT_ERRORS!_print_warnings_!FREEGLUT_PRINT_WARNINGS!"

SET "OUTPUT_DIR=%CURRENT_DIR%\..\%NAME%"
IF EXIST "%OUTPUT_DIR%" RD /q /s "%OUTPUT_DIR%"

(
ECHO [requires]
ECHO FreeGlut/3.0.0@iblis_ms/stable
ECHO [options]
ECHO GMock:FREEGLUT_STATIC=!FREEGLUT_STATIC!
ECHO GMock:FREEGLUT_BUILD_DEMOS=!FREEGLUT_BUILD_DEMOS!
ECHO GMock:FREEGLUT_GLES=!FREEGLUT_GLES!
ECHO GMock:FREEGLUT_PRINT_ERRORS=!FREEGLUT_PRINT_ERRORS!
ECHO GMock:FREEGLUT_PRINT_WARNINGS=!FREEGLUT_PRINT_WARNINGS!
ECHO GMock:FREEGLUT_REPLACE_GLUT=!FREEGLUT_REPLACE_GLUT!
ECHO GMock:INSTALL_PDB=!INSTALL_PDB!
ECHO [generators]
ECHO cmake
ECHO [imports]
ECHO bin, *.dll -^> ../!NAME!/bin
ECHO lib, *.dylib* -^> ../!NAME!/bin
ECHO lib, *.so -^> ../!NAME!/bin
ECHO lib, *.a -^> ../!NAME!/lib
ECHO lib, *.lib -^> ../!NAME!/lib
ECHO docs, * -^> ../!NAME!/docs
) > "conanfile.txt"

MKDIR %OUTPUT_DIR%
COPY conanfile.txt %OUTPUT_DIR%\conanfile.txt

CALL conan install . --build -s compiler=gcc -s compiler.version=%GCC_VERSION% -s compiler.libcxx=%LIB_STD%
IF %errorlevel% neq 0 EXIT /b %errorlevel%

CD "%OUTPUT_DIR%"

SET "CC=%GCC%"
SET "CXX=%GPP%"

ECHO "------ Generating MinGW project"

ECHO "cmake -G MinGW Makefiles -DCMAKE_BUILD_TYPE=Release -DFREEGLUT_BUILD_DEMOS=%FREEGLUT_BUILD_DEMOS% -DFREEGLUT_STATIC=%FREEGLUT_STATIC% -DFREEGLUT_GLES=%FREEGLUT_GLES% -DFREEGLUT_PRINT_ERRORS=%FREEGLUT_PRINT_ERRORS% -DFREEGLUT_PRINT_WARNINGS=%FREEGLUT_PRINT_WARNINGS% -DFREEGLUT_REPLACE_GLUT=%FREEGLUT_REPLACE_GLUT% -DINSTALL_PDB=%INSTALL_PDB% %APP_DIR%
"
cmake -G "MinGW Makefiles" -DCMAKE_BUILD_TYPE=Release -DFREEGLUT_BUILD_DEMOS=%FREEGLUT_BUILD_DEMOS% -DFREEGLUT_STATIC=%FREEGLUT_STATIC% -DFREEGLUT_GLES=%FREEGLUT_GLES% -DFREEGLUT_PRINT_ERRORS=%FREEGLUT_PRINT_ERRORS% -DFREEGLUT_PRINT_WARNINGS=%FREEGLUT_PRINT_WARNINGS% -DFREEGLUT_REPLACE_GLUT=%FREEGLUT_REPLACE_GLUT% -DINSTALL_PDB=%INSTALL_PDB% %APP_DIR%

IF %errorlevel% neq 0 EXIT /b %errorlevel%

ECHO "------ Compiling MinGW project"

cmake --build .
SET "ABC=%errorlevel%"
IF %ABC% neq 0 EXIT /b %ABC%
ECHO "------ Checking if program exists"

CD bin
IF NOT EXIST FreeGlutProgram.exe EXIT /b 1

CD "%CURRENT_DIR%"
