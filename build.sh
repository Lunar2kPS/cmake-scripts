#!/bin/bash

# This is a helper script to build when Visual Studio is not available
#       (For example, when developing on MacOS or Linux systems).
# The default configuration is the 64-bit Release version for your OS.
# Note that you may pass a different config as an argument.
# To see the available values, see the "name" values of the configurationPresets array in CMakePresets.json

# COMMAND LINE USAGE:
# ./build.sh [CONFIG]
#   CONFIG must be either Debug or Release.
#   Based on your platform, it will automatically figure out the CMake preset name to use (such as "windows-x64-release" from Release if you're on Windows, for example)

# EXAMPLES:
#       ./cmake-scripts/build.sh Release      -> windows-x64-release
#       ./cmake-scripts/build.sh Debug        -> linux-x64-debug

# NOTE:
# cmd.exe or VS' vcvarsall.bat was causing of some random error,
#   'ommunity' is not recognized as an internal or external command, operable program or batch file.
#   No idea why, maybe it was cause I didn't have Ninja installed? But either way, I realized we should be using Visual Studio 17 2022 as the CMake generator anyway!

# WARNING: Git Bash for Windows must use double slashes:
# cmd.exe //C
# https://stackoverflow.com/questions/21357813/bash-in-git-for-windows-weirdness-when-running-a-command-with-cmd-exe-c-with-a
function runInVSCmd() {
    local command="$1"
    # NOTE: Removing this because quoting was going horribly wrong!
    #   It was also seeming that Git Bash was mistaking the & to run part of the command in the background!
    # cmd.exe //C "C:/Program Files/Microsoft Visual Studio/2022/Community/VC/Auxiliary/Build/vcvarsall.bat x64 & $command"

    # The `start` command would let Windows pick the right program to launch the Windows Batch (.bat) script, but the windows would stay open and the "exit" command wouldn't work.

    # So, we can use cmd.exe //C run-in-vs-cmd.bat {ARG1}, which seems to be the easiest solution!

     # NOTE: We need the Windows-style path
        #   (although, I'ma use forward slashes (/) everywhere still) or else
        #   CMake won't know where paths like /d/Projects are. It needs to be in the format like D:/Projects, for Windows, instead.

    # NOTE: We do NOT use BASH_SOURCE[0] here because that's this bash script's file path,
    #   But below in this script, we cd (change directory), so we need to use $cmakeToScriptsFolder, which is the folder path to get from the folder containing our main CMakeLists.txt to the cmake-scripts folder, so realpath can work:
    local batchFilePath="$cmakeToScriptsFolder/run-in-vs-cmd.bat"
    batchFilePath="$(realpath "$batchFilePath")"
    batchFilePath="$(cygpath -w "$batchFilePath")"
    batchFilePath="${batchFilePath//\\/\/}"

    cmd.exe //C "$batchFilePath" "$command"
}

function runInVSCmdIfWindows() {
    local command="$1"
    if [ "$simpleOSName" = "Windows" ]; then
        runInVSCmd "$command"
    else
        eval " $command"
    fi
}

argCount=$#
args=("$@")

thisScriptFolder="$(dirname "${BASH_SOURCE[0]}")"
source "$thisScriptFolder/get-main-cmake.sh"
source "$thisScriptFolder/get-relative-path.sh"

if [ $argCount -gt 0 ]; then
    config="${args[0]}"
else
    config="Debug"
fi

lowercaseOSName="$(echo "$simpleOSName" | tr '[:upper:]' '[:lower:]')"
systemBitness="x64"
lowercaseConfig="$(echo "$config" | tr '[:upper:]' '[:lower:]')"

cmakePresetName="$lowercaseOSName-$systemBitness-$lowercaseConfig"
printf "CMake Preset: $cmakePresetName\n"

if [ "$foundCMakeLists" = true ]; then
    cd "$cmakeFolder"
fi

currentDir="$(pwd)"
prebuildScript="$currentDir/pre-build.sh"
postbuildScript="$currentDir/post-build.sh"
if [ -f "$prebuildScript" ]; then
    printf "\nPre-build script running...\n   ($prebuildScript)\n"
    
    # NOTE: We do NOT source here, because the pre-build/post-build scripts might have conflicting, unrelated variables set, such as $config.
    "$prebuildScript"
    exitCode=$?
    if [ $exitCode -ne 0 ]; then
        printf "Pre-build script exited with error code $exitCode.\n"
        exit $exitCode
    fi
fi

printf "Building $config (preset: $cmakePresetName)...\n\n"
printf "Running CMake...\n"
hasCMakePresets=false
if [ -f "CMakePresets.json" ]; then
    hasCMakePresets=true
    runInVSCmdIfWindows "cmake --preset $cmakePresetName"
else
    cmake  . -B "out/build" \
        -D CMAKE_BUILD_TYPE="$config"
fi

exitCode=$?
if [ $exitCode -ne 0 ]; then
    exit $exitCode
fi
printf "\nRunning CMake build system...\n"
if [[ $hasCMakePresets == true ]]; then
    runInVSCmdIfWindows "cmake --build out/build/$cmakePresetName"
else
    cmake --build "out/build" --config "$config"
fi

exitCode=$?
if [ $exitCode -ne 0 ]; then
    exit $exitCode
fi
if [ -f "$postbuildScript" ]; then
    printf "\nPost-build script running...\n    ($postbuildScript)\n"

    # NOTE: We do NOT source here, because the pre-build/post-build scripts might have conflicting, unrelated variables set, such as $config.
    # COMMAND LINE USAGE:
    # post-build.sh {BUILD_EXIT_CODE} {BUILD_OUTPUT_FOLDER}
    "$postbuildScript" --exit-code $exitCode --output-path "out/build/$cmakePresetName" --config "$config"
    
    exitCode=$?
    if [ $exitCode -ne 0 ]; then
        printf "Post-build script exited with error code $exitCode.\n"
    fi
fi

printf "\n\nSUCCESS!\n\n"
