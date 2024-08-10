#!/bin/bash

# NOTE: This script is used so that the original cmake-scripts path is remembered, so that even if `cd` is used,
#   More cmake-scripts can be easily run, even if $0 and ${BASH_SOURCE[0]} get skewed from recursive script sourcing and cd'ing.

# USAGE:
# (At the start of your scripts)
# source cmake-scripts/initialize.sh

cmakeScriptsFolder="$(dirname "${BASH_SOURCE[0]}")"
source "$cmakeScriptsFolder/path-utility.sh"

cmakeScriptsFolder="$(getAbsolutePath "$cmakeScriptsFolder")"
echo "Initialized cmake-scripts folder at: $cmakeScriptsFolder"
