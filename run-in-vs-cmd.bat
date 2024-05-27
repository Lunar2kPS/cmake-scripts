set "firstArg=%~1"
echo The first arg is: %firstArg%

"C:/Program Files/Microsoft Visual Studio/2022/Community/VC/Auxiliary/Build/vcvarsall.bat" x64 & %firstArg%
