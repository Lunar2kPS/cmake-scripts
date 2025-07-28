#!/bin/bash

# WARNING: These functions seem to be very slow compared to regular file path operations!
# When using these functions in a row many times, you may want to use &, $!, and wait commands to parallelize what you can and avoid observable lag.

# This calculates the relative path between two folders, and supports Windows, MacOS, and Linux.
#   MacOS does NOT support the use of the `--relative-to` option with the `realpath` command,
#   So this function had to get its own implementation for MacOS to support all platforms easily.
function getRelativePath() {
    # NOTE $0 only works when running this script directly.
    #   When this script is SOURCED from another bash script,
    #   We must use the BASH_SOURCE variable, which works in both cases.
    if [ -z "$simpleOSName" ]; then
        source "$(dirname "${BASH_SOURCE[0]}")/get-platform.sh" --silent
    fi
    local relativePath=""

    # WARNING: realpath --relative-to is NOT IMPLEMENTED on MacOS!
    #   Instead, let's roll our own, since it's fairly simple given 2 absolute paths from readlink -f (above)
    # This assumes the currentRealPath must be ABOVE the scriptRealPath.
    #   Aka, no one's gonna put their project under the cmake-scripts repo. Instead, they'll CONTAIN the cmake-scripts repo (directly or recursively).
    if [ "$simpleOSName" == "MacOS" ]; then
        # NOTE: These 2 are folder paths
        local from="$(readlink -f "$1")"
        local to="$(readlink -f "$2")"

        common="$from" # NOTE: Let's TRY to say we have everything in common with the $from folder path.
        # ${to#$common} removes (ONLY FROM THE BEGINNIG) the $common string, if it exists in the to.

        # While there's no COMPLETE (100%) match of $common being contained in the $to string,
        while [[ "${to#$common}" == "${to}" ]]; do
            common=$(dirname "$common") # NOTE: This removes a folder (goes up)
            relativePath="../${relativePath}"
        done
        relativePath="${relativePath}${to#$common/}"
    else
        local from="$(realpath "$1")"
        local to="$(realpath "$2")"
        relativePath="$(realpath --relative-to="$from" "$to")"
    fi
    echo "$relativePath"
}

function getAbsolutePath() {
    local absolutePath="$1"
    absolutePath="$(realpath "$absolutePath")"

    if [ -z "$simpleOSName" ]; then
        source "$(dirname "${BASH_SOURCE[0]}")/get-platform.sh" --silent
    fi
    absolutePath="$(cygpath -w "$absolutePath")"
    absolutePath="${absolutePath//\\/\/}"
    echo "$absolutePath"
}
