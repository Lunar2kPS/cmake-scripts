#!/bin/bash

launchJSONFilePath=".vscode/launch.json"
if [ ! -f "$launchJSONFilePath" ]; then
    exit 0
fi

# NOTE $0 only works when running this script directly.
#   When this script is SOURCED from another bash script,
#   We must use the BASH_SOURCE variable, which works in both cases.
thisScriptFolder="$(dirname "${BASH_SOURCE[0]}")"
source "$thisScriptFolder/get-project-name.sh"
source "$thisScriptFolder/get-program-info.sh"
oldName="$projectName"
newName="$programName"

if [ "$oldName" == "$newName" ]; then
    exit 0
fi

# Create a temp file
tempFilePath="${launchJSONFilePath}.temp"

# Backup original
touch "$tempFilePath"

regex="\"program\":.*$oldName"

# Replace any line with both "program": and the old name
while IFS= read -r line; do
    if [[ "$line" =~ $regex ]]; then
        modifiedLine="${line//$oldName/$newName}"
        echo "$modifiedLine" >> "$tempFilePath"
    else
        echo "$line" >> "$tempFilePath"
    fi
done < "$launchJSONFilePath"

# Overwrite the original file
originalText="$(cat "$launchJSONFilePath")"
newText="$(cat "$tempFilePath")"
if [ "$originalText" != "$newText" ]; then
    mv "$tempFilePath" "$launchJSONFilePath"
    echo "✅ launch.json updated: '$oldName' → '$newName'"
else
    rm "$tempFilePath"
fi
