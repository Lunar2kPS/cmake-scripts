# NOTE:
# cmd.exe or VS' vcvarsall.bat was causing of some random error,
#   'ommunity' is not recognized as an internal or external command, operable program or batch file.
#   No idea why, but I think it was some string quoting issue, fixed by using a Windows Batch file (.bat) to run the command easier.

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

    if [ -z "$cmakeToScriptsFolder" ]; then
        source "$cmakeScriptsFolder/get-main-cmake.sh"
    fi

    # NOTE: We do NOT use BASH_SOURCE[0] here because that's this bash script's file path,
    #   But below in this script, we cd (change directory), so we need to use $cmakeToScriptsFolder, which is the folder path to get from the folder containing our main CMakeLists.txt to the cmake-scripts folder, so realpath can work:
    local batchFilePath="$cmakeToScriptsFolder/run-in-vs-cmd.bat"
    batchFilePath="$(realpath "$batchFilePath")"
    batchFilePath="$(cygpath -w "$batchFilePath")"
    batchFilePath="${batchFilePath//\\/\/}"

    cmd.exe //C "$batchFilePath" "$command"
}

function runInVSCmdIfWindows() {
    # WARNING: It seems that ${BASH_SOURCE[0]} is relative to the original first Bash script's pwd.
    #   So, if you cd and THEN source this script, it will be relative to the wrong directory in it.
    if [ -z "$simpleOSName" ]; then
        source "$cmakeScriptsFolder/get-platform.sh"
    fi

    local command="$1"
    if [ "$simpleOSName" = "Windows" ]; then
        runInVSCmd "$command"
    else
        eval " $command"
    fi
}
