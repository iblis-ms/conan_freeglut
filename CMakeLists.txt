# Author: Marcin Serwach
# https://github.com/iblis-ms/conan_freeglut

cmake_minimum_required(VERSION 2.8)
project(conanFreeGlut)


if ("${FREEGLUT_STATIC}" STREQUAL "True")
    set(FREEGLUT_BUILD_SHARED_LIBS "OFF")
    set(FREEGLUT_BUILD_STATIC_LIBS "ON")
else ()
    set(FREEGLUT_BUILD_SHARED_LIBS "ON")
    set(FREEGLUT_BUILD_STATIC_LIBS "OFF")
endif ()

include(conanbuildinfo.cmake)
CONAN_BASIC_SETUP()

add_subdirectory("FreeGLUT-FG_3_0_0")

# FreeGlut target name depends of library type
if("${FREEGLUT_BUILD_SHARED_LIBS}" STREQUAL "ON")
    SET(FREEGLUT_TARGET freeglut)
elseif("${FREEGLUT_BUILD_STATIC_LIBS}" STREQUAL "ON")
    SET(FREEGLUT_TARGET freeglut_static)
else()
    message(FATAL "Unknown type of FreeGlut library")
endif()


