#!/bin/bash

ignoreScripts=(
    "README.md"
    "aliases"
    "get-platform-default-config"
    "get-platform"
    "get-project-name"
)

scriptsFolder="$(dirname "${BASH_SOURCE[0]}")"
printf "Adding aliases for the bash scripts under '$scriptsFolder'\n"
for filePath in "$scriptsFolder/"*; do
    fileName="$(basename $filePath)"
    if [[ $fileName != *.sh ]]; then
        continue
    fi

    aliasName=${fileName/.sh/}

    ignore=false
    for ignoreName in "${ignoreScripts[@]}"; do
        if [ "$aliasName" == "$ignoreName" ]; then
            ignore=true
            break
        fi
    done

    if [ $ignore == true ]; then
        continue
    fi

    printf "%-5s%-30s\n" " - " "$aliasName"
    alias $aliasName="$filePath"
done
