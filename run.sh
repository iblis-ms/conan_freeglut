#!/bin/bash

rm -rf /home/iblis/git_workspace/conanFreeGlut/test_package/build
cd tests/linux
./stopConanServer.sh 
./startConanServer.sh

cd ../..

conan test test_package -s compiler=gcc -s compiler.version=7.3 -s compiler.libcxx=libstdc++ FreeGlut/3.0.0@iblis_ms/stable --build

