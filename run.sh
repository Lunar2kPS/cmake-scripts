#!/bin/bash

argCount=$#
args=("$@")

thisScriptFolder="$(dirname "${BASH_SOURCE[0]}")"
source "$thisScriptFolder/get-platform.sh" --silent
source "$thisScriptFolder/get-project-name.sh"

# NOTE: These are default arg values:
config="Debug"
buildProfile="editor"

if [ $argCount -eq 1 ]; then
    config="${args[0]}"
elif [ $argCount -ge 2 ]; then
    for ((i = 0; $i < $argCount; i = i + 2)); do
        currentArg="${args[$i]}"
        nextArg="${args[(($i + 1))]}"

        case "$currentArg" in
            "--profile")        buildProfile="$nextArg";;
            "--config")         config="$nextArg";;
        esac
    done
fi

lowercaseOSName="$(echo "$simpleOSName" | tr '[:upper:]' '[:lower:]')"
systemBitness="x64"
lowercaseConfig="$(echo "$config"| tr '[:upper:]' '[:lower:]')"

cmakePresetName="$lowercaseOSName-$systemBitness-$lowercaseConfig"
outFolderName="$cmakePresetName"
if [ -n "$buildProfile" ]; then
    outFolderName="$outFolderName-$buildProfile"
fi

if [ "$foundCMakeLists" = true ]; then
    buildFolderRoot="$cmakeFolder/out"
else
    buildFolderRoot="./out"
fi

case "$simpleOSName" in
    "Windows")      "$buildFolderRoot/build/$outFolderName/$projectName.exe";;
    "MacOS")        "$buildFolderRoot/build/$outFolderName/$projectName";;
    "Linux")        "$buildFolderRoot/build/$outFolderName/$projectName";;
esac
