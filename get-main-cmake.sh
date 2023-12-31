#!/bin/bash

thisScriptFolder="$(dirname $0)"
source "$thisScriptFolder/get-platform.sh" "--silent"

if [ "$simpleOSName" = "MacOS" ]; then
    currentRealPath="$(readlink -f "$(pwd)")"
    scriptRealPath="$(readlink -f "$thisScriptFolder")"

    # WARNING: realpath --relative-to is NOT IMPLEMENTED on MacOS!
    #   Instead, let's roll our own, since it's fairly simple given 2 absolute paths from readlink -f (above)
    # This assumes the currentRealPath must be ABOVE the scriptRealPath.
    #   Aka, no one's gonna put their project under the cmake-scripts repo. Instead, they'll CONTAIN the cmake-scripts repo (directly or recursively).

    # This calculates the relative path between two folders on MacOS.
    calculateRelativePathMacOS() {
        # NOTE: These 2 are folder paths
        src=$(readlink -f "$1")
        target=$(readlink -f "$2")
        # src="$1"
        # target="$2"

        common="$src" # NOTE: Let's TRY to say we have everything in common with the $src folder path.
        relativePath=""

        # ${target#$common} removes (ONLY FROM THE BEGINNIG) the $common string, if it exists in the target.

        # While there's no COMPLETE (100%) match of $common being contained in the $target string,
        while [[ "${target#$common}" == "${target}" ]]; do
            common=$(dirname "$common") # NOTE: This removes a folder (goes up)
            relativePath="../${relativePath}"
        done
        relativePath="${relativePath}${target#$common/}"
    }
    calculateRelativePathMacOS "$currentRealPath" "$scriptRealPath"
else
    currentRealPath="$(realpath "$(pwd)")"
    scriptRealPath="$(realpath "$thisScriptFolder")"
    relativePath="$(realpath --relative-to="$currentRealPath" "$scriptRealPath")" # EX: "PixelEngine/cmake-scripts"
fi


# For debugging:
# printf "currentRealPath = $currentRealPath\nscriptRealPath = $scriptRealPath\nrelativePath = $relativePath\n"

cmakeFolder=""
cmakeFile=""
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

# NOTE: relativePath does NOT have a trailing slash (/), so we'll never the cmake-scripts folder (good!).
relativePathLength=${#relativePath}
for ((i=0; i<$relativePathLength; i++)); do
    currentChar="${relativePath:$i:1}"
    
    # NOTE: printf "-" will trick printf, thinking you're trying to pass an option, and then it'll error out.
    # To make sure this line only treats $currentChar as a string literal, we use %s like so:
    # printf "%s " "$currentChar"

    if [[ "$currentChar" = "/" ]]; then
        nextFolder="${relativePath:$startIndex:$i}"
        checkForCMake "$nextFolder"
    fi
done
