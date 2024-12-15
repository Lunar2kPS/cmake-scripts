#!/bin/bash

# NOTE: This script is used so that the original cmake-scripts path is remembered, so that even if `cd` is used,
#   More cmake-scripts can be easily run, even if $0 and ${BASH_SOURCE[0]} get skewed from recursive script sourcing and cd'ing.

# USAGE:
# (At the start of your scripts)
# source cmake-scripts/initialize.sh [--silent]

argCount=$#
args=("$@")

silentMode=false
for arg in ${args[@]}; do
    case "$arg" in
        "--silent")     silentMode=true;;
    esac
done

cmakeScriptsFolder="$(dirname "${BASH_SOURCE[0]}")"
source "$cmakeScriptsFolder/path-utility.sh"

cmakeScriptsFolder="$(getAbsolutePath "$cmakeScriptsFolder")"
if [ $silentMode != true ]; then
    echo "Initialized cmake-scripts folder at: $cmakeScriptsFolder"
fi
