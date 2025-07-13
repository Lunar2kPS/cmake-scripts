#!/bin/bash

argCount=$#
args=("$@")

thisScriptFolder="$(dirname "${BASH_SOURCE[0]}")"
source "$thisScriptFolder/get-platform.sh" --silent
source "$thisScriptFolder/get-program-info.sh"

# NOTE: These are default arg values:
config="Debug"
buildProfile=""
defaultBuildProfile="game"

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

if [ "$foundCMakeLists" = true ]; then
    buildFolderRoot="$cmakeFolder/out"
else
    buildFolderRoot="./out"
fi

case "$simpleOSName" in
    "Windows")      fileExtension=".exe";;
    "MacOS")        fileExtension="";;
    "Linux")        fileExtension="";;
esac

possibleFiles=()

if [ -n "$buildProfile" ]; then
    possibleFiles+=("$buildFolderRoot/build/$cmakePresetName-$buildProfile/$programName$fileExtension")
else
    possibleFiles+=("$buildFolderRoot/build/$cmakePresetName-$defaultBuildProfile/$programName$fileExtension")
fi

# NOTE: This takes secondary precedence.
# We check FIRST for stuff like "windows-x64-debug-game" instead of the generic "windows-x64-debug" executable.
possibleFiles+=("$buildFolderRoot/build/$cmakePresetName/$programName$fileExtension")

mainExeFound=false
for file in "${possibleFiles[@]}"; do
    if [ -f "$file" ]; then
        printf "Found main executable at:\n    $file\n"
        "$file"
        mainExeFound=true
        break
    fi
done

if [ $mainExeFound != true ]; then
    printf "Failed to find main executable at any of the following path(s):\n" >&2
    for file in "${possibleFiles[@]}"; do
        printf "    $file\n" >&2
    done
fi
