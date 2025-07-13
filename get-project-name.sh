#!/bin/bash

# NOTE $0 only works when running this script directly.
#   When this script is SOURCED from another bash script,
#   We must use the BASH_SOURCE variable, which works in both cases.
thisScriptFolder="$(dirname "${BASH_SOURCE[0]}")"
source "$thisScriptFolder/get-main-cmake.sh"

if [ "$foundCMakeLists" != true ]; then
    cmakeFile="CMakeLists.txt"
fi

projectNameRegex='project\(([A-Za-z0-9\._]+) VERSION ([0-9\.]+)'
mainCMakeText="$(cat "$cmakeFile")"
if ! [[ $mainCMakeText =~ $projectNameRegex ]]; then
    echo "Failed to find main program version from CMake." >&2
    exit 40
fi

projectName="${BASH_REMATCH[1]}"
programVersion="${BASH_REMATCH[2]}"
