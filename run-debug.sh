#!/bin/bash

thisScriptFolder="$(dirname $0)"
source "$thisScriptFolder/get-platform-default-config.sh"
source "$thisScriptFolder/get-project-name.sh"
source "$thisScriptFolder/get-main-cmake.sh"

defaultDebugConfig=${defaultConfig/release/debug}
if [ "$foundCMakeLists" = true ]; then
    buildFolderRoot="$cmakeFolder/out"
else
    buildFolderRoot="./out"
fi

case "$simpleOSName" in
    "Windows")      "$buildFolderRoot/build/$defaultDebugConfig/$projectName.exe";;
    "MacOS")        "$buildFolderRoot/build/$defaultDebugConfig/$projectName";;
    "Linux")        "$buildFolderRoot/build/$defaultDebugConfig/$projectName";;
esac
