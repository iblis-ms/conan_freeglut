#!/bin/bash

set -e

echo "------------------ program tests ------------------"

currentDir=`pwd`



for demos in True False
do
  for static in True False
  do
    for gles in False # True https://bugs.launchpad.net/ubuntu/+source/mesa/+bug/1706936 
    do
      for printErrors in True False
      do
        for printWarnings in True False
        do
          for compiler in clang gcc
          do
            for stdlib in libstdc++ libstdc++11 #libc++ 
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


cd "$currentDir"
