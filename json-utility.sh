#!bin/bash
# NOTE: These functions require JSON.sh from:
#   https://github.com/dominictarr/JSON.sh
# You must set the jsonLibraryPath global variable before using these functions.
# For example,
#   jsonLibraryPath="./libraries/JSON.sh/JSON.sh"

# -s = Silent Mode
# -S = Show errors when they occur (only when -s is used)
# 2>&1 = Redirect stderr to stdout (to see the result in our testData variable below)
# testData="$(curl -sS https://registry.npmjs.org/express 2>&1)"

# Sets a global Bash array called lastJSONArray from the JSON.sh split output.
function getJSONArray() {
    local jsonText="$1"
    local arrayName="$2"
    local jsonSplit="$(echo "$jsonText" | "$jsonLibraryPath")"
    local regex="\\[\"$arrayName\",[0-9]+\][[:space:]]*\"(.*)\"" # NOTE: The double quotes here are important to get the WHOLE array!

    lastJSONArray=()
    while IFS= read -r line; do
        if [[ "$line" =~ $regex ]]; then
            lastJSONArray+=("${BASH_REMATCH[1]}")
        fi
    done <<< "$jsonSplit"
}

function getJSONValue() {
    local jsonText="$1"
    local key="$2"
    local jsonSplit="$(echo "$jsonText" | "$jsonLibraryPath")"
    local regex="\\[\"$key\"\\][[:space:]]*(.*)" # NOTE: NO DOUBLE QUOTES here, because we may have different types of values (integers, booleans, strings, etc.)

    while IFS= read -r line; do
        if [[ "$line" =~ $regex ]]; then
            lastJSONValue="${BASH_REMATCH[1]}"

            # NOTE: If it WAS a string, then we should remove the quotes:
            lastJSONValue="${lastJSONValue%\"}"  # Remove trailing quote (Bash parameter expansion)
            lastJSONValue="${lastJSONValue#\"}"  # Remove leading quote (Bash parameter expansion)
            return 0
        fi
    done <<< "$jsonSplit"

    # Not found:
    return 1
}