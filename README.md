# CMake C++ Scripts
This Git repo contains scripts to help you easily build and run C++ projects created with CMake on Windows, Mac, and Linux.


## 🖥️ Developer Workflow
The [aliases.sh](/aliases.sh) script allows all the bash scripts in this top-level (except for the scripts defined by the `$ignoreScripts` array) to be used as aliases without their ".sh" file extension.

This allows for super easy usage of building, running, and cleaning a project built with CMake.

**The build process, does however, depend on a CMakePresets.json file.**
A **sample CMakePresets.json file is provided** as [CMakePresets-Sample.json](/CMakePresets-Sample.json), which you may copy into your CMake project's root level for convenience.

## ♻️ Automating aliases.sh Upon Opening VS Code
It seems that VS Code tasks are unable to run in your integrated terminal (such as Git Bash), so instead, you can copy the following into your `~/.bashrc` file:

Every time a bash or Git Bash terminal opens, it'll run `source ./cmake-scripts/aliases.sh` if the following 2 conditions are true:
1. The folder the terminal is opened up in is a local Git repo.
2. A subfolder exists named "cmake-scripts" that contains the "aliases.sh" file.
    - _Typically, I bring in this cmake-scripts Git repo as a git submodule at the root of my project, which works with this structure._

```sh
# CUSTOM from https://github.com/Lunar2kPS/cmake-scripts:
# --- --- ---
supportedFolders=(
    "cmake-scripts"
    "PixelEngine/cmake-scripts"
)

function automaticCmakeCommands() {
    # NOTE: We redirect standard output (stream 1) and standard error (stream 2) to be discarded (/dev/null)
    isInGitRepo="$(git rev-parse --is-inside-work-tree 2>/dev/null)"
    exitCode=$?
    if [ $exitCode -ne 0 ]; then
        isInGitRepo="false"
    fi

    if [[ $isInGitRepo != "true" ]]; then
        return 1;
    fi

    for possibleFolder in "${supportedFolders[@]}"; do
        local cmakeAliases="$possibleFolder/aliases.sh"
        if [ -f "$cmakeAliases" ]; then
            source "$cmakeAliases"
            break
        fi
    done

    # Even if git rev-parse fails cause we're not in a git repo,
    #   This ensures we always succeed by default at the end
    #   of this script.
    return 0
}

automaticCmakeCommands
# --- --- ---
```
