#!/bin/bash

set -e

echo "------------------ program tests ------------------"

currentDir=`pwd`

if [ -d ~/.conan_server/data/Freeglut ]
then
  rm -rf ~/.conan_server/data/Freeglut
fi

./startConanServer.sh

# all options are building to long
for demos in False # True
do
  for static in False True 
  do
    for gles in False # True https://bugs.launchpad.net/ubuntu/+source/mesa/+bug/1706936 - cannot install libgles1-mesa
    do
      for printErrors in False # True
      do
        for printWarnings in False # True
        do
          for compiler in clang gcc
          do
            for stdlib in libstdc++ libstdc++11 libc++ 
            do
              if [ "$compiler" != "gcc" ] || [ "$stdlib" != "libc++" ]
              then
                echo "--------------------------------------------"
                echo "-------------------- compiler: ${compiler}"
                echo "-------------------- stdlib: ${stdlib}"
                echo "-------------------- demos: ${demos}"
                echo "-------------------- static: ${static}"
                echo "-------------------- gles: ${gles}"
                echo "-------------------- printErrors: ${printErrors}"
                echo "-------------------- printWarnings: ${printWarnings}"
                ./run.sh $compiler $stdlib $demos $static $gles $printErrors $printWarnings
              fi
            done
          done
        done
      done
    done
  done
done

./stopConanServer.sh

cd "$currentDir"
