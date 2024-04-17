#!/bin/bash

argCount=$#
args=("$@")

thisScriptFolder="$(dirname "${BASH_SOURCE[0]}")"
source "$thisScriptFolder/get-platform.sh"
source "$thisScriptFolder/get-project-name.sh"

if [ $argCount -gt 0 ]; then
    config="${args[0]}"
else
    config="Debug"
fi

lowercaseOSName="$(echo "$simpleOSName" | tr '[:upper:]' '[:lower:]')"
systemBitness="x64"
lowercaseConfig="$(echo "$config"| tr '[:upper:]' '[:lower:]')"

cmakePresetName="$lowercaseOSName-$systemBitness-$lowercaseConfig"
printf "CMake Preset: $cmakePresetName\n"

if [ "$foundCMakeLists" = true ]; then
    buildFolderRoot="$cmakeFolder/out"
else
    buildFolderRoot="./out"
fi

case "$simpleOSName" in
    "Windows")      "$buildFolderRoot/build/$cmakePresetName/$projectName.exe";;
    "MacOS")        "$buildFolderRoot/build/$cmakePresetName/$projectName";;
    "Linux")        "$buildFolderRoot/build/$cmakePresetName/$projectName";;
esac
