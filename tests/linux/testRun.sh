#!/bin/bash

set -e

currentDir=`pwd`

export repoBaseDir=$currentDir/../..

cd $repoBaseDir
echo "Run docker"
docker run conan_freeglut /bin/bash -c "cd /test/tests/linux && ./runAllTests.sh"

cd $currentDir
