#!/bin/bash

# NOTE: From ChatGPT
# In this modified command, we added an additional awk command at the end.
# The first awk command (awk -F '[()]' '{print $2}') is used to extract
# the string between the parentheses, which orresponds to the first argument of the project() command.

# The second awk command (awk '{print $1}') is used to extract
# the first field from the output of the previous awk command. This will give you the first argument from the project() command.

thisScriptFolder="$(dirname $0)"
source "$thisScriptFolder/get-main-cmake.sh"

if [ "$foundCMakeLists" != true ]; then
    cmakeFile="CMakeLists.txt"
fi
projectName=$(grep -m 1 'project(' "$cmakeFile" | awk -F '[()]' '{print $2}' | awk '{print $1}' | xargs)
