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

source $(dirname $0)"/get-platform-default-config.sh"

argCount=$#
args=("$@")

if [ $argCount -gt 0 ]; then
    config=${args[0]}
else
    config="$defaultConfig"
fi

printf "Building $config...\n\n"
printf "Running CMake...\n"

hasCMakePresets=0
if [ -f "CMakePresets.json" ]; then
    hasCMakePresets=1
    runInVSCmdIfWindows "cmake --preset $config"
else
    cmake  . -B out/build
fi

exitCode=$?
if [ $exitCode -ne 0 ]; then
    exit $exitCode
fi
printf "\n"

printf "Running CMake build system...\n"

if [ $hasCMakePresets -eq 1 ]; then
    runInVSCmdIfWindows "cmake --build out/build/$config"
else
    cmake --build out/build
fi

exitCode=$?
if [ $exitCode -ne 0 ]; then
    exit $exitCode
fi

printf "\n\nSUCCESS!\n\n"
