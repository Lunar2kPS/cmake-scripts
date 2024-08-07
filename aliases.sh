#!/bin/bash

currentFolder="$(dirname "${BASH_SOURCE[0]}")"
proxyAliasFolder=""
ignoreScripts=(
    "README.md"
    "aliases"
    "get-main-cmake"
    "get-platform"
    "get-project-name"
    "get-relative-path"
)

source "$currentFolder/get-relative-path.sh"
printf "Adding aliases for bash scripts under...\n"

function setDefaultValues() {
    proxyAliasFolder=""
    ignoreScripts=()
}

function addAliasesForCurrentFolder() {
    local searchFolder=""
    if [ -n "$proxyAliasFolder" ]; then
        searchFolder="$proxyAliasFolder"
    else
        searchFolder="$currentFolder"
    fi
    local displayFolder=""
    if [ -n "$previousPwd" ]; then
        displayFolder="$(getRelativePath "$previousPwd" "$searchFolder")"
    else
        displayFolder="$searchFolder"
    fi
    printf "%2s$displayFolder:\n" ""
    for filePath in "$searchFolder/"*; do
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

        printf "%4s%-4s%-30s\n" "" "-" "$aliasName"
        alias $aliasName="$filePath"
    done
}
addAliasesForCurrentFolder

currentFolder="$(realpath "$(dirname "$currentFolder")")"
previousPwd="$(realpath "$(pwd)")"
while [ -n "$currentFolder" ]; do
    cd "$currentFolder"
    isInGitRepo="$(git rev-parse --is-inside-work-tree 2>/dev/null)"
    cd "$previousPwd"
    if [ "$isInGitRepo" = true ]; then
        if [ -f "$currentFolder/aliases.sh" ]; then
            setDefaultValues
            source "$currentFolder/aliases.sh"
            addAliasesForCurrentFolder
        elif [ -d "$currentFolder/shortcut-scripts" ]; then
            setDefaultValues
            proxyAliasFolder="$currentFolder/shortcut-scripts"
            addAliasesForCurrentFolder
        fi
    else
        break
    fi
    currentFolder="$(realpath "$(dirname $currentFolder)")"
done
cd "$previousPwd"
