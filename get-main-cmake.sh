#!/bin/bash
# This script checks all the folders between the current folder (pwd) and the folder containing
# All of the cmake-scripts (not including the cmake-scripts folder),
# To find the first CMakeLists.txt.

thisScriptFolder="$(dirname "${BASH_SOURCE[0]}")"
source "$thisScriptFolder/get-platform.sh" --silent
source "$thisScriptFolder/get-relative-path.sh"

# EX: "PixelEngine/cmake-scripts"
relativePath="$(getRelativePath "$(pwd)" "$thisScriptFolder")"

cmakeFolder=""
cmakeFile=""
cmakeToScriptsFolder=""
foundCMakeLists=false
function checkForCMake() {
    local currentPath="$1"
    local possibleCMakeFile="$currentPath/CMakeLists.txt"

    if [ -f "$possibleCMakeFile" ]; then
        foundCMakeLists=true
        cmakeFile="$possibleCMakeFile"
        cmakeFolder="$(dirname $cmakeFile)"
    fi
}

# NOTE: relativePath does NOT have a trailing slash (/), so we'll never check the cmake-scripts folder (good!).

checkForCMake "."
if [ $foundCMakeLists = true ]; then
    cmakeToScriptsFolder="$relativePath"
else
    relativePathLength=${#relativePath}
    for ((i=0; i<$relativePathLength; i++)); do
        currentChar="${relativePath:$i:1}"

        # NOTE: printf "-" will trick printf, thinking you're trying to pass an option, and then it'll error out.
        # To make sure this line only treats $currentChar as a string literal, we use %s like so:
        # printf "%s " "$currentChar"

        if [[ "$currentChar" = "/" ]]; then
            nextFolder="${relativePath:0:$i}"
            checkForCMake "$nextFolder"

            if [ $foundCMakeLists = true ]; then
                cmakeToScriptsFolder="${relativePath:($i + 1):($relativePathLength - 1)}"
                break
            fi
        fi
    done
fi

if [ $foundCMakeLists != true ]; then
    echo "Failed to find CMakeLists.txt in current directory or any subdirectories down to the $thisScriptFolder folder."
fi
