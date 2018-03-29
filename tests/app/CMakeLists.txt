# Author: Marcin Serwach
# https://github.com/iblis-ms/conan_freeglut

cmake_minimum_required(VERSION 3.3.0)

project(FreeGlutProgram CXX)

if ("${FREEGLUT_STATIC}" STREQUAL "True")
    set(FREEGLUT_BUILD_SHARED_LIBS "OFF")
    set(FREEGLUT_BUILD_STATIC_LIBS "ON")
else ()
    set(FREEGLUT_BUILD_SHARED_LIBS "ON")
    set(FREEGLUT_BUILD_STATIC_LIBS "OFF")
endif ()

include(conanbuildinfo.cmake)
conan_basic_setup()

message(STATUS "CMAKE_CXX_COMPILER_ID=${CMAKE_CXX_COMPILER_ID}")
message(STATUS "FREEGLUT_BUILD_DEMOS=${FREEGLUT_BUILD_DEMOS}")
message(STATUS "FREEGLUT_BUILD_SHARED_LIBS=${FREEGLUT_BUILD_SHARED_LIBS}")
message(STATUS "FREEGLUT_BUILD_STATIC_LIBS=${FREEGLUT_BUILD_STATIC_LIBS}")
message(STATUS "FREEGLUT_GLES=${FREEGLUT_GLES}")
message(STATUS "FREEGLUT_PRINT_ERRORS=${FREEGLUT_PRINT_ERRORS}")
message(STATUS "FREEGLUT_PRINT_WARNINGS=${FREEGLUT_PRINT_WARNINGS}")
message(STATUS "FREEGLUT_REPLACE_GLUT=${FREEGLUT_REPLACE_GLUT}")
message(STATUS "INSTALL_PDB=${INSTALL_PDB}")

set(PROGRAM_NAME "${PROJECT_NAME}")

message(STATUS "Program name: ${PROGRAM_NAME}")

add_executable(${PROGRAM_NAME} FreeGlutExample.cpp)


target_link_libraries(${PROGRAM_NAME} PRIVATE ${CONAN_LIBS})

# Conan sets D_GLIBCXX_USE_CXX11_ABI=1 for stdlibc++11. 
# You can't mix D_GLIBCXX_USE_CXX11_ABI=0 library with D_GLIBCXX_USE_CXX11_ABI=1 program because of runtime crashes.
if ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "Clang")
  if ("${STDLIB}" STREQUAL "libc++")
    target_compile_options(${PROGRAM_NAME} PUBLIC "-stdlib=libc++")
    set_target_properties(${PROGRAM_NAME} PROPERTIES LINK_FLAGS "-stdlib=libc++")
  elseif ("${STDLIB}" STREQUAL "libstdc++")
    target_compile_options(${PROGRAM_NAME} PUBLIC "-stdlib=libstdc++" "-D_GLIBCXX_USE_CXX11_ABI=0")
    set_target_properties(${PROGRAM_NAME} PROPERTIES LINK_FLAGS "-stdlib=libstdc++")
  elseif ("${STDLIB}" STREQUAL "libstdc++11")
    target_compile_options(${PROGRAM_NAME} PUBLIC "-stdlib=libstdc++" "-D_GLIBCXX_USE_CXX11_ABI=1")
    set_target_properties(${PROGRAM_NAME} PROPERTIES LINK_FLAGS "-stdlib=libstdc++")
  endif ()
elseif ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "GNU")
  if ("${STDLIB}" STREQUAL "libstdc++")
    target_compile_options(${PROGRAM_NAME} PUBLIC "-D_GLIBCXX_USE_CXX11_ABI=0")
  elseif ("${STDLIB}" STREQUAL "libstdc++11")
    target_compile_options(${PROGRAM_NAME} PUBLIC "-D_GLIBCXX_USE_CXX11_ABI=1")
  endif ()
elseif ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "MSVC")
  if ("${SHARED}" STREQUAL "True")
    target_compile_options(${PROGRAM_NAME} PUBLIC  "/MD")
  else ()
    target_compile_options(${PROGRAM_NAME} PUBLIC  "/MT")
  endif ()
endif ()


if ("${FREEGLUT_GLES}" STREQUAL "True")
  target_compile_definitions(${PROGRAM_NAME} PUBLIC "FREEGLUT_GLES=ON")
# there is #ifdef FREEGLUT_GLES in freeglut_std.h, so OFF value shouldn't be passed
endif ()

