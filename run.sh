#!/bin/bash

argCount=$#
args=("$@")

thisScriptFolder="$(dirname "${BASH_SOURCE[0]}")"
source "$thisScriptFolder/get-platform.sh" --silent
source "$thisScriptFolder/get-program-info.sh"
source "$thisScriptFolder/path-utility.sh"

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

for ((i = 0; i < "${#possibleFiles[@]}"; i++)) do
    possibleFiles[$i]="$(getAbsolutePath "${possibleFiles[$i]}")"
done

stdoutConnectedToATerminal=false
if [ -t 1 ]; then
    stdoutConnectedToATerminal=true
fi

if [ $stdoutConnectedToATerminal = true ]; then
    RED="\e[31m"
    GREEN="\e[32m"
    YELLOW="\e[33m"
    BRIGHT_BLUE="\e[1;34m"
    RESET_COLOR="\e[0m"
else
    RED=""
    GREEN=""
    YELLOW=""
    BRIGHT_BLUE=""
    RESET_COLOR=""
fi

# NOTE: This allows any 24-bit RGB color. Example shown is (255, 0, 0):
# ANY_COLOR="\e[38;2;255;0;0m"

mainExeFound=false
for file in "${possibleFiles[@]}"; do
    if [ -f "$file" ]; then
        containingFolder="$(dirname "$file")"
        fileName="$(basename "$file")"
        printf "✅ ${GREEN}Running main executable at:\n${YELLOW}$containingFolder/${BRIGHT_BLUE}$fileName${RESET_COLOR}\n\n"
        "$file"
        mainExeFound=true
        break
    fi
done

if [ $mainExeFound != true ]; then
    printf "❌ ${RED}Failed to find main executable at any of the following path(s):${RESET_COLOR}\n" >&2
    for file in "${possibleFiles[@]}"; do
        printf "    $file\n" >&2
    done
fi
