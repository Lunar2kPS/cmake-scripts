#!/bin/bash

thisScriptFolder="$(dirname $0)"
source "$thisScriptFolder/get-platform-default-config.sh"
source "$thisScriptFolder/get-project-name.sh"
source "$thisScriptFolder/get-main-cmake.sh"

if [ "$foundCMakeLists" = true ]; then
    buildFolderRoot="$cmakeFolder/out"
else
    buildFolderRoot="./out"
fi

case "$simpleOSName" in
    "Windows")      "$buildFolderRoot/build/$defaultConfig/$projectName.exe";;
    "MacOS")        "$buildFolderRoot/build/$defaultConfig/$projectName";;
    "Linux")        "$buildFolderRoot/build/$defaultConfig/$projectName";;
esac
