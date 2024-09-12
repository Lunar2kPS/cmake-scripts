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
# OR
# ./build.sh --profile [PROFILE_NAME] --config [CONFIG]

# EXAMPLES:
#       ./cmake-scripts/build.sh Release      -> windows-x64-release
#       ./cmake-scripts/build.sh Debug        -> linux-x64-debug

argCount=$#
args=("$@")

thisScriptFolder="$(dirname "${BASH_SOURCE[0]}")"
source "$thisScriptFolder/get-main-cmake.sh"
source "$thisScriptFolder/path-utility.sh"
source "$thisScriptFolder/run-in-vs-cmd.sh"

# NOTE: These are default arg values:
config="Debug"
buildProfile=""

if [ $argCount -eq 1 ]; then
    config="${args[0]}"
elif [ $argCount -ge 2 ]; then
    for ((i = 0; $i < $argCount; i = i + 2)); do
        currentArg="${args[$i]}"
        nextArg="${args[(($i + 1))]}"

        case "$currentArg" in
            "--profile")        buildProfile="$nextArg";;
            "--config")         config="$nextArg";;
        esac
    done
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
    # NOTE: This means we HAVE To keep the build directory specified by the CMake preset, despite us wanting to have build profiles for some projects (like "editor", "game", etc.):
    #   I'd prefer to NOT over-complicate the CMakePresets.json file with even more presets (think: Win, Mac, Linux, etc. variants for EACH!)
    #   Instead, additional build scripts must copy THESE builds into their own folders as apart of their post-process build steps.
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
    "$postbuildScript" --exit-code $exitCode --output-path "out/build/$cmakePresetName" --config "$config" --args "$@"

    # EXAMPLE POST-BUILD SCRIPT ARGS HANDLING:
    # #!/bin/bash

    # argCount=$#
    # args=("$@")

    # buildExitCode=0
    # outputPath=""
    # config=""

    # for ((i = 0; $i < $argCount; i = i + 2)); do
    #     currentArg="${args[$i]}"
    #     nextArg="${args[(($i + 1))]}"

    #     case "$currentArg" in
    #         "--exit-code")      buildExitCode="$nextArg";;
    #         "--output-path")    outputPath="$nextArg";;
    #         "--config")         config="$nextArg";;
    #     esac
    # done

    exitCode=$?
    if [ $exitCode -ne 0 ]; then
        printf "Post-build script exited with error code $exitCode.\n"
    fi
fi

printf "\n\nSUCCESS!\n\n"
