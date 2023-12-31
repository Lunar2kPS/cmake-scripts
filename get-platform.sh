#/bin/bash

# COMMAND LINE USAGE:
# ./get-platform.sh [--silent]

# WARNING: Because this script is sourced, it could mess up other scripts if we named these just "argCount" and "args"!
getPlaformArgCount=$#
getPlatformArgs=("$@")

for ((i=0; i < $getPlaformArgCount; i++)); do
    if [ "${getPlatformArgs[$i]}" = "--silent" ]; then
        silentMode=true
    fi
done

# These are regexes to compare against $(uname) and $OSTYPE.

# WARNING: The case-insensitive modifier (?i)...(?-i) did NOT work for me
# on MINGW (Windows), so I'm avoiding it in the regex patterns! (using lowercase instead)
windowsNamePattern="(mingw)|(msys)"
macOSNamePattern="darwin"
linuxNamePattern="linux"

lowercaseUName=$(uname | tr '[:upper:]' '[:lower:]')
lowercaseOSType=$(echo "$OSTYPE" | tr '[:upper:]' '[:lower:]')

# Examples values per-platform:
#   Windows:
#       uname       MINGW64_NT-10.0-19044
#       $OSTYPE     msys
#   MacOS:
#       uname       Darwin
#       $OSTYPE     darwin21
#   Linux:
#       uname       Linux
#       $OSTYPE     linux-gnu

simpleOSName="Unknown"
if [[ $lowercaseUName =~ $windowsNamePattern && $lowercaseOSType =~ $windowsNamePattern ]]; then
    simpleOSName="Windows"
fi
if [[ $lowercaseUName =~ $macOSNamePattern && $lowercaseOSType =~ $macOSNamePattern ]]; then
    simpleOSName="MacOS"
fi
if [[ $lowercaseUName =~ $linuxNamePattern && $lowercaseOSType =~ $linuxNamePattern ]]; then
    simpleOSName="Linux"

    # NOTE $0 only works when running this script directly.
    #   When this script is SOURCED from another bash script,
    #   We must use the BASH_SOURCE variable, which works in both cases.
    "$(dirname ${BASH_SOURCE[0]})/pi-check.sh"

    exitCode=$?
    if [ $exitCode -ne 0 ]; then
        isRaspberryPi=true
    fi
fi

if [ "$silentMode" != true ]; then
    if [[ $isRaspberryPi == true ]]; then
        printf "Platform: $simpleOSName (Raspberry Pi)\n"
    else
        printf "Platform: $simpleOSName\n"
    fi
fi
