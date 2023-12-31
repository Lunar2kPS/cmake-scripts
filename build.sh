#!/bin/bash

# This is a helper script to build when Visual Studio is not available
#       (For example, when developing on MacOS or Linux systems).
# The default configuration is the 64-bit Release version for your OS.
# Note that you may pass a different config as an argument.
# To see the available values, see the "name" values of the configurationPresets array in CMakePresets.json

# COMMAND LINE USAGE:
# ./build.sh [CONFIG]

# EXAMPLES:
#       ./build.sh windows-x64-release
#       ./build.sh linux-x64-debug

function runInVSCmd() {
    local command="$1"
    cmd.exe /C "\"C:/Program Files/Microsoft Visual Studio/2022/Community/VC/Auxiliary/Build/vcvarsall.bat\" x64 & $command"
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

thisScriptFolder="$(dirname $0)"
source "$thisScriptFolder/get-platform-default-config.sh"
source "$thisScriptFolder/get-main-cmake.sh"

if [ "$foundCMakeLists" = true ]; then
    cd "$cmakeFolder"
fi
currentDir="$(pwd)"

if [ $argCount -gt 0 ]; then
    config=${args[0]}
else
    config="$defaultConfig"
fi

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

printf "Building $config...\n\n"
printf "Running CMake...\n"
hasCMakePresets=false
if [ -f "CMakePresets.json" ]; then
    hasCMakePresets=true
    runInVSCmdIfWindows "cmake --preset $config"
else
    cmake  . -B out/build
fi

exitCode=$?
if [ $exitCode -ne 0 ]; then
    exit $exitCode
fi
printf "\nRunning CMake build system...\n"
if [[ $hasCMakePresets == true ]]; then
    runInVSCmdIfWindows "cmake --build out/build/$config"
else
    cmake --build out/build
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
    "$postbuildScript" $exitCode "out/build/$config"
    
    exitCode=$?
    if [ $exitCode -ne 0 ]; then
        printf "Post-build script exited with error code $exitCode.\n"
    fi
fi

printf "\n\nSUCCESS!\n\n"
