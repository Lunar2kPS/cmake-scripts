@ECHO OFF

set "firstArg=%~1"
@REM echo The first arg is: %firstArg%

"C:/Program Files/Microsoft Visual Studio/2022/Community/VC/Auxiliary/Build/vcvarsall.bat" x64 & %firstArg%
