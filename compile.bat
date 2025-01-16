@echo off
echo =========================================
echo NimRAT Compiler // github.com/WipingAllOut
echo =========================================
echo Select an option:
echo 1 - Install packages
echo 2 - Compile the program
echo 3 - Install packages and compile
echo 4 - (Debug) Compile with console window

set /p choice="> "

if "%choice%"=="1" (
    echo Installing packages...
    nimble install dimscord
    nimble install nimprotect
    nimble install winim
    nimble install pixie
    echo Packages installed successfully!
)

if "%choice%"=="2" (
    echo Compiling the program...
    nim c -d:danger --app:gui --mm:arc -d:useMalloc --panics:on program.nim
    echo Compilation complete!
)

if "%choice%"=="3" (
    echo Installing packages and compiling...
    nimble install dimscord
    nimble install nimprotect
    nimble install winim
    nimble install pixie
    nim c -d:danger --app:gui --mm:arc -d:useMalloc --panics:on program.nim
    echo Packages installed and program compiled successfully!
)

if "%choice%"=="4" (
    echo Compiling the program...
    nim c -d:danger --mm:arc -d:useMalloc --panics:on program.nim
    echo Compilation complete!
)

echo =========================================
timeout 5
