#!/bin/bash

echo "------------------ start server conan ------------------"

callDir=`pwd`

conan remove -f FreeGlut*

conan_server&
echo "Conan server 1st run: $?"
sleep 2
./stopConanServer.sh
echo "Conan server 1st run was stopped: $?"
sleep 2
cp ../server.conf $HOME/.conan_server/

conan_server&
echo "Conan server 2nd run: $?"

cd ../../

conan export . FreeGlut/3.0.0@iblis_ms/stable

remote=`conan remote list | grep "http://localhost:9300"`
if [ -z "$remote" ]; then
  conan remote add local http://localhost:9300
fi

conan user -p demo -r local  demo

conan upload FreeGlut/3.0.0@iblis_ms/stable --all -r=local --force

echo "FreeGlut was uploaded: $?"

cd "$callDir"
