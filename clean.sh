#!/bin/bash

thisScriptFolder="$(dirname $0)"
source "$thisScriptFolder/get-main-cmake.sh"

if [ "$foundCMakeLists" = true ]; then
    buildFolder="$cmakeFolder/out"
else
    buildFolder="out"
fi

printf "Cleaning folder...    ($buildFolder)\n"
rm -rf "$buildFolder"
