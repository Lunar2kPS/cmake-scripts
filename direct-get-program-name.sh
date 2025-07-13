#!/bin/bash

# NOTE $0 only works when running this script directly.
#   When this script is SOURCED from another bash script,
#   We must use the BASH_SOURCE variable, which works in both cases.
thisScriptFolder="$(dirname "${BASH_SOURCE[0]}")"

if [ -f "ProjectSettings.json" ]; then
    jsonLibraryPath="./libraries/JSON.sh/JSON.sh"
    source "$thisScriptFolder/json-utility.sh"

    projectSettingsJSON="$(cat ProjectSettings.json)"
    getJSONValue "$projectSettingsJSON" "programName"
fi

if [ -z "$$lastJSONValue" ]; then
    # If zero-length "programName" result, then let's default to the CMakeLists's project(...) name (aka, ${PROJECT_NAME} in CMake)
    source "$thisScriptFolder/get-project-name.sh"
    echo "$projectName"
else
    echo "$lastJSONValue"
fi
exit 0
