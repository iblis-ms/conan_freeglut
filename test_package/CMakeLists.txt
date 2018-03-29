# Author: Marcin Serwach
# https://github.com/iblis-ms/conan_freeglut

cmake_minimum_required(VERSION 2.8.12)

project(FreeGlutPackageTest CXX)

set(CMAKE_VERBOSE_MAKEFILE ON) 


include(${CMAKE_BINARY_DIR}/conanbuildinfo.cmake)
conan_basic_setup()


find_package(OpenGL REQUIRED)

set(EXE_NAME "example")

add_executable(${EXE_NAME} FreeGlutExample.cpp)


target_link_libraries(${EXE_NAME} PRIVATE ${CONAN_LIBS} ${OPENGL_LIBRARIES})
target_include_directories(${EXE_NAME} PUBLIC ${OPENGL_INCLUDE_DIR})

